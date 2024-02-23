
// Copyright Alexey Varfolomeev 2021 <varlesh@gmail.com>
import QtQuick 2.8
import QtQuick.Controls 1.1
import QtGraphicalEffects 1.0
import org.kde.plasma.workspace.components 2.0 as PW

import "../components"


Item {

    Rectangle {
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        id: panel
        color: "#111928"
        radius: 20
        height: 34
        opacity: 0.7
        border.width: 0.5
        // border.color: "#ffffff1f"
        border.color: "#2f3643"
        // border.color: "#4a5059"
    }

    ShaderEffectSource {
         id: blurArea
         sourceItem: wallpaper
         width: panel.width
         height: panel.height
         anchors.centerIn: panel
         sourceRect: Qt.rect(x,y,width,height)
         visible: false
     }

    FastBlur {
        anchors.fill: panel
        source: blurArea
        radius: 100
        z:-1
        property bool rounded: true
        layer.enabled: rounded
        layer.effect: OpacityMask {
            maskSource: Item {
                width: panel.width
                height: panel.height
                Rectangle {
                    anchors.centerIn: parent
                    width: panel.width
                    height: panel.height
                    radius: panel.radius
                }
            }
        }
    }

    // DropShadow {
    //     anchors.fill: panel
    //     horizontalOffset: 0
    //     verticalOffset: 0
    //     radius: 10.0
    //     samples: 17
    //     color: "#70000000"
    //     source: panel
    // }

    Row {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.topMargin: 6.5

        Item {

            Image {
                id: shutdown
                height: 22
                width: 22
                source: "images/system-shutdown.svg"
                fillMode: Image.PreserveAspectFit

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        shutdown.source = "images/system-shutdown-hover.svg"
                        var component = Qt.createComponent(
                                    "../components/ShutdownToolTip.qml")
                        if (component.status === Component.Ready) {
                            var tooltip = component.createObject(shutdown)
                            tooltip.x = -90
                            tooltip.y = 25
                            tooltip.destroy(600)
                        }
                    }
                    onExited: {
                        shutdown.source = "images/system-shutdown.svg"
                    }
                    onClicked: {
                        shutdown.source = "images/system-shutdown-pressed.svg"
                        onClicked: action_shutDown()
                    }
                }
            }
        }

        Row {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 30

            Item {

                Image {
                    id: reboot
                    height: 22
                    width: 22
                    source: "images/system-reboot.svg"
                    fillMode: Image.PreserveAspectFit

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: {
                            reboot.source = "images/system-reboot-hover.svg"
                            var component = Qt.createComponent(
                                        "../components/RebootToolTip.qml")
                            if (component.status === Component.Ready) {
                                var tooltip = component.createObject(reboot)
                                tooltip.x = -80
                                tooltip.y = 25
                                tooltip.destroy(600)
                            }
                        }
                        onExited: {
                            reboot.source = "images/system-reboot.svg"
                        }
                        onClicked: {
                            reboot.source = "images/system-reboot-pressed.svg"
                            onClicked: action_reBoot()
                        }
                    }
                }
            }

            Row {
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 65
                anchors.topMargin: 0.5

                Text {
                    id: batt
                    // text: "batt"
                    Battery {}
                    color: "#fefefe"
                    font.pointSize: 11
                }
                
                PW.KeyboardLayoutSwitcher {
                                id: keyboardLayoutSwitcher

                                anchors.fill: parent
                                acceptedButtons: Qt.NoButton
                            }

                Row {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: 20
                    Text {
                        id: kb
                        color: "#dfdfdf"
                        text: keyboardLayoutSwitcher.layoutNames.shortName
                        font.pointSize: 12
                    }
                }

                Row {
                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.rightMargin: 46
                    Text {
                        id: timelb
                        // text: Qt.formatDateTime(new Date(), "HH:mm")
                        text: Qt.formatDateTime(new Date(), "hh:mm ap")
                        color: "#fefefe"
                        font.pointSize: 12
                    }
                }
            }
        }
    }

    Timer {
        id: timetr
        interval: 500
        repeat: true
        onTriggered: {
            timelb.text = Qt.formatDateTime(new Date(), "HH:mm")
        }
    }

}
