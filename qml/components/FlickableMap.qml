/**********************************************************************
*
* This file is part of the JollaOpas, forked from Jopas originally
* forked from Meegopas.
* More information:
*
*   https://github.com/hsarkanen/JollaOpas
*   https://github.com/rasjani/Jopas
*   https://github.com/junousia/Meegopas
*
* Author: Heikki Sarkanen <heikki.sarkanen@gmail.com>
* Original author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
* Other contributors:
*   Jani Mikkonen <jani.mikkonen@gmail.com>
*   Jonni Rainisto <jonni.rainisto@gmail.com>
*   Mohammed Sameer <msameer@foolab.org>
*   Clovis Scotti <scotti@ieee.org>
*   Benoit HERVIER <khertan@khertan.net>
*
* All assets contained within this project are copyrighted by their
* respectful authors.
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* See full license at http://www.gnu.org/licenses/gpl-3.0.html
*
**********************************************************************/

/* Modified from the example by Clovis Scotti <scotti@ieee.org>, http://cpscotti.com/blog/?p=52, released with GPL 3.0 */

import QtQuick 2.1
import QtLocation 5.0
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "../js/storage.js" as Storage

Map {
    id: map
    anchors.fill: parent
    // Read the value in settings between 1-10 and scale to rational values between 10-19
    zoomLevel: Storage.getSetting('default_zoom_level') === "Unknown" ?
                   14 : parseInt(Storage.getSetting('default_zoom_level'), 10) + 9
    clip: true
    gesture.enabled: true
    gesture.activeGestures: appWindow.followMode ? MapGestureArea.ZoomGesture : MapGestureArea.ZoomGesture | MapGestureArea.PanGesture | MapGestureArea.FlickGesture
    gesture.flickDeceleration: 4000
    activeMapType: supportedMapTypes.length < 7 ? supportedMapTypes[0] : supportedMapTypes[6]

    Rectangle {
        anchors.fill: map
        // TODO: bad color
        color: "black"
        opacity: mapTypeMenu.active ? 1.0 : 0.0
        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }
    }

    plugin: Plugin {
        name: "here"

        PluginParameter {
            name: "app_id"
            value: "27CldTbuDTOoIAGxIjkd"
        }

        PluginParameter {
            name: "app_code"
            value: "<insert your api key from https://platform.here.com/portal/ here>"
        }
    }

    center {
        latitude: Storage.getSetting("api") === "helsinki" ? 60.1687069096 : 61.5000000000
        longitude: Storage.getSetting("api") === "helsinki" ? 24.9407379411 : 23.7667000000
    }

    Behavior on center {
        CoordinateAnimation {
            duration: 500
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on zoomLevel {
        NumberAnimation {
            duration: 250
            easing.type: Easing.Linear
        }
    }

    function panToCoordinate(coordinate) {
        map.panToLatLong(coordinate.latitude, coordinate.longitude)
    }

    function panToLatLong(latitude,longitude) {
        map.center = QtPositioning.coordinate(latitude, longitude)
    }

    MapQuickItem {
        width: 70 // width of MapButton
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        z: 100

        sourceItem: Column {
            id: col
            spacing: 16

            MapButton {
                id: mapType
                visible: map.supportedMapTypes.length > 1
                source: "qrc:/images/maptype.png"
                onClicked: {
                    mapTypeMenu.open()
                }

                MySelectionDialog {
                    id: mapTypeMenu
                    model: map.supportedMapTypes
                    delegate: MaptypesDelegate {
                        onClicked: {
                            mapTypeMenu.selectedIndex = index
                            mapTypeMenu.accept()
                        }
                    }
                    onAccepted: {
                        map.activeMapType = map.supportedMapTypes[selectedIndex]
                    }
                    onRejected: {}
                }
            }

            MapButton {
                source: "qrc:/images/current.png"
                selected: appWindow.followMode
                onClicked: appWindow.followMode = !appWindow.followMode
            }

            MapButton {
                id: zoomIn
                source: "image://theme/icon-m-add"
                onClicked: zoomLevel += 1
            }

            MapButton {
                id: zoomOut
                source: "image://theme/icon-m-remove"
                onClicked: zoomLevel -= 1
            }
        }
    }
}
