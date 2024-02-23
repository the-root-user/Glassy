/********************************************************************
 This file is part of the KDE project.

Copyright (C) 2014 Aleix Pol Gonzalez <aleixpol@blue-systems.com>

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

import QtQuick 2.6
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.sessions 2.0
import "../components"

Item {
    id: wallpaperFader
    property Item clock
    property Item mainStack
    property Item footer
    property alias source: wallpaperBlur.source
    state: lockScreenRoot.uiVisible ? "on" : "off"
    property real factor: 0
    readonly property bool lightBackground: Math.max(PlasmaCore.ColorScope.backgroundColor.r, PlasmaCore.ColorScope.backgroundColor.g, PlasmaCore.ColorScope.backgroundColor.b) > 0.5

    property bool alwaysShowClock: typeof config === "undefined" || config.alwaysShowClock === true

    Behavior on factor {
        NumberAnimation {
            target: wallpaperFader
            property: "factor"
            duration: 1000
            easing.type: Easing.InOutQuad
        }
    }

    // Thought of two blurs to make distinction between the "on" and "off" state but.. ig, +1 don't work simultaneously :/

    GaussianBlur {
        id: wallpaperBlur
        anchors.fill: parent
        // radius: wallpaperFader.factor
        radius: 30
        samples: radius
        // z:-3
    }
    ShaderEffect {
        id: wallpaperShader
        anchors.fill: parent
        supportsAtlasTextures: true
        property var source: ShaderEffectSource {
            id: shaderSource
            sourceItem: wallpaperBlur
            live: true
            hideSource: true
            textureMirroring: ShaderEffectSource.NoMirroring
        }
        readonly property real contrast: 1 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real saturation: 1.8 * wallpaperFader.factor + (1 - wallpaperFader.factor)
        readonly property real intensity: (wallpaperFader.lightBackground ? 1.7 : 0.6) * wallpaperFader.factor + (1 - wallpaperFader.factor)
    }

    // FastBlur {
    //     anchors.fill: parent
    //     source: wallpaper
    //     id: wallpaperBlurExtra
    //     radius: wallpaperFader.factor
    //     z:-2
    // }
    // ShaderEffect {
    //     id: wallpaperShaderExtra
    //     anchors.fill: parent
    //     supportsAtlasTextures: true
    //     property var source: ShaderEffectSource {
    //         id: shaderSourceExtra
    //         sourceItem: wallpaperBlurExtra
    //         live: true
    //         hideSource: true
    //         textureMirroring: ShaderEffectSource.NoMirroring
    //     }
    //     readonly property real contrast: 1 * wallpaperFader.factor + (1 - wallpaperFader.factor)
    //     readonly property real saturation: 1.8 * wallpaperFader.factor + (1 - wallpaperFader.factor)
    //     readonly property real intensity: (wallpaperFader.lightBackground ? 1.7 : 0.6) * wallpaperFader.factor + (1 - wallpaperFader.factor)
    // }

    states: [
        State {
            name: "on"
            PropertyChanges {
                target: mainStack
                opacity: 1
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 90
            }
            PropertyChanges {
                target: clock.shadow
                opacity: 0
            }
            PropertyChanges {
                target: clock
                opacity: 0
            }
        },
        State {
            name: "off"
            PropertyChanges {
                target: mainStack
                opacity: 0
            }
            PropertyChanges {
                target: wallpaperFader
                factor: 0
            }
            PropertyChanges {
                target: clock.shadow
                opacity: wallpaperFader.alwaysShowClock ? 1 : 0
            }
            PropertyChanges {
                target: clock
                opacity: wallpaperFader.alwaysShowClock ? 1 : 0
            }
        }
    ]
    transitions: [
        Transition {
            from: "off"
            to: "on"
            //Note: can't use animators as they don't play well with parallelanimations
            NumberAnimation {
                targets: [mainStack, clock]
                property: "opacity"
                // duration: units.longDuration
                duration: 500
                easing.type: Easing.InOutQuad
            }
        },
        Transition {
            from: "on"
            to: "off"
            NumberAnimation {
                targets: [mainStack, clock]
                property: "opacity"
                duration: 500
                easing.type: Easing.InOutQuad
            }
        }
    ]
}
