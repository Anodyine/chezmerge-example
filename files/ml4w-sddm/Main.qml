import "."
import QtQuick
import SddmComponents
import QtQuick.Effects
import QtMultimedia
import "components"

Item {
    id: root
    state: Config.lockScreenDisplay ? "lockState" : "loginState"

    TextConstants {
        id: textConstants
    }

    property bool capsLockOn: false
    Component.onCompleted: {
        if (keyboard)
            capsLockOn = keyboard.capsLock;
    }
    onCapsLockOnChanged: {
        loginScreen.updateCapsLock();
    }

    states: [
        State {
            name: "lockState"
            PropertyChanges {
                target: lockScreen
                opacity: 1.0
            }
            PropertyChanges {
                target: loginScreen
                opacity: 0.0
            }
            PropertyChanges {
                target: loginScreen.loginContainer
                scale: 0.5
            }
            PropertyChanges {
                target: backgroundEffect
                blurMax: Config.lockScreenBlur
                brightness: Config.lockScreenBrightness
                saturation: Config.lockScreenSaturation
            }
        },
        State {
            name: "loginState"
            PropertyChanges {
                target: lockScreen
                opacity: 0.0
            }
            PropertyChanges {
                target: loginScreen
                opacity: 1.0
            }
            PropertyChanges {
                target: loginScreen.loginContainer
                scale: 1.0
            }
            PropertyChanges {
                target: backgroundEffect
                blurMax: Config.loginScreenBlur
                brightness: Config.loginScreenBrightness
                saturation: Config.loginScreenSaturation
            }
        }
    ]
    transitions: Transition {
        enabled: Config.enableAnimations
        PropertyAnimation {
            duration: 150
            properties: "opacity"
        }
        PropertyAnimation {
            duration: 400
            properties: "blurMax"
        }
        PropertyAnimation {
            duration: 400
            properties: "brightness"
        }
        PropertyAnimation {
            duration: 400
            properties: "saturation"
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height

        Image {
            id: backgroundImage
            property string tsource: root.state === "lockState" ? Config.lockScreenBackground : Config.loginScreenBackground

            property bool isVideo: {
                if (!tsource || tsource.toString().length === 0)
                    return false;
                var parts = tsource.toString().split(".");
                if (parts.length === 0)
                    return false;
                var ext = parts[parts.length - 1];
                return ["avi", "mp4", "mov", "mkv", "m4v", "webm"].indexOf(ext) !== -1;
            }
            property bool displayColor: root.state === "lockState" && Config.lockScreenUseBackgroundColor || root.state === "loginState" && Config.loginScreenUseBackgroundColor
            property string placeholder: Config.animatedBackgroundPlaceholder

            anchors.fill: parent
            source: !isVideo ? "backgrounds/" + tsource : ""
            cache: true
            mipmap: true
            fillMode: {
                if (Config.backgroundFillMode === "stretch") {
                    return Image.Stretch;
                } else if (Config.backgroundFillMode === "fit") {
                    return Image.PreserveAspectFit;
                } else {
                    return Image.PreserveAspectCrop;
                }
            }

            function updateVideo() {
                if (isVideo && tsource.toString().length > 0) {
                    backgroundVideo.source = Qt.resolvedUrl("backgrounds/" + tsource);

                    if (placeholder.length > 0)
                        source = "backgrounds/" + placeholder;
                }
            }

            onSourceChanged: {
                updateVideo();
            }
            Component.onCompleted: {
                updateVideo();
            }
            onStatusChanged: {
                if (status === Image.Error) {
                    if (source !== "backgrounds/default.jpg" && source !== "") {
                        source = "backgrounds/default.jpg";
                    } else if (source === "backgrounds/default.jpg") {
                        displayColor = true;
                    }
                }
            }

            Rectangle {
                id: backgroundColor
                anchors.fill: parent
                anchors.margins: 0
                color: root.state === "lockState" && Config.lockScreenUseBackgroundColor ? Config.lockScreenBackgroundColor : root.state === "loginState" && Config.loginScreenUseBackgroundColor ? Config.loginScreenBackgroundColor : "black"
                visible: parent.displayColor || (backgroundVideo.visible && parent.placeholder.length === 0)
            }

            Video {
                id: backgroundVideo
                anchors.fill: parent
                visible: parent.isVideo && !parent.displayColor
                enabled: visible
                autoPlay: false
                loops: MediaPlayer.Infinite
                muted: true
                fillMode: {
                    if (Config.backgroundFillMode === "stretch") {
                        return VideoOutput.Stretch;
                    } else if (Config.backgroundFillMode === "fit") {
                        return VideoOutput.PreserveAspectFit;
                    } else {
                        return VideoOutput.PreserveAspectCrop;
                    }
                }

                onSourceChanged: {
                    if (source && source.toString().length > 0) {
                        backgroundVideo.play();
                    }
                }
                onErrorOccurred: function(error) {
                    if (error !== MediaPlayer.NoError && (!backgroundImage.placeholder || backgroundImage.placeholder.length === 0)) {
                        backgroundImage.displayColor = true;
                    }
                }
            }

            Component.onDestruction: {
                if (backgroundVideo) {
                    backgroundVideo.stop();
                    backgroundVideo.source = "";
                }
            }
        }
        MultiEffect {
            id: backgroundEffect
            source: backgroundImage
            anchors.fill: parent
            blurEnabled: backgroundImage.visible && blurMax > 0
            blur: blurMax > 0 ? 1.0 : 0.0
            autoPaddingEnabled: false
        }

        Item {
            id: screenContainer
            anchors.fill: parent
            anchors.top: parent.top

            LockScreen {
                id: lockScreen
                z: root.state === "lockState" ? 2 : 1
                anchors.fill: parent
                focus: root.state === "lockState"
                enabled: root.state === "lockState"
                backgroundSource: backgroundEffect
                onLoginRequested: {
                    root.state = "loginState";
                    loginScreen.resetFocus();
                }
            }
            LoginScreen {
                id: loginScreen
                z: root.state === "loginState" ? 2 : 1
                anchors.fill: parent
                enabled: root.state === "loginState"
                opacity: 0.0
                backgroundSource: backgroundEffect
                onClose: {
                    root.state = "lockState";
                }
            }
        }
    }
}
