import QtQuick
import QtQuick.VirtualKeyboard
import QtQuick.VirtualKeyboard.Settings

InputPanel {
    id: inputPanel

    property real edgeMargin: 24 * Config.generalScale
    property real panelGap: 24 * Config.generalScale
    property real reservedBottomSpace: (Config.menuAreaButtonsMarginBottom + (Config.menuAreaButtonsSize * Config.generalScale) + panelGap)
    property string pos: Config.virtualKeyboardPosition
    property point loginLayoutPosition: loginContainer && loginLayout ? loginContainer.mapToGlobal(loginLayout.x, loginLayout.y) : Qt.point(0, 0)
    property bool vKeyboardMoved: false

    width: Math.min(loginScreen && loginScreen.width ? loginScreen.width * 0.6 : 960, 760) * Config.virtualKeyboardScale * Config.generalScale
    active: Qt.inputMethod.visible
    visible: loginScreen && loginScreen.showKeyboard && loginScreen.state !== "selectingUser" && loginScreen.state !== "authenticating"
    opacity: visible ? 1.0 : 0.0
    externalLanguageSwitchEnabled: true
    onExternalLanguageSwitch: {
        if (loginScreen && loginScreen.toggleLayoutPopup) {
            loginScreen.toggleLayoutPopup();
        }
    }

    function centeredX() {
        return (parent.width - inputPanel.width) / 2;
    }

    function maxBottomY() {
        return parent.height - inputPanel.height - reservedBottomSpace;
    }

    function loginAnchorY() {
        var baseTarget = loginLayoutPosition.y + (loginLayout ? loginLayout.height : 0) + (loginMessage && loginMessage.visible ? (loginMessage.height + Config.warningMessageMarginTop) : 0) + panelGap;
        if (loginBackdrop) {
            baseTarget = Math.max(baseTarget, loginBackdrop.y + loginBackdrop.height + panelGap);
        }
        return Math.min(baseTarget, maxBottomY());
    }

    Component.onCompleted: {
        VirtualKeyboardSettings.styleName = "vkeyboardStyle";
        VirtualKeyboardSettings.layout = "symbols";
    }

    x: {
        if (pos === "top" || pos === "bottom") {
            return centeredX();
        }
        if (pos === "left") {
            return edgeMargin + Config.menuAreaButtonsMarginLeft;
        }
        if (pos === "right") {
            return parent.width - inputPanel.width - edgeMargin - Config.menuAreaButtonsMarginRight;
        }
        if (Config.loginAreaPosition === "left" && Config.loginAreaMargin !== -1) {
            return Math.min(Config.loginAreaMargin, parent.width - inputPanel.width - edgeMargin);
        }
        if (Config.loginAreaPosition === "right" && Config.loginAreaMargin !== -1) {
            return Math.max(edgeMargin, parent.width - inputPanel.width - Config.loginAreaMargin);
        }
        return centeredX();
    }

    y: {
        if (pos === "top") {
            return Config.menuAreaButtonsMarginTop + panelGap;
        }
        if (pos === "bottom") {
            return maxBottomY();
        }
        if (pos === "left" || pos === "right") {
            return (parent.height - inputPanel.height) / 2;
        }
        if (!vKeyboardMoved) {
            return loginAnchorY();
        }
        return y;
    }

    Behavior on y {
        enabled: Config.enableAnimations
        NumberAnimation {
            duration: 150
        }
    }

    Behavior on x {
        enabled: Config.enableAnimations
        NumberAnimation {
            duration: 150
        }
    }

    Behavior on opacity {
        enabled: Config.enableAnimations
        NumberAnimation {
            duration: 250
        }
    }

    MouseArea {
        id: vKeyboardDragArea
        property point initialPosition: Qt.point(-1, -1)
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: loginScreen && loginScreen.userNeedsPassword ? Qt.ArrowCursor : Qt.ForbiddenCursor
        drag.target: inputPanel
        acceptedButtons: Qt.MiddleButton
        onPressed: function(event) {
            cursorShape = Qt.ClosedHandCursor;
            initialPosition = Qt.point(event.x, event.y);
        }
        onReleased: function(event) {
            cursorShape = loginScreen && loginScreen.userNeedsPassword ? Qt.ArrowCursor : Qt.ForbiddenCursor;
            if (initialPosition !== Qt.point(event.x, event.y) && !inputPanel.vKeyboardMoved) {
                inputPanel.vKeyboardMoved = true;
            }
        }
    }
}
