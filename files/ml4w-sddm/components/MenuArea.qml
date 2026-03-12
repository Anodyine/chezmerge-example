import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: menuArea
    anchors.fill: parent

    Component {
        id: sessionMenuComponent

        IconButton {
            id: sessionButton
            property bool showLabel: Config.sessionDisplaySessionName
            preferredWidth: showLabel ? (Config.sessionButtonWidth === -1 ? undefined : Config.sessionButtonWidth) : Config.menuAreaButtonsSize
            height: Config.menuAreaButtonsSize * Config.generalScale
            iconSize: Config.sessionIconSize
            fontSize: Config.sessionFontSize
            enabled: loginScreen.state === "normal" || popup.visible
            active: popup.visible
            contentColor: Config.sessionContentColor
            activeContentColor: Config.sessionActiveContentColor
            borderRadius: Config.menuAreaButtonsBorderRadius
            borderSize: Config.sessionBorderSize
            backgroundColor: Config.sessionBackgroundColor
            backgroundOpacity: Config.sessionBackgroundOpacity
            activeBackgroundColor: Config.sessionBackgroundColor
            activeBackgroundOpacity: Config.sessionActiveBackgroundOpacity
            fontFamily: Config.menuAreaButtonsFontFamily
            activeFocusOnTab: true
            focus: false
            onClicked: {
                if (loginScreen.isSelectingUser) {
                    loginScreen.isSelectingUser = false;
                } else {
                    popup.open();
                }
            }
            tooltipText: "Change session"

            Popup {
                id: popup
                parent: sessionButton
                padding: Config.menuAreaPopupsPadding
                background: Rectangle {
                    color: Config.menuAreaPopupsBackgroundColor
                    opacity: Config.menuAreaPopupsBackgroundOpacity
                    radius: Config.menuAreaButtonsBorderRadius * Config.generalScale

                    Rectangle {
                        anchors.fill: parent
                        visible: Config.menuAreaPopupsBorderSize > 0
                        radius: parent.radius
                        color: "transparent"
                        border {
                            color: Config.menuAreaPopupsBorderColor
                            width: Config.menuAreaPopupsBorderSize * Config.generalScale
                        }
                    }
                }
                dim: true
                Overlay.modal: Rectangle {
                    color: "transparent"
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function(event) {
                            popup.close();
                            event.accepted = true;
                        }
                    }
                }

                onOpened: loginScreen.safeStateChange("popup")
                onClosed: loginScreen.safeStateChange("normal")

                modal: true
                popupType: Popup.Item
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                focus: visible

                SessionSelector {
                    focus: popup.focus
                    onSessionChanged: function(newSessionIndex, sessionIcon, sessionLabel) {
                        loginScreen.sessionIndex = newSessionIndex;
                        sessionButton.icon = sessionIcon;
                        sessionButton.label = sessionButton.showLabel ? sessionLabel : "";
                    }
                    onClose: {
                        popup.close();
                    }
                }

                Component.onCompleted: {
                    [x, y] = menuArea.calculatePopupPos(Config.sessionPopupDirection, Config.sessionPopupAlign, popup, sessionButton);
                }
            }
        }
    }

    Component {
        id: layoutMenuComponent

        IconButton {
            id: layoutButton

            property bool showLabel: Config.layoutDisplayLayoutName

            height: Config.menuAreaButtonsSize * Config.generalScale
            icon: Config.getIcon(Config.layoutIcon)
            active: popup.visible
            borderRadius: Config.menuAreaButtonsBorderRadius
            borderSize: Config.layoutBorderSize
            iconSize: Config.layoutIconSize
            fontSize: Config.layoutFontSize
            backgroundColor: Config.layoutBackgroundColor
            backgroundOpacity: Config.layoutBackgroundOpacity
            activeBackgroundColor: Config.layoutBackgroundColor
            activeBackgroundOpacity: Config.layoutActiveBackgroundOpacity
            contentColor: Config.layoutContentColor
            activeContentColor: Config.layoutActiveContentColor
            fontFamily: Config.menuAreaButtonsFontFamily
            activeFocusOnTab: true
            enabled: loginScreen.state === "normal" || popup.visible
            focus: false
            onClicked: {
                if (loginScreen.isSelectingUser) {
                    loginScreen.isSelectingUser = false;
                } else {
                    popup.open();
                }
            }
            tooltipText: "Change keyboard layout"
            label: showLabel ? (keyboard && keyboard.layouts && keyboard.currentLayout >= 0 && keyboard.currentLayout < keyboard.layouts.length ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : "") : ""

            Connections {
                target: loginScreen
                function onToggleLayoutPopup() {
                    if (popup.visible) {
                        popup.close();
                    } else {
                        popup.open();
                    }
                }
            }

            Component.onDestruction: {
                if (typeof connections !== "undefined") {
                    connections.target = null;
                }
            }

            Popup {
                id: popup
                parent: layoutButton
                padding: Config.menuAreaPopupsPadding
                background: Rectangle {
                    color: Config.menuAreaPopupsBackgroundColor
                    opacity: Config.menuAreaPopupsBackgroundOpacity
                    radius: Config.menuAreaButtonsBorderRadius * Config.generalScale

                    Rectangle {
                        anchors.fill: parent
                        visible: Config.menuAreaPopupsBorderSize > 0
                        radius: parent.radius
                        color: "transparent"
                        border {
                            color: Config.menuAreaPopupsBorderColor
                            width: Config.menuAreaPopupsBorderSize * Config.generalScale
                        }
                    }
                }
                focus: visible
                dim: true
                Overlay.modal: Rectangle {
                    color: "transparent"
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function(event) {
                            popup.close();
                            event.accepted = true;
                        }
                    }
                }

                onOpened: loginScreen.safeStateChange("popup")
                onClosed: loginScreen.safeStateChange("normal")

                modal: true
                popupType: Popup.Item
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                LayoutSelector {
                    focus: popup.focus
                    onLayoutChanged: function(index) {
                        layoutButton.label = showLabel ? (keyboard && keyboard.layouts && keyboard.currentLayout >= 0 && keyboard.currentLayout < keyboard.layouts.length ? keyboard.layouts[keyboard.currentLayout].shortName.toUpperCase() : "") : "";
                        VirtualKeyboardSettings.locale = Languages.getKBCodeFor(keyboard && keyboard.layouts && keyboard.currentLayout >= 0 && keyboard.currentLayout < keyboard.layouts.length ? keyboard.layouts[keyboard.currentLayout].shortName : "");
                    }
                    onClose: {
                        popup.close();
                    }
                }

                Component.onCompleted: {
                    [x, y] = menuArea.calculatePopupPos(Config.layoutPopupDirection, Config.layoutPopupAlign, popup, layoutButton);
                }
            }
        }
    }

    Component {
        id: keyboardMenuComponent

        IconButton {
            id: keyboardButton

            height: Config.menuAreaButtonsSize * Config.generalScale
            width: Config.menuAreaButtonsSize * Config.generalScale
            icon: Config.getIcon(Config.keyboardIcon)
            iconSize: Config.keyboardIconSize
            backgroundColor: Config.keyboardBackgroundColor
            backgroundOpacity: Config.keyboardBackgroundOpacity
            activeBackgroundColor: Config.keyboardBackgroundColor
            activeBackgroundOpacity: Config.keyboardActiveBackgroundOpacity
            contentColor: Config.keyboardContentColor
            activeContentColor: Config.keyboardActiveContentColor
            active: showKeyboard
            fontFamily: Config.menuAreaButtonsFontFamily
            borderRadius: Config.menuAreaButtonsBorderRadius
            borderSize: Config.keyboardBorderSize
            enabled: loginScreen.showKeyboard || loginScreen.state === "normal"
            activeFocusOnTab: true
            focus: false
            onClicked: {
                loginScreen.showKeyboard = !loginScreen.showKeyboard;
            }
            tooltipText: "Toggle virtual keyboard"
        }
    }

    Component {
        id: powerMenuComponent

        IconButton {
            id: powerButton

            height: Config.menuAreaButtonsSize * Config.generalScale
            width: Config.menuAreaButtonsSize * Config.generalScale
            icon: Config.getIcon(Config.powerIcon)
            iconSize: Config.powerIconSize
            contentColor: Config.powerContentColor
            activeContentColor: Config.powerActiveContentColor
            fontFamily: Config.menuAreaButtonsFontFamily
            active: popup.visible
            borderRadius: Config.menuAreaButtonsBorderRadius
            borderSize: Config.powerBorderSize
            backgroundColor: Config.powerBackgroundColor
            backgroundOpacity: Config.powerBackgroundOpacity
            activeBackgroundColor: Config.powerBackgroundColor
            activeBackgroundOpacity: Config.powerActiveBackgroundOpacity
            enabled: loginScreen.state === "normal" || popup.visible
            activeFocusOnTab: true
            focus: false
            onClicked: {
                popup.open();
            }
            tooltipText: "Power options"

            Popup {
                id: popup
                parent: powerButton
                background: Rectangle {
                    color: Config.menuAreaPopupsBackgroundColor
                    opacity: Config.menuAreaPopupsBackgroundOpacity
                    radius: Config.menuAreaButtonsBorderRadius * Config.generalScale

                    Rectangle {
                        anchors.fill: parent
                        visible: Config.menuAreaPopupsBorderSize > 0
                        radius: parent.radius
                        color: "transparent"
                        border {
                            color: Config.menuAreaPopupsBorderColor
                            width: Config.menuAreaPopupsBorderSize * Config.generalScale
                        }
                    }
                }
                dim: true
                padding: Config.menuAreaPopupsPadding
                Overlay.modal: Rectangle {
                    color: "transparent"
                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: function(event) {
                            popup.close();
                            event.accepted = true;
                        }
                    }
                }

                onOpened: loginScreen.safeStateChange("popup")
                onClosed: loginScreen.safeStateChange("normal")

                modal: true
                popupType: Popup.Item
                closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
                focus: visible

                PowerMenu {
                    focus: popup.focus
                    onClose: {
                        popup.close();
                    }
                }

                Component.onCompleted: {
                    [x, y] = menuArea.calculatePopupPos(Config.powerPopupDirection, Config.powerPopupAlign, popup, powerButton);
                }
            }
        }
    }

    Row {
        id: topLeftButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            top: parent.top
            left: parent.left
            topMargin: Config.menuAreaButtonsMarginTop
            leftMargin: Config.menuAreaButtonsMarginLeft
        }
    }

    Row {
        id: topCenterButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Config.menuAreaButtonsMarginTop
        }
    }

    Row {
        id: topRightButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            top: parent.top
            right: parent.right
            topMargin: Config.menuAreaButtonsMarginTop
            rightMargin: Config.menuAreaButtonsMarginRight
        }
    }

    Column {
        id: centerLeftButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
            leftMargin: Config.menuAreaButtonsMarginLeft
        }
    }

    Column {
        id: centerRightButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            right: parent.right
            verticalCenter: parent.verticalCenter
            rightMargin: Config.menuAreaButtonsMarginRight
        }
    }

    Row {
        id: bottomLeftButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            bottom: parent.bottom
            left: parent.left
            bottomMargin: Config.menuAreaButtonsMarginBottom
            leftMargin: Config.menuAreaButtonsMarginLeft
        }
    }

    Row {
        id: bottomCenterButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
            bottomMargin: Config.menuAreaButtonsMarginBottom
        }
    }

    Row {
        id: bottomRightButtons

        height: childrenRect.height
        width: childrenRect.width
        spacing: Config.menuAreaButtonsSpacing

        anchors {
            bottom: parent.bottom
            right: parent.right
            bottomMargin: Config.menuAreaButtonsMarginBottom
            rightMargin: Config.menuAreaButtonsMarginRight
        }
    }

    Item {
        id: bottomLeftBackdrop
        z: -1
        visible: bottomLeftButtons.width > 0 && bottomLeftButtons.height > 0
        x: bottomLeftButtons.x - 18
        y: bottomLeftButtons.y - 12
        width: bottomLeftButtons.width + 36
        height: bottomLeftButtons.height + 24
        clip: true

        ShaderEffectSource {
            anchors.fill: parent
            sourceItem: loginScreen.backgroundSource
            live: true
            hideSource: false
            sourceRect: Qt.rect(bottomLeftBackdrop.x, bottomLeftBackdrop.y, bottomLeftBackdrop.width, bottomLeftBackdrop.height)
        }

        MultiEffect {
            anchors.fill: parent
            source: parent.children[0]
            blurEnabled: true
            blurMax: 48
            blur: 1.0
            brightness: -0.04
            saturation: -0.5
        }

        Item {
            anchors.fill: parent
            anchors.margins: 2
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#575b75"
                opacity: 0.50
            }

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#575b75"
                opacity: 0.22
            }
        }

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.clearRect(0, 0, width, height);
                var lineWidth = 2;
                var radius = 18;
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

    Item {
        id: bottomCenterBackdrop
        z: -1
        visible: bottomCenterButtons.width > 0 && bottomCenterButtons.height > 0
        x: bottomCenterButtons.x - 18
        y: bottomCenterButtons.y - 12
        width: bottomCenterButtons.width + 36
        height: bottomCenterButtons.height + 24
        clip: true

        ShaderEffectSource {
            anchors.fill: parent
            sourceItem: loginScreen.backgroundSource
            live: true
            hideSource: false
            sourceRect: Qt.rect(bottomCenterBackdrop.x, bottomCenterBackdrop.y, bottomCenterBackdrop.width, bottomCenterBackdrop.height)
        }

        MultiEffect {
            anchors.fill: parent
            source: parent.children[0]
            blurEnabled: true
            blurMax: 48
            blur: 1.0
            brightness: -0.04
            saturation: -0.5
        }

        Item {
            anchors.fill: parent
            anchors.margins: 2
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#575b75"
                opacity: 0.50
            }

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#575b75"
                opacity: 0.22
            }
        }

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.clearRect(0, 0, width, height);
                var lineWidth = 2;
                var radius = 18;
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

    Item {
        id: bottomRightBackdrop
        z: -1
        visible: bottomRightButtons.width > 0 && bottomRightButtons.height > 0
        x: bottomRightButtons.x - 18
        y: bottomRightButtons.y - 12
        width: bottomRightButtons.width + 36
        height: bottomRightButtons.height + 24
        clip: true

        ShaderEffectSource {
            anchors.fill: parent
            sourceItem: loginScreen.backgroundSource
            live: true
            hideSource: false
            sourceRect: Qt.rect(bottomRightBackdrop.x, bottomRightBackdrop.y, bottomRightBackdrop.width, bottomRightBackdrop.height)
        }

        MultiEffect {
            anchors.fill: parent
            source: parent.children[0]
            blurEnabled: true
            blurMax: 48
            blur: 1.0
            brightness: -0.04
            saturation: -0.5
        }

        Item {
            anchors.fill: parent
            anchors.margins: 2
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#575b75"
                opacity: 0.50
            }

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: "#575b75"
                opacity: 0.22
            }
        }

        Canvas {
            anchors.fill: parent
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                ctx.clearRect(0, 0, width, height);
                var lineWidth = 2;
                var radius = 18;
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

    property var createdObjects: []

    Component.onCompleted: {
        var menus = Config.sortMenuButtons();

        for (var i = 0; i < menus.length; i++) {
            var pos;
            switch (menus[i].position) {
            case "top-left":
                pos = topLeftButtons;
                break;
            case "top-center":
                pos = topCenterButtons;
                break;
            case "top-right":
                pos = topRightButtons;
                break;
            case "center-left":
                pos = centerLeftButtons;
                break;
            case "center-right":
                pos = centerRightButtons;
                break;
            case "bottom-left":
                pos = bottomLeftButtons;
                break;
            case "bottom-center":
                pos = bottomCenterButtons;
                break;
            case "bottom-right":
                pos = bottomRightButtons;
                break;
            }

            var createdObject;
            if (menus[i].name === "session")
                createdObject = sessionMenuComponent.createObject(pos, {});
            else if (menus[i].name === "layout")
                createdObject = layoutMenuComponent.createObject(pos, {});
            else if (menus[i].name === "keyboard")
                createdObject = keyboardMenuComponent.createObject(pos, {});
            else if (menus[i].name === "power")
                createdObject = powerMenuComponent.createObject(pos, {});

            if (createdObject) {
                createdObjects.push(createdObject);
            }
        }
    }

    Component.onDestruction: {
        for (var i = 0; i < createdObjects.length; i++) {
            if (createdObjects[i]) {
                createdObjects[i].destroy();
            }
        }
        createdObjects = [];
    }

    function calculatePopupPos(direction, align, popup, button) {
        var popupMargin = Config.menuAreaPopupsMargin;
        var x = 0;
        var y = 0;

        if (direction === "up") {
            y = -popup.height - popupMargin;
            if (align === "start") {
                x = 0;
            } else if (align === "end") {
                x = -popup.width + button.width;
            } else {
                x = (button.width - popup.width) / 2;
            }
        } else if (direction === "down") {
            y = button.height + popupMargin;
            if (align === "start") {
                x = 0;
            } else if (align === "end") {
                x = -popup.width + button.width;
            } else {
                x = (button.width - popup.width) / 2;
            }
        } else if (direction === "left") {
            x = -popup.width - popupMargin;
            if (align === "start") {
                y = 0;
            } else if (align === "end") {
                y = -popup.height + button.height;
            } else {
                y = (button.height - popup.height) / 2;
            }
        } else {
            x = button.width + popupMargin;
            if (align === "start") {
                y = 0;
            } else if (align === "end") {
                y = -popup.height + button.height;
            } else {
                y = (button.height - popup.height) / 2;
            }
        }
        return [x, y];
    }
}
