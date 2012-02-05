/*
 * This file is part of the Meegopas, more information at www.gitorious.org/meegopas
 *
 * Author: Jukka Nousiainen <nousiaisenjukka@gmail.com>
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * See full license at http://www.gnu.org/licenses/gpl-3.0.html
 */

import QtQuick 1.1
import com.nokia.symbian 1.1
import "UIConstants.js" as UIConstants
import "reittiopas.js" as Reittiopas

Page {
    id: stop_page
    property string leg_code
    property int leg_index
    anchors.fill: parent

    onStatusChanged: {
        if(status == Component.Ready && !stopModel.count) {
            var route = Reittiopas.get_route_instance()
            route.dump_stops(leg_index, stopModel)
        }
    }

    tools: stopTools
    state: "normal"

    ToolBarLayout {
        id: stopTools
        visible: false
        ToolButton { iconSource: "toolbar-back"; onClicked: { stop_page.state = "normal"; pageStack.pop(); } }
        ToolButton {
            text: qsTr("Map")
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                stop_page.state = stop_page.state == "normal" ? "map" : "normal"
            }
        }
    }

    anchors.margins: UIConstants.DEFAULT_MARGIN

    ListModel {
        id: stopModel
        property bool done : false
    }

    ListView {
        id: routeList
        clip: true
        anchors.top: parent.top
        height: parent.height/2
        width: parent.width
        z: 200
        model: stopModel
        delegate: StopDelegate {}
        header: Header {
            text: leg_code ? qsTr("Stops for line ") + leg_code : qsTr("Walking route")
        }
        onCountChanged: {
            if(stopModel.done)
                map.flickable_map.panToLatLong(stopModel.get(0).latitude,stopModel.get(0).longitude)
        }
    }

    Rectangle {
        id: map_blocker
        color: "black"
        z: 100
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width + UIConstants.DEFAULT_MARGIN * 2
        height: parent.height/2
    }

    MapElement {
        id: map
        anchors.top: routeList.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height: parent.height/2 + UIConstants.DEFAULT_MARGIN
        width: parent.width + UIConstants.DEFAULT_MARGIN * 2
    }
    ScrollDecorator {
        id: scrolldecorator
        flickableItem: routeList
    }

    states: [
        State {
            name: "map"
            PropertyChanges { target: map; opacity: 1.0 }
            PropertyChanges { target: routeList; height: parent.height/2 }
            PropertyChanges { target: map_blocker; height: parent.height/2 }
        },
        State {
            name: "normal"
            PropertyChanges { target: map; opacity: 0.0 }
            PropertyChanges { target: routeList; height: parent.height }
            PropertyChanges { target: map_blocker; height: parent.height }
        }
    ]
    transitions: Transition {
        NumberAnimation { properties: "height"; duration: 500; easing.type: Easing.InOutCubic }
        NumberAnimation { properties: "opacity"; duration: 500; }
    }

    BusyIndicator {
        id: busyIndicator
        visible: !(stopModel.done)
        running: true
        anchors.centerIn: parent
        width: 75
        height: 75
    }
}
