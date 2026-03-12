import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import SddmComponents

Item {
    id: loginScreen
    signal close
    signal toggleLayoutPopup

    state: "normal"
    property bool stateChanging: false
    property var backgroundSource: null

    function safeStateChange(newState) {
        if (!stateChanging) {
            stateChanging = true;
            state = newState;
            stateChanging = false;
        }
    }
    onStateChanged: {
        if (state === "normal") {
            resetFocus();
        }
    }

    readonly property alias password: password
    readonly property alias loginButton: loginButton
    readonly property alias loginContainer: loginContainer

    property bool showKeyboard: !Config.virtualKeyboardStartHidden

    property bool foundUsers: userModel.count > 0

    property int sessionIndex: 0
    property int userIndex: 0
    property string userName: ""
    property string userRealName: ""
    property string userIcon: ""
    property bool userNeedsPassword: true

    function login() {
        var user = foundUsers ? userName : userInput.text;
        if (user && user !== "") {
            safeStateChange("authenticating");
            sddm.login(user, password.text, sessionIndex);
        } else {
            loginMessage.warn(textConstants.promptUser || "Enter your user!", "error");
        }
    }
    Connections {
        function onLoginSucceeded() {
            loginContainer.scale = 0.0;
        }
        function onLoginFailed() {
            safeStateChange("normal");
            loginMessage.warn(textConstants.loginFailed || "Login failed", "error");
            password.text = "";
        }
        function onInformationMessage(message) {
            loginMessage.warn(message, "error");
        }
        target: sddm
    }

    Component.onDestruction: {
        if (typeof connections !== "undefined") {
            connections.target = null;
        }
    }

    function updateCapsLock() {
        if (root.capsLockOn && loginScreen.state !== "authenticating") {
            loginMessage.warn(textConstants.capslockWarning || "Caps Lock is on", "warning");
        } else {
            loginMessage.clear();
        }
    }

    function resetFocus() {
        if (!loginScreen.foundUsers) {
            userInput.input.forceActiveFocus();
        } else {
            if (loginScreen.userNeedsPassword) {
                password.input.forceActiveFocus();
            } else {
                loginButton.forceActiveFocus();
            }
        }
    }

    Item {
        id: loginContainer
        width: Config.loginAreaPosition === "left" || Config.loginAreaPosition === "right" ? (Config.avatarActiveSize + Config.usernameMargin + loginArea.width) : userSelector.width
        height: childrenRect.height
        scale: 0.5

        Behavior on scale {
            enabled: Config.enableAnimations
            NumberAnimation {
                duration: 200
            }
        }

        Component.onCompleted: {
            if (Config.loginAreaPosition === "left") {
                anchors.verticalCenter = parent.verticalCenter;
                if (Config.loginAreaMargin === -1) {
                    anchors.horizontalCenter = parent.horizontalCenter;
                } else {
                    anchors.left = parent.left;
                    anchors.leftMargin = Config.loginAreaMargin;
                }
            } else if (Config.loginAreaPosition === "right") {
                anchors.verticalCenter = parent.verticalCenter;
                if (Config.loginAreaMargin === -1) {
                    anchors.horizontalCenter = parent.horizontalCenter;
                } else {
                    anchors.right = parent.right;
                    anchors.rightMargin = Config.loginAreaMargin;
                }
            } else {
                anchors.horizontalCenter = parent.horizontalCenter;
                if (Config.loginAreaMargin === -1) {
                    anchors.verticalCenter = parent.verticalCenter;
                } else {
                    anchors.top = parent.top;
                    anchors.topMargin = Config.loginAreaMargin;
                }
            }

            if (!loginScreen.foundUsers) {
                userSelector.visible = false;
                noUsersLoginArea.visible = true;
            }
        }

        Item {
            id: noUsersLoginArea
            width: Config.passwordInputWidth * Config.generalScale + (loginButton.visible ? Config.passwordInputHeight * Config.generalScale + Config.loginButtonMarginLeft : 0)
            height: childrenRect.height
            visible: false

            Text {
                id: noUsersMessage
                anchors {
                    top: parent.top
                }
                width: parent.width
                text: "SDDM could not find any user. Type your username below:"
                wrapMode: Text.Wrap
                horizontalAlignment: {
                    if (Config.loginAreaPosition === "left") {
                        horizontalAlignment: Text.AlignLeft;
                    } else if (Config.loginAreaPosition === "right") {
                        horizontalAlignment: Text.AlignRight;
                    } else {
                        horizontalAlignment: Text.AlignHCenter;
                    }
                }
                color: "#eaf2f1"
                font.pixelSize: Math.max(8, Config.passwordInputFontSize * Config.generalScale)
                font.family: Config.passwordInputFontFamily
            }

            Input {
                id: userInput
                anchors {
                    top: noUsersMessage.bottom
                    topMargin: Config.usernameMargin
                }
                width: parent.width
                icon: Config.getIcon("user-default")
                placeholder: (textConstants && textConstants.userName) ? textConstants.userName : "Password"
                isPassword: false
                splitBorderRadius: false
                enabled: loginScreen.state !== "authenticating"
                onAccepted: {
                    loginScreen.login();
                }
            }

            Component.onCompleted: {
                anchors.bottom = loginLayout.top;
                if (Config.loginAreaPosition === "left") {
                    anchors.left = parent.left;
                } else if (Config.loginAreaPosition === "right") {
                    anchors.right = parent.right;
                } else {
                    anchors.horizontalCenter = parent.horizontalCenter;
                }
            }
        }

        UserSelector {
            id: userSelector
            listUsers: loginScreen.state === "selectingUser"
            enabled: loginScreen.state !== "authenticating"
            visible: true
            activeFocusOnTab: true
            orientation: Config.loginAreaPosition === "left" || Config.loginAreaPosition === "right" ? "vertical" : "horizontal"
            width: orientation === "horizontal" ? loginScreen.width - Config.loginAreaMargin * 2 : (Config.avatarActiveSize * Config.generalScale)
            height: orientation === "horizontal" ? (Config.avatarActiveSize * Config.generalScale) : loginScreen.height - Config.loginAreaMargin * 2
            onOpenUserList: {
                safeStateChange("selectingUser");
            }
            onCloseUserList: {
                safeStateChange("normal");
                loginScreen.resetFocus();
            }
            onUserChanged: (index, name, realName, icon, needsPassword) => {
                if (loginScreen.foundUsers) {
                    loginScreen.userIndex = index;
                    loginScreen.userName = name;
                    loginScreen.userRealName = realName;
                    loginScreen.userIcon = icon;
                    loginScreen.userNeedsPassword = needsPassword;
                }
            }

            Component.onCompleted: {
                anchors.top = parent.top;
                if (Config.loginAreaPosition === "left") {
                    anchors.left = parent.left;
                } else if (Config.loginAreaPosition === "right") {
                    anchors.right = parent.right;
                }
            }
        }

        Item {
            id: loginLayout
            height: activeUserName.height + Config.passwordInputMarginTop + loginArea.height
            width: loginArea.width > activeUserName.width ? loginArea.width : activeUserName.width

            Component.onCompleted: {
                if (Config.loginAreaPosition === "left") {
                    anchors.verticalCenter = parent.verticalCenter;
                    if (userSelector.visible) {
                        anchors.left = userSelector.right;
                        anchors.leftMargin = Config.usernameMargin;
                    } else {
                        anchors.left = parent.left;
                    }
                } else if (Config.loginAreaPosition === "right") {
                    anchors.verticalCenter = parent.verticalCenter;
                    if (userSelector.visible) {
                        anchors.right = userSelector.left;
                        anchors.rightMargin = Config.usernameMargin;
                    } else {
                        anchors.right = parent.right;
                    }
                } else {
                    anchors.top = userSelector.bottom;
                    anchors.topMargin = Config.usernameMargin;
                    anchors.horizontalCenter = parent.horizontalCenter;
                }
            }

            Text {
                id: activeUserName
                font.family: Config.usernameFontFamily
                font.weight: Config.usernameFontWeight
                font.pixelSize: Config.usernameFontSize * Config.generalScale
                color: "#eaf2f1"
                text: loginScreen.userRealName || loginScreen.userName || ""
                visible: loginScreen.foundUsers

                Component.onCompleted: {
                    anchors.top = parent.top;
                    if (Config.loginAreaPosition === "left") {
                        anchors.left = parent.left;
                    } else if (Config.loginAreaPosition === "right") {
                        anchors.right = parent.right;
                    } else {
                        anchors.horizontalCenter = parent.horizontalCenter;
                    }
                }
            }

            RowLayout {
                id: loginArea
                height: Config.passwordInputHeight * Config.generalScale
                spacing: Config.loginButtonMarginLeft
                visible: loginScreen.state !== "authenticating"

                Component.onCompleted: {
                    anchors.top = activeUserName.bottom;
                    anchors.topMargin = Config.passwordInputMarginTop;
                    if (Config.loginAreaPosition === "left") {
                        anchors.left = parent.left;
                    } else if (Config.loginAreaPosition === "right") {
                        anchors.right = parent.right;
                    } else {
                        anchors.horizontalCenter = parent.horizontalCenter;
                    }
                }

                Input {
                    id: password
                    Layout.alignment: Qt.AlignHCenter
                    enabled: loginScreen.state === "normal"
                    visible: loginScreen.userNeedsPassword || !loginScreen.foundUsers
                    icon: Config.getIcon(Config.passwordInputIcon)
                    placeholder: (textConstants && textConstants.password) ? textConstants.password : "Password"
                    isPassword: true
                    splitBorderRadius: true
                    onAccepted: {
                        loginScreen.login();
                    }
                }

                IconButton {
                    id: loginButton
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: width
                    height: password.height
                    visible: !Config.loginButtonHideIfNotNeeded || !loginScreen.userNeedsPassword
                    enabled: loginScreen.state !== "selectingUser" && loginScreen.state !== "authenticating"
                    activeFocusOnTab: true
                    icon: Config.getIcon(Config.loginButtonIcon)
                    label: textConstants.login ? textConstants.login : "Login"
                    showLabel: Config.loginButtonShowTextIfNoPassword && !loginScreen.userNeedsPassword
                    tooltipText: !Config.tooltipsDisableLoginButton && (!Config.loginButtonShowTextIfNoPassword || loginScreen.userNeedsPassword) ? (textConstants.login || "Login") : ""
                    iconSize: Config.loginButtonIconSize
                    fontFamily: Config.loginButtonFontFamily
                    fontSize: Config.loginButtonFontSize
                    fontWeight: Config.loginButtonFontWeight
                    contentColor: "#eaf2f1"
                    activeContentColor: "#eaf2f1"
                    backgroundColor: Config.loginButtonBackgroundColor
                    backgroundOpacity: Config.loginButtonBackgroundOpacity
                    activeBackgroundColor: Config.loginButtonActiveBackgroundColor
                    activeBackgroundOpacity: Config.loginButtonActiveBackgroundOpacity
                    borderSize: Config.loginButtonBorderSize
                    borderColor: Config.loginButtonBorderColor
                    borderRadiusLeft: password.visible ? Config.loginButtonBorderRadiusLeft : Config.loginButtonBorderRadiusRight
                    borderRadiusRight: Config.loginButtonBorderRadiusRight
                    onClicked: {
                        loginScreen.login();
                    }

                    Behavior on x {
                        enabled: Config.enableAnimations
                        NumberAnimation {
                            duration: 150
                        }
                    }
                }
            }

            Spinner {
                id: spinner
                visible: loginScreen.state === "authenticating"
                opacity: visible ? 1.0 : 0.0

                Component.onCompleted: {
                    anchors.top = activeUserName.bottom;
                    anchors.topMargin = Config.passwordInputMarginTop;
                    if (Config.loginAreaPosition === "left") {
                        anchors.left = parent.left;
                    } else if (Config.loginAreaPosition === "right") {
                        anchors.right = parent.right;
                    } else {
                        anchors.horizontalCenter = parent.horizontalCenter;
                    }
                }
            }

            Text {
                id: loginMessage
                property bool capslockWarning: false
                font.pixelSize: Config.warningMessageFontSize * Config.generalScale
                font.family: Config.warningMessageFontFamily
                font.weight: Config.warningMessageFontWeight
                color: "#eaf2f1"
                visible: text !== "" && loginScreen.state !== "authenticating" && (capslockWarning ? loginScreen.userNeedsPassword : true)
                opacity: visible ? 1.0 : 0.0
                anchors.top: loginArea.bottom
                anchors.topMargin: visible ? Config.warningMessageMarginTop : 0

                Component.onCompleted: {
                    if (root.capsLockOn)
                        loginMessage.warn(textConstants.capslockWarning || "Caps Lock is on", "warning");

                    if (Config.loginAreaPosition === "left") {
                        anchors.left = parent.left;
                    } else if (Config.loginAreaPosition === "right") {
                        anchors.right = parent.right;
                    } else {
                        anchors.horizontalCenter = parent.horizontalCenter;
                    }
                }

                Behavior on anchors.topMargin {
                    enabled: Config.enableAnimations
                    NumberAnimation {
                        duration: 150
                    }
                }
                Behavior on opacity {
                    enabled: Config.enableAnimations
                    NumberAnimation {
                        duration: 150
                    }
                }

                function warn(message, type) {
                    clear();
                    text = message;
                    color = "#eaf2f1";
                    if (message === (textConstants.capslockWarning || "Caps Lock is on"))
                        capslockWarning = true;
                }

                function clear() {
                    text = "";
                    capslockWarning = false;
                }
            }
        }
    }

    Item {
        id: loginBackdrop
        z: -1
        property int horizontalPadding: 63
        property int topPadding: 73
        property int bottomPadding: 63
        property real minimumWidth: 560 * Config.generalScale
        property real contentWidth: Config.loginAreaPosition === "left" || Config.loginAreaPosition === "right"
            ? loginContainer.width
            : Math.max(
                Config.avatarActiveSize * Config.generalScale,
                loginLayout.width,
                noUsersLoginArea.visible ? noUsersLoginArea.width : 0
            )
        property real baseWidth: contentWidth + (horizontalPadding * 2)
        property real extraWidthOffset: Math.max(0, minimumWidth - baseWidth) / 2
        visible: loginScreen.opacity > 0 && loginContainer.visible
        x: (Config.loginAreaPosition === "left" || Config.loginAreaPosition === "right"
            ? loginContainer.x
            : loginContainer.x + ((loginContainer.width - contentWidth) / 2)) - horizontalPadding - extraWidthOffset
        y: loginContainer.y - topPadding
        width: Math.max(baseWidth, minimumWidth)
        height: loginContainer.height + topPadding + bottomPadding
        clip: true

        ShaderEffectSource {
            id: loginBackdropSource
            anchors.fill: parent
            sourceItem: loginScreen.backgroundSource
            live: true
            hideSource: false
            sourceRect: Qt.rect(loginBackdrop.x, loginBackdrop.y, loginBackdrop.width, loginBackdrop.height)
        }

        MultiEffect {
            anchors.fill: panelInner
            source: loginBackdropSource
            autoPaddingEnabled: false
            blurEnabled: true
            blurMax: 48
            blur: 1.0
            brightness: -0.04
            saturation: -0.5
        }

        Item {
            id: panelInner
            anchors.fill: parent
            anchors.margins: 2
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: 22
                color: "#333751"
                opacity: 0.45
            }
        }

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.clearRect(0, 0, width, height);

                var lineWidth = 2;
                var radius = 24;
                var halfLine = lineWidth / 2;
                var w = width - lineWidth;
                var h = height - lineWidth;
                var x = halfLine;
                var y = halfLine;

                var gradient = ctx.createLinearGradient(0, 0, 0, height);
                gradient.addColorStop(0, "#dbab27");
                gradient.addColorStop(1, "#382e1f");

                ctx.beginPath();
                ctx.moveTo(x + radius, y);
                ctx.lineTo(x + w - radius, y);
                ctx.quadraticCurveTo(x + w, y, x + w, y + radius);
                ctx.lineTo(x + w, y + h - radius);
                ctx.quadraticCurveTo(x + w, y + h, x + w - radius, y + h);
                ctx.lineTo(x + radius, y + h);
                ctx.quadraticCurveTo(x, y + h, x, y + h - radius);
                ctx.lineTo(x, y + radius);
                ctx.quadraticCurveTo(x, y, x + radius, y);
                ctx.closePath();

                ctx.lineWidth = lineWidth;
                ctx.strokeStyle = gradient;
                ctx.stroke();
            }
        }
    }

    MenuArea {}
    CVKeyboard {}

    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            if (loginScreen.state === "authenticating") {
                event.accepted = false;
                return;
            }
            if (Config.lockScreenDisplay) {
                loginScreen.close();
            }
            password.text = "";
        } else if (event.key === Qt.Key_CapsLock) {
            root.capsLockOn = !root.capsLockOn;
        }
        event.accepted = true;
    }

    MouseArea {
        id: closeUserSelectorMouseArea
        z: -1
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (loginScreen.state === "selectingUser") {
                safeStateChange("normal");
            }
        }
        onWheel: event => {
            if (loginScreen.state === "selectingUser") {
                if (event.angleDelta.y < 0) {
                    userSelector.nextUser();
                } else {
                    userSelector.prevUser();
                }
            }
        }
    }
}
