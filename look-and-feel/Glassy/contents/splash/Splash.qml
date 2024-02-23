/*
 *   Copyright 2014 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License version 2,
 *   or (at your option) any later version, as published by the Free
 *   Software Foundation
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.1


Image {
    id: root
    source: "images/background.jpg"

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }
    Image {
        id: topRect
        anchors.horizontalCenter: parent.horizontalCenter
        // y: root.height / 3
        source: "images/rectangle.svg"
        Image {
            source: "images/logo.png"
            height: 340
            width: height
            anchors.centerIn: parent
        }
        Rectangle {
            id: rect1
            color: "#fefefe"
            opacity: 0.25
            anchors {
                bottom: parent.bottom
                bottomMargin: topRect.height / -5
                horizontalCenter: parent.horizontalCenter
            }
            height: 10
            radius: height/2
            width: height*24
        }
        // border rect
        //Rectangle {
        //    id: rect2
        //    color: "#fefefe"
        //    opacity: 0.1
        //    anchors {
        //        bottom: parent.bottom
        //        bottomMargin: topRect.height / -4 -1
        //        horizontalCenter: parent.horizontalCenter
        //    }
        //    height: rect1.height +2
        //    radius: height/2
        //    width: rect1.width +2
        //    z:-1
        //}
        Rectangle {
            id: rect3
            radius: height/2
            color: "#5657f5"
            opacity: 1
            anchors {
                left: rect1.left
                top: rect1.top
                bottom: rect1.bottom
            }
            width: (rect1.width / 6) * (stage - 1)
            Behavior on width { 
                PropertyAnimation {
                    duration: 250
                    easing.type: Easing.InOutQuad
                }
            }
        }
    
    }

    SequentialAnimation {
        id: introAnimation
        running: false

        ParallelAnimation {

            PropertyAnimation {
                property: "y"
                target: topRect
                from: root.height / 2
                to: root.height / 3
                duration: 1000
                easing.type: Easing.InOutBack
                easing.overshoot: 1.0
            }

            PropertyAnimation {
                property: "opacity"
                target: topRect
                from: 0
                to: 1
                duration: 1500
                easing.type: Easing.InOutBack
                easing.overshoot: 1.0
            }

            PropertyAnimation {
                property: "y"
                target: bottomRect
                to: 2 * (root.height / 3) - bottomRect.height
                duration: 1000
                easing.type: Easing.InOutBack
                easing.overshoot: 1.0
            }
        }
    }
}
