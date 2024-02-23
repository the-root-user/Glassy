// Modified by Alexey Varfolomeev 2021 <varlesh@gmail.com>


/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2016 Kai Uwe Broulik <kde@privat.broulik.de>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*********************************************************************/
import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    visible: mpris2Source.hasPlayer
    implicitHeight: controlsRow.height + controlsRow.y

    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.topMargin: 60
        anchors.rightMargin: 20
        id: widget
        color: "#111928"
        radius: 28
        height: 100
        width: 320
        opacity: 0.7
        border.width: 0.5
        // border.color: "#ffffff1f"
        border.color: "#2f3643"
        // border.color: "#4a5059"
    }

    ShaderEffectSource {
         id: blurArea
         sourceItem: wallpaper
         width: widget.width
         height: widget.height
         anchors.centerIn: widget
         sourceRect: Qt.rect(x,y,width,height)
         visible: false
     }

    FastBlur {
        anchors.fill: widget
        source: blurArea
        radius: 100
        z:-1
        property bool rounded: true
        layer.enabled: rounded
        layer.effect: OpacityMask {
            maskSource: Item {
                width: widget.width
                height: widget.height
                Rectangle {
                    anchors.centerIn: widget
                    width: widget.width
                    height: widget.height
                    radius: widget.radius
                }
            }
        }
    }

    Image {
        id: img
        property bool rounded: true
        property bool adapt: true
        anchors.fill: widget
        opacity: 0
        source: mpris2Source.albumArt
        fillMode: Image.PreserveAspectCrop
        visible: status === Image.Loading || status === Image.Ready
    }

    FastBlur {
        anchors.fill: img
        source: img
        radius: 54
        opacity: 0.15
        property bool rounded: true
        property bool adapt: true
        layer.enabled: rounded
        layer.effect: OpacityMask {
            maskSource: Item {
                width: img.width
                height: img.height
                Rectangle {
                    anchors.centerIn: parent
                    width: img.adapt ? img.width : Math.min(img.width, img.height)
                    height: img.adapt ? img.height : width
                    radius: widget.radius
                }
            }
        }
    }

    // DropShadow {
    //     anchors.fill: widget
    //     horizontalOffset: 0
    //     verticalOffset: 6
    //     radius: 20.0
    //     samples: 17
    //     color: "#40000000"
    //     source: widget
    // }

    RowLayout {
        id: controlsRow
        anchors.fill: widget
        anchors.right: parent.right
        anchors.top: parent.top
        // anchors.topMargin: 90
        anchors.rightMargin: 20
        anchors.leftMargin: 30
        spacing: 0

        enabled: mpris2Source.canControl

        PlasmaCore.DataSource {
            id: mpris2Source

            readonly property string source: "@multiplex"
            readonly property var playerData: data[source]

            readonly property bool hasPlayer: sources.length > 1 && !!playerData
            readonly property string identity: hasPlayer && playerData.Identity || ""
            readonly property bool playing: hasPlayer && playerData.PlaybackStatus === "Playing"
            readonly property bool canControl: hasPlayer && playerData.CanControl
            readonly property bool canGoBack: hasPlayer && playerData.CanGoPrevious
            readonly property bool canGoNext: hasPlayer && playerData.CanGoNext

            readonly property var currentMetadata: hasPlayer ? playerData.Metadata : ({})

            readonly property string track: {
                const xesamTitle = currentMetadata["xesam:title"]
                if (xesamTitle) {
                    return xesamTitle
                }
                // if no track title is given, print out the file name
                const xesamUrl = currentMetadata["xesam:url"] ? currentMetadata["xesam:url"].toString() : ""
                if (!xesamUrl) {
                    return ""
                }
                const lastSlashPos = xesamUrl.lastIndexOf('/')
                if (lastSlashPos < 0) {
                    return ""
                }
                const lastUrlPart = xesamUrl.substring(lastSlashPos + 1)
                return decodeURIComponent(lastUrlPart)
            }
            readonly property var artists: currentMetadata["xesam:artist"] || [] // stringlist
            readonly property var albumArtists: currentMetadata["xesam:albumArtist"] || [] // stringlist
            readonly property string albumArt: currentMetadata["mpris:artUrl"] || ""

            engine: "mpris2"
            connectedSources: [source]

            function startOperation(op) {
                const service = serviceForSource(source)
                const operation = service.operationDescription(op)
                return service.startOperationCall(operation)
            }

            function goPrevious() {
                startOperation("Previous");
            }
            function goNext() {
                startOperation("Next");
            }
            function playPause(source) {
                startOperation("PlayPause");
            }
        }

        Image {
            id: albumArt
            property bool rounded: true
            property bool adapt: true
            opacity: 1
            Layout.preferredWidth: height
            Layout.preferredHeight: widget.height * 3/4
            asynchronous: true
            source: mpris2Source.track.length > 0 ? mpris2Source.albumArt : ""
            fillMode: Image.PreserveAspectFit
            // sourceSize.height: height
            visible: status === Image.Loading || status === Image.Ready

            layer.enabled: rounded
            layer.effect: OpacityMask {
                maskSource: Item {
                    width: albumArt.width
                    height: albumArt.height
                    Rectangle {
                        anchors.centerIn: parent
                        width: albumArt.adapt ? albumArt.width : Math.min(albumArt.width, albumArt.height)
                        height: albumArt.adapt ? albumArt.height : width
                        radius: 7
                    }
                }
            }
        }

        Item {
            // spacer
            // width: units.smallSpacing
            width: widget.height - albumArt.Layout.preferredHeight - 5
            height: 1
        }

        ColumnLayout {
            Layout.maximumWidth: 260
            Layout.minimumWidth: 150
            spacing: 0

            PlasmaComponents3.Label {
                Layout.fillWidth: true
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                text: mpris2Source.track.length > 0 ? mpris2Source.track
                        : ((mpris2Source.hasPlayer && ["Playing", "Paused"].includes(mpris2Source.playerData.PlaybackStatus))
                            ? i18nd("plasma_lookandfeel_org.kde.lookandfeel", "No title")
                            : i18nd("plasma_lookandfeel_org.kde.lookandfeel", "No media playing"))
                textFormat: Text.PlainText
                // font.pointSize: PlasmaCore.Theme.defaultFont.pointSize + 1
                font.pointSize: PlasmaCore.Theme.defaultFont.pointSize * 1.25 + 1
                maximumLineCount: 1
                // color: "#dfdfdf"
            }

            PlasmaExtras.DescriptiveLabel {
                Layout.fillWidth: true
                wrapMode: Text.NoWrap
                elide: Text.ElideRight
                // if no artist is given, show player name instead
                text: mpris2Source.artists.length > 0 ? mpris2Source.artists.join(", ") : (mpris2Source.albumArtists.length > 0 ? mpris2Source.albumArtists.join(", ") : mpris2Source.identity)
                // text: mpris2Source.artist || mpris2Source.identity
                textFormat: Text.PlainText
                font.pointSize: PlasmaCore.Theme.smallestFont.pointSize + 1
                maximumLineCount: 1
                // color: "#dfdfdf"
            }
        }

        // PlasmaComponents3.ToolButton {
        //     focusPolicy: Qt.TabFocus
        //     enabled: mpris2Source.canGoBack
        //     Layout.preferredHeight: PlasmaCore.Units.gridUnit * 2
        //     Layout.preferredWidth: Layout.preferredHeight
        //     icon.name: LayoutMirroring.enabled ? "media-skip-forward" : "media-skip-backward"
        //     onClicked: {
        //         fadeoutTimer.running = false
        //         mpris2Source.goPrevious()
        //     }
        //     visible: mpris2Source.canGoBack || mpris2Source.canGoNext
        //     Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Previous track")
        // }
        // PlasmaComponents3.ToolButton {
        //     focusPolicy: Qt.TabFocus
        //     // Layout.fillHeight: true
        //     // Layout.preferredWidth: height // make this button bigger
        //     // Slightly bigger than the rest
        //     Layout.preferredHeight: PlasmaCore.Units.gridUnit * 2.5
        //     Layout.preferredWidth: Layout.preferredHeight
        //     icon.name: mpris2Source.playing ? "media-playback-pause" : "media-playback-start"
        //     onClicked: {
        //         fadeoutTimer.running = false
        //         mpris2Source.playPause()
        //     }
        //     Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Play or Pause media")
        // }
        // PlasmaComponents3.ToolButton {
        //     focusPolicy: Qt.TabFocus
        //     enabled: mpris2Source.canGoNext
        //     Layout.preferredHeight: PlasmaCore.Units.gridUnit * 2
        //     Layout.preferredWidth: Layout.preferredHeight
        //     icon.name: LayoutMirroring.enabled ? "media-skip-backward" : "media-skip-forward"
        //     onClicked: {
        //         fadeoutTimer.running = false
        //         mpris2Source.goNext()
        //     }
        //     visible: mpris2Source.canGoBack || mpris2Source.canGoNext
        //     Accessible.name: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Next track")
        // }
    }
}
