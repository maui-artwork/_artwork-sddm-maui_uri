import QtQuick 2.0
import QtGraphicalEffects 1.0
import SddmComponents 2.0

Item {
    id: frame
    property int sessionIndex: sessionModel.lastIndex
    property string userName: userModel.lastUser
    property bool isProcessing: glowAnimation.running
    property alias input: passwdInput
    property alias button: loginButton

    Connections {
        target: sddm
        onLoginSucceeded: {
            glowAnimation.running = false
            Qt.quit()
        }
        onLoginFailed: {
            passwdInput.echoMode = TextInput.Normal
            passwdInput.text = textConstants.loginFailed
            passwdInput.focus = false
            passwdInput.color = "#e7b222"
            glowAnimation.running = false
        }
    }

    Item {
        id: loginItem
        anchors.centerIn: parent
        width: parent.width
        height: parent.height

        UserAvatar {
            id: userIconRec
            anchors {
                top: parent.top
                topMargin: parent.height / 4
                horizontalCenter: parent.horizontalCenter
            }
            width: 130
            height: 130
            source: userFrame.currentIconPath
            onClicked: {
                root.state = "stateUser"
                userFrame.focus = true
            }
        }

        Glow {
            id: avatarGlow
            anchors.fill: userIconRec
            radius: 0
            samples: 17
            color: "#99ffffff"
            source: userIconRec

            SequentialAnimation on radius {
                id: glowAnimation
                running: false
                alwaysRunToEnd: true
                loops: Animation.Infinite
                PropertyAnimation { to: 20 ; duration: 1000}
                PropertyAnimation { to: 0 ; duration: 1000}
            }
        }

        Text {
            id: userNameText
            anchors {
                top: userIconRec.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }

            text: userName
            color: textColor
            font.pointSize: 15
        }

        Rectangle {
            id: passwdInputRec
            visible: ! isProcessing
            anchors {
                top: userNameText.bottom
                topMargin: 10
                horizontalCenter: parent.horizontalCenter
            }
            width: 300
            height: 36
            radius: 3
            color: "#212121"
            
            Text {
                    id: passwordNotice
                    text: "Click your avatar, enter your password"
                    color: "#424242"
                    anchors {
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: 20
                    }
                    font.pointSize: 9
                }

            TextInput {
                id: passwdInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8 + 36
                clip: true
                focus: true
                color: textColor
                font.pointSize: 15
                selectByMouse: true
                selectionColor: "#a8d6ec"
                echoMode: TextInput.Password
                verticalAlignment: TextInput.AlignVCenter
                
                onFocusChanged: {
                    if (focus) {
                        color = textColor
                        echoMode = TextInput.Password
                        text = ""
                    }
                }
                onAccepted: {
                    glowAnimation.running = true
                    sddm.login(userNameText.text, passwdInput.text, sessionIndex)
                }
                KeyNavigation.backtab: {
                    if (sessionButton.visible) {
                        return sessionButton
                    }
                    else if (userButton.visible) {
                        return userButton
                    }
                    else {
                        return shutdownButton
                    }
                }
                KeyNavigation.tab: loginButton
                Timer {
                    interval: 200
                    running: true
                    onTriggered: passwdInput.forceActiveFocus()
                }
            }
            ImgButton {
                id: loginButton
                height: passwdInput.height
                width: height
                anchors {
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                }

                normalImg: "icons/login_normal.svg"
                hoverImg: "icons/login_hover.svg"
                pressImg: "icons/login_press.svg"
                onClicked: {
                    glowAnimation.running = true
                    sddm.login(userNameText.text, passwdInput.text, sessionIndex)
                }
                KeyNavigation.tab: shutdownButton
                KeyNavigation.backtab: passwdInput
            }
        }
    }
}
