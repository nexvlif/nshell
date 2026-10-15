#!/usr/bin/env python3
"""Static smoke suite for nshell — no compositor needed (runs in CI).

Checks the invariants the three workstreams depend on:
  1. Config keys referenced by new code actually exist in Config.qml.
  2. Avatar image goes through services/Avatar.qml (no hardcoded overrides).
  3. Vertical bar has coffee/gamemode (+ bluetooth/notif) parity.
  4. hypridle conf is marked fallback-only.
  5. Weather manual-override plumbing exists end to end.
  6. shell.qml keeps the inhibit + lock wiring alive.
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
fails: list[str] = []


def check(name: str, cond: bool, hint: str = "") -> None:
    print(("PASS " if cond else "FAIL ") + name + (f" — {hint}" if hint and not cond else ""))
    if not cond:
        fails.append(name)


def read(rel: str) -> str:
    return (ROOT / rel).read_text()


cfg = read("services/Config.qml")
bar = read("modules/bar/Bar.qml")
hypridle = read("scripts/hypridle-nshell.conf")
weather = read("services/Weather.qml")
# Settings content lives in Settings.qml + Page*.qml siblings.
def read_settings() -> str:
    parts = [(ROOT / "modules/settings/Settings.qml").read_text()]
    for p in sorted((ROOT / "modules/settings").glob("Page*.qml")):
        parts.append(p.read_text())
    return "\n".join(parts)


settings = read_settings()
wxcard = read("modules/widgets/WeatherCard.qml")
shell = read("shell.qml")
avatar = read("services/Avatar.qml")

# 1. Config keys
for key in ["avatarPath", "autoLocate", "property string place",
            "property real lat", "property real lon",
            "property JsonObject weather", "property JsonObject coffee",
            "property JsonObject gamemode"]:
    check(f"config defines {key}", key in cfg)

# 2. Avatar centralization: no hardcoded image *sources* outside Avatar.qml
# (placeholder/help text mentioning the default path is fine).
strays = []
for f in sorted(ROOT.rglob("*.qml")):
    if f.name == "Avatar.qml" or "venv" in f.parts:
        continue
    for line in f.read_text().splitlines():
        if "Pictures/pp.jpg" in line and ("file://" in line or "source" in line):
            strays.append(f"{f.relative_to(ROOT)}: {line.strip()}")
            break
check("avatar centralized in Avatar.qml", not strays, f"hardcoded in {strays}")
check("bar uses Avatar.source", bar.count("Avatar.source") >= 2)
check("lock uses Avatar.source", "Avatar.source" in read("modules/lock/LockScreen.qml"))
check("session uses Avatar.source", "Avatar.source" in read("modules/session/SessionMenu.qml"))
check("avatar falls back to pp.jpg", "Pictures/pp.jpg" in avatar)

# 3. Vertical bar parity — slice from the vertical NRect to end of file
vstart = bar.find('visible: vertical')
vblock = bar[vstart:] if vstart >= 0 else ""
for icon in ['"coffee"', '"sports_esports"', "Bluetooth.icon", "Notifs.dnd"]:
    check(f"vertical bar has {icon}", icon in vblock)
check("vertical coffee toggles", "Coffee.toggle()" in vblock)
check("vertical gamemode toggles", "GameMode.toggle()" in vblock)

# 4. Official idle/suspend path
check("hypridle marked fallback", "FALLBACK ONLY" in hypridle)
check("hypridle points at SleepLock", "SleepLock" in hypridle)
check("settings behavior cites official", "SleepLock" in settings)

# 5. Weather override plumbing
for fn in ["setManual", "setAuto", "applyConfig", "cfgAuto"]:
    check(f"weather has {fn}", fn in weather)
check("settings weather section", "Auto-detect location" in settings)
check("settings avatar row", "Avatar image" in settings and "bar.avatarPath" in settings)
check("weathercard refresh", '"sync"' in wxcard)
check("weathercard manual hint", "manual" in wxcard)

# 6. shell wiring
check("shell idle inhibitor", "IdleInhibitor" in shell and "Coffee.enabled" in shell and "GameMode.enabled" in shell)
check("shell keeps AutoLock", "AutoLock" in shell)
check("shell keeps SleepLock", "SleepLock" in shell)
check("shell ipc openApp", "openApp" in shell)
check("shell registers Apps", "Apps {}" in shell and "qs.modules.apps" in shell)

# 9. Bundled everyday apps
ui = read("services/Ui.qml")
launcher = read("modules/launcher/Launcher.qml")
check("ui apps state", "appsOpen" in ui and 'appPage' in ui)
check("ui openApp/toggleApps", "openApp(page" in ui and "toggleApps(page" in ui)
check("ui single exclusivity", '"appsOpen"' in ui and '"launcherOpen"' in ui and "function _flip(prop: string)" in ui)
check("ui no duplicated close-lists", all(f"{p} = false" not in ui for p in [
    "launcherOpen", "sessionOpen", "nflyoutOpen", "controlOpen", "clipOpen",
    "notifOpen", "calendarOpen", "screenshotOpen", "recordingOpen",
    "galleryOpen", "fileOpen", "settingsOpen"]))
for page in ["CalcPage", "CameraPage", "RecPage"]:
    check(f"apps has {page}", (ROOT / f"modules/apps/{page}.qml").exists())
for entry in ["Calculator", "Camera", "Voice recorder", "openApp(\"calc\")",
              "openApp(\"camera\")", "openApp(\"rec\")"]:
    check(f"launcher has {entry}", entry in launcher)
check("recorder dep listed", '"ffmpeg"' in read("services/Deps.qml"))

# 10. Apps is a floating draggable window, not a modal popup
apps = read("modules/apps/Apps.qml")
check("apps no modal dim", "0.45" not in apps)
check("apps no outside-close", apps.count("Ui.closeAll()") == 2)  # Esc + titlebar X only
check("apps drag handle", "dragArea" in apps and "clampX" in apps)
check("apps persists pos", "apps.pos" in apps and "property JsonObject apps" in cfg)
check("apps recenter", "onDoubleClicked" in apps)
check("apps hugs content", "anchors" in apps and "posX" in apps)

# 7. Config.options top-level refs resolve to a defined section
sections = set(re.findall(r"property JsonObject (\w+)", cfg))
_settings_files = ["modules/settings/Settings.qml"] + sorted(
    str(p.relative_to(ROOT)) for p in (ROOT / "modules/settings").glob("Page*.qml"))
refs = set(re.findall(r"Config\.options\.(\w+)", "".join(
    (ROOT / f).read_text() for f in [
        "modules/bar/Bar.qml"] + _settings_files + [
        "modules/widgets/WeatherCard.qml", "services/Weather.qml",
        "services/Avatar.qml", "modules/lock/LockScreen.qml",
        "modules/session/SessionMenu.qml"])))
unknown = sorted(refs - sections)
check("config sections resolve", not unknown, f"unknown {unknown} vs {sorted(sections)}")

# 11. Settings pages live in split Page*.qml siblings, parent only instantiates
_pages = sorted((ROOT / "modules/settings").glob("Page*.qml"))
_parent = (ROOT / "modules/settings/Settings.qml").read_text()
check("settings split", len(_pages) >= 14)
check("settings parent instantiates", _parent.count("visible: root.page ===") == 14
      and "SSection" not in _parent and "ColumnLayout {\n                                visible" not in _parent)

# 8. Every icon/name literal must exist in the bundled MaterialSymbolsLite
# font (ligature GSUB; '_' is stored as 'underscore'). A missing name
# renders as literal text instead of a glyph.
try:
    from fontTools.ttLib import TTFont
except ImportError:
    print("SKIP icon coverage (no fontTools)")
else:
    font = TTFont(str(ROOT / "assets/fonts/MaterialSymbolsLite.ttf"))
    ligs = set()
    for lookup in font["GSUB"].table.LookupList.Lookup:
        for st in lookup.SubTable:
            for first, ls in getattr(st.ExtSubTable, "ligatures", {}).items():
                for lg in ls:
                    ligs.add(first + "".join(lg.Component))
    used: dict[str, list[str]] = {}
    for qml in sorted(ROOT.rglob("*.qml")):
        if "venv" in qml.parts:
            continue
        lines = qml.read_text().splitlines()
        for i, line in enumerate(lines):
            for m in re.finditer(r'(?:icon|name): "([a-z_]+)"', line):
                # Launcher section headers reuse `name:` for titles, not glyphs.
                if m.group(0).startswith("name:") and any(
                        'kind: "header"' in lines[j] for j in range(max(0, i - 2), i)):
                    continue
                used.setdefault(m.group(1), []).append(str(qml.relative_to(ROOT)))
    bad = {u: fs for u, fs in used.items() if u.replace("_", "underscore") not in ligs}
    check("icons covered by bundled font", not bad,
          f"missing {sorted(bad)} e.g. {next(iter(bad.values()))[:2] if bad else ''}")

print(f"\n{len(fails)} failure(s)")
sys.exit(1 if fails else 0)
