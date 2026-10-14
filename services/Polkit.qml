pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Polkit

Singleton {
    id: root

    property string actionId: ""
    property string message: ""
    property string iconName: ""
    property string inputPrompt: ""
    property bool responseVisible: false
    property bool responseRequired: false
    property string note: ""
    property bool noteIsError: false

    readonly property bool hasRequest: agent.flow !== null

    function submit(secret: string): void {
        if (agent.flow && agent.flow.isResponseRequired)
            agent.flow.submit(secret);
    }

    function cancel(): void {
        if (agent.flow)
            agent.flow.cancelAuthenticationRequest();
    }

    function clearNote(): void {
        root.note = "";
        root.noteIsError = false;
    }

    PolkitAgent {
        id: agent

        onAuthenticationRequestStarted: {
            const f = agent.flow;
            root.actionId = f ? f.actionId : "";
            root.message = f ? f.message : "";
            root.iconName = f ? f.iconName : "";
            root.clearNote();
            root.syncPrompt();
        }
    }

    function syncPrompt(): void {
        const f = agent.flow;
        root.inputPrompt = f ? f.inputPrompt : "";
        root.responseVisible = f ? f.responseVisible : false;
        root.responseRequired = f ? f.isResponseRequired : false;
    }

    Connections {
        target: agent.flow
        function onInputPromptChanged() {
            root.syncPrompt();
        }
        function onResponseVisibleChanged() {
            root.syncPrompt();
        }
        function onIsResponseRequiredChanged() {
            root.syncPrompt();
        }
        function onSupplementaryMessageChanged() {
            const f = agent.flow;
            root.note = f ? f.supplementaryMessage : "";
            root.noteIsError = f ? f.supplementaryIsError : false;
        }
        function onAuthenticationSucceeded() {
            root.clearNote();
        }
        function onAuthenticationFailed() {
            root.note = root.note !== "" ? root.note : "Authentication failed";
            root.noteIsError = true;
        }
    }
}
