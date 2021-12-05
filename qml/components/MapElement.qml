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

import QtQuick 2.1
import QtLocation 5.0
import QtPositioning 5.3
import MqttClient 1.0
import "../js/reittiopas.js" as Reittiopas
import "../js/sirilive.js" as Sirilive
import "../js/storage.js" as Storage
import "../js/UIConstants.js" as UIConstants
import "../js/helper.js" as Helper
import "../js/theme.js" as Theme

Item {
    id: map_element
    property bool positioningActive : true
    property alias flickable_map : flickable_map
    property variant mqttSubscriptionMap : []

    MqttClient {
        id: mqttClient
        hostname: "mqtt.hsl.fi"
    }
    Component.onDestruction: {
        if (appWindow.currentApi === "helsinki") {
            mqttClient.disconnectFromHost()
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if(Qt.application.active) {
                vehicleUpdateTimer.start()
            }
            else {
                vehicleModel.clear()
                if (appWindow.currentApi !== "helsinki") {
                    vehicleUpdateTimer.stop()
                }
                else {
                    mqttClient.disconnectFromHost()
                }
            }
        }
    }

    function addMqttVehicle(topic, payload) {
        var payload_json = JSON.parse(payload)
        var vehicleUniqueId = payload_json.VP.oper + payload_json.VP.veh;
        for (var vehicleIndex = 0; vehicleIndex < vehicleModel.count; ++vehicleIndex) {
            if (vehicleModel.get(vehicleIndex).modelUniqueId === vehicleUniqueId) {
                vehicleModel.remove(vehicleIndex);
                break;
            }
        }
        // Mqtt API doesn't support subway or ferry yet so leave those colors out for now
        var vehicleColor = "#08a7cc"; // Default to bus
        if (topic.substring(27, 31) === "tram") {
            vehicleColor = "#925bc6"
        }
        else if (topic.substring(27, 32) === "train") {
            vehicleColor = "#61b700"
        }
        var vehicleSpeed = Math.round(payload_json.VP.spd * 3.6) // Convert to km/h
        vehicleModel.append({"modelUniqueId": vehicleUniqueId,
                                "modelLongitude": payload_json.VP.long, "modelLatitude":
                                payload_json.VP.lat, "modelCode": payload_json.VP.desi,
                                "modelColor": vehicleColor, "modelBearing": payload_json.VP.hdg,
                                "modelSpeed": vehicleSpeed})
    }

    function next_station() {
        flickable_map.panToCoordinate(Helper.next_station())
    }

    function previous_station() {
        flickable_map.panToCoordinate(Helper.previous_station())
    }

    function first_station() {
        flickable_map.panToCoordinate(Helper.first_station())
    }

    function removeAll() {
        flickable_map.map.removeMapObject(root_group)
    }

    function receiveVehicleLocation() {
        Sirilive.new_live_instance(vehicleModel, Storage.getSetting('api'))

        var epochTime = vehicleModel.timeStamp

        if (!epochTime) {
            flickable_map.timeStamp.text = qsTr(" Backend error ")
            return
        }

        // Convert Turku specific seconds to milliseconds
        if (Storage.getSetting('api') === 'turku') {
            epochTime *= 1000
        }

        var timeDifference = Date.now() - epochTime
        timeDifference /= 1000  // Convert milliseconds to seconds

        if (timeDifference > 0 && timeDifference < 60) {
            flickable_map.timeStamp.text = qsTr(" Updated ") + Math.round(timeDifference) + qsTr(" s ago ")
        }
        else {
            var updatedDate = new Date(0)

            if (updatedDate.getTimezoneOffset() < 180) {
                var dayLightSavingTime = 0
                dayLightSavingTime = parseInt(epochTime)
                dayLightSavingTime += 3600000
                epochTime = dayLightSavingTime.toString()
            }

            updatedDate.setMilliseconds(epochTime)
            flickable_map.timeStamp.text =
                    qsTr(" Updated ") + Qt.formatDateTime(updatedDate, "d.M. hh:mm:ss ")
        }
    }

    ListModel {
        id: stationModel
    }

    ListModel {
        id: stationTextModel
    }

    ListModel {
        id: stopModel
    }

    ListModel {
        id: vehicleModel
        property bool done: false
        property string timeStamp: ""
        property var vehicleCodesToShowOnMap: []
    }

    Timer {
        id: vehicleUpdateTimer
        interval: appWindow.currentApi !== "helsinki" ? 3000 : 300
        repeat: appWindow.currentApi !== "helsinki"
        onTriggered: {
            if (appWindow.currentApi === "helsinki") {
                mqttClient.port = "8883"
                mqttClient.connectToHost()
                for (var allowedLine in vehicleModel.vehicleCodesToShowOnMap) {
                    var vehicleToSubscribe = mqttClient.subscribe("/hfp/v2/journey/ongoing/vp/+/+/+/" +
                            vehicleModel.vehicleCodesToShowOnMap[allowedLine].gtfsId
                            + "/#");
                    vehicleToSubscribe.messageReceived.connect(addMqttVehicle)
                    mqttSubscriptionMap.push(vehicleToSubscribe)
                }
            }
            else {
                receiveVehicleLocation()
            }
        }
    }

    FlickableMap {
        id: flickable_map
        property alias start_point: startPoint
        property alias end_point: endPoint
        property alias timeStamp: timeStamp

        anchors.fill: parent

        // TODO: ?
        MapItemView {
            id: stationView
            model: stationModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(lat, lng)
                sourceItem: Image {
                    smooth: true
                    height: 30
                    width: 30
                    source: "qrc:/images/stop.png"
                }
                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 45
            }
        }

        // TODO: ?
        MapItemView {
            id: stationTextView
            model: stationTextModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(lat, lng)
                sourceItem: Text {
                    // TODO: width and height?
                    font.pixelSize: UIConstants.FONT_LARGE * appWindow.scalingFactor
                    text: name
                }
                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 48
            }
        }

        // This is the yellow squares representing stops
        MapItemView {
            id: stopView
            model: stopModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(lat, lng)
                sourceItem: Image {
                    smooth: true
                    height: 20
                    width: 20
                    source: "qrc:/images/station.png"
                }

                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 45
            }
        }

        // This is the vehicles moving on map
        MapItemView {
            id: vehicleView
            model: vehicleModel
            delegate: MapQuickItem {
                coordinate: QtPositioning.coordinate(modelLatitude, modelLongitude)
                sourceItem:
                    Rectangle {
                    color: modelColor
                    radius: width * 0.5
                    border.color: 'black'
                    border.width: 2
                    width: 50
                    height: 50
                    Text {
                        id: lineCodeText
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: appWindow.currentApi === "helsinki" ? -8 : 0
                        font.pixelSize: 20
                        font.bold: true
                        text: modelCode
                    }
                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: 8
                        text: appWindow.currentApi === "helsinki" ? modelSpeed + "km/h" : ""
                        visible: appWindow.currentApi === "helsinki"
                        font.pixelSize: 12
                        font.bold: true
                    }

                    Image {
                        source: "qrc:/images/bearing_indicator.png"
                        enabled: typeof modelBearing !== "undefined"
                        height: 10
                        width: 20
                        visible: (typeof modelBearing !== "undefined") && (modelBearing != 0)
                        x: 15; y: -7.5
                        transform: Rotation {
                            origin.x: 10; origin.y: 32.5;
                            angle: typeof modelBearing === "undefined" ? 0 : modelBearing
                        }
                    }
                }

                anchorPoint.y: sourceItem.height / 2
                anchorPoint.x: sourceItem.width / 2
                z: 48
            }
        }

        // Trip start
        MapQuickItem {
            id: startPoint
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/start.png"
                height: 50
                width: 50
            }

            anchorPoint.y: sourceItem.height - 5
            anchorPoint.x: sourceItem.width / 2
            z: 50
        }

        // Trip end
        MapQuickItem {
            id: endPoint
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/finish.png"
                height: 50
                width: 50
            }

            anchorPoint.y: sourceItem.height - 5
            anchorPoint.x: sourceItem.width / 2
            z: 50
        }

        MapQuickItem {
            id: timeStamp
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            z: 100
            property alias text: timeStampText.text

            sourceItem:
                Rectangle {
                height: timeStampText.height
                width: timeStampText.width
                color: "grey"
                radius: 10
                opacity: 0.7
                Text {
                    id: timeStampText
                    anchors.centerIn: parent
                    font.bold: true
                    text: ""
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            onPressAndHold: flickable_map.panToCoordinate(current_position.coordinate)
            onDoubleClicked: flickable_map.zoomLevel += 1
        }
    }

    // Route
    Component {
        id: polyline_component

        MapPolyline {
            line.width: 8 * appWindow.scalingFactor
            z: 30
            smooth: true
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 200
        active: Qt.application.active
        onPositionChanged: {
            if(appWindow.followMode) {
                flickable_map.panToCoordinate(current_position.coordinate)
            }
        }
    }

    Connections {
        target: appWindow
        onFollowModeEnabled: {
            flickable_map.panToCoordinate(positionSource.position.coordinate)
        }
    }

    Binding {
        target: current_position
        property: "coordinate"
        value: positionSource.position.coordinate
    }

    MapQuickItem {
        id: current_position
        sourceItem: Image {
            smooth: true
            source: "qrc:/images/position.png"
            width: 30
            height: 30
        }

        visible: positionSource.position.latitudeValid && positionSource.position.longitudeValid && positionSource.position.horizontalAccuracy > 0 && positionSource.position.horizontalAccuracy < 100
        anchorPoint.y: sourceItem.height / 2
        anchorPoint.x: sourceItem.width / 2
        z: 51

        Behavior on coordinate {
            CoordinateAnimation {
                duration: 500
                easing.type: Easing.Linear
            }
        }
    }

    Component {
        id: coord_component

        Location {
            id: coord
        }
    }

    Component {
        id: stop

        MapQuickItem {
            id: stop_circle
            sourceItem: Image {
                smooth: true
                source: "qrc:/images/station.png"
                height: 20 * appWindow.scalingFactor
                width: 20 * appWindow.scalingFactor
            }
            anchorPoint.y: sourceItem.height / 2
            anchorPoint.x: sourceItem.width / 2
            z: 45
        }
    }

    function initialize(multipleRoutes) {
        flickable_map.addMapItem(current_position)

        if (appWindow.currentApi === "helsinki" || appWindow.currentApi === "turku" || appWindow.currentApi === "tampere") {
            vehicleUpdateTimer.start()
        }

        Helper.clear_objects()
        vehicleModel.vehicleCodesToShowOnMap = []

        // Add startPoint to the map
        add_station2(appWindow.itinerariesModel.get(0).legs.get(0).from, appWindow.itinerariesModel.get(0).legs.get(0).from.name)
        flickable_map.start_point.coordinate.longitude =
                appWindow.itinerariesModel.get(0).legs.get(0).from.longitude
        flickable_map.start_point.coordinate.latitude =
                appWindow.itinerariesModel.get(0).legs.get(0).from.latitude

        // Add all the routes and vehicles to the map, ResultMapPage shows content for all the 5 routes,
        // last 4 with thinner line
        if (multipleRoutes === true) {
            var countOfRoutes = appWindow.itinerariesModel.count;
            for (var routeIndex = 0; routeIndex < countOfRoutes; ++routeIndex) {
                add_route_to_map(routeIndex)
            }
        }
        else if (appWindow.itinerariesIndex >= 0) {
                add_route_to_map(appWindow.itinerariesIndex)
        }

        // Add endPoint to the map
        var countOfLegs = appWindow.itinerariesModel.get(0).legs.count
        add_station2(appWindow.itinerariesModel.get(0).legs.get(countOfLegs - 1).to, appWindow.itinerariesModel.get(0).legs.get(countOfLegs - 1).to.name)
        flickable_map.end_point.coordinate.longitude =
                appWindow.itinerariesModel.get(0).legs.get(countOfLegs - 1).to.longitude
        flickable_map.end_point.coordinate.latitude =
                appWindow.itinerariesModel.get(0).legs.get(countOfLegs - 1).to.latitude
    }

    function add_route_to_map(route_index) {
        var countOfLegs = appWindow.itinerariesModel.get(route_index).legs.count
        for (var legindex = 0; legindex < countOfLegs; ++legindex) {
            var legdata = appWindow.itinerariesModel.get(route_index).legs.get(legindex)
            var paths = []
            add_station2(legdata.to,
                         legdata.name)
            var coordinates = decodePolyline(legdata.polyline)

            for(var coordinateIndex = 0; coordinateIndex < coordinates.length; ++ coordinateIndex) {
                paths.push({"longitude": coordinates[coordinateIndex][1], "latitude": coordinates[coordinateIndex][0]})
            }

            var p = polyline_component.createObject(flickable_map)
            p.line.color =
                    Theme.theme['general'].TRANSPORT_COLORS[legdata.type]
            p.path = paths

            // Print all 4 later route options with thinner line
            if (route_index > 0) {
                p.line.width *= 0.5;
            }

            flickable_map.addMapItem(p)

            if (legdata.type !== "walk") {
                vehicleModel.vehicleCodesToShowOnMap.push(
                            {"gtfsId": legdata.gtfsId,
                                "type": legdata.type,
                                "code": legdata.code})
            }
            if(legdata.type !== "walk") {
                var countOfStops = appWindow.itinerariesModel.get(route_index).legs.get(legindex).locs.count
                for(var stopindex = 0; stopindex < countOfStops; ++stopindex) {
                    var loc = legdata.locs.get(stopindex)
                    add_stop2(loc.latitude, loc.longitude)
                }
            }
        }
    }

    function add_station2(coord, name) {
        if (name != "") {
            // Append to name model
            stationModel.append({"lng": coord.longitude, "lat": coord.latitude, "name": name})
        }

        // Add the normal point for the station
        stationModel.append({"lng": coord.longitude, "lat": coord.latitude})
        Helper.add_station(coord)
    }

    function add_station(coord, name, map_group) {
        map_group.station_text.coordinate = coord
        map_group.station_text.text = name?name:""
        map_group.station.coordinate = coord

        Helper.add_station(coord)
    }

    function add_stop2(latitude, longitude) {
        stopModel.append({"lng": longitude, "lat": latitude})
    }

    function add_stop(latitude, longitude) {
        var stop_object = stop.createObject(appWindow)
        if(!stop_object) {
            console.debug("creating object failed")
            return
        }
        var coord = coord_component.createObject(appWindow)
        coord.latitude = latitude
        coord.longitude = longitude
        stop_object.coordinate = coord
        Helper.push_to_objects(stop_object)
    }

    // Adapted from: https://github.com/mapbox/polyline/blob/master/src/polyline.js
    function decodePolyline(str, precision) {
        var index = 0,
            lat = 0,
            lng = 0,
            coordinates = [],
            shift = 0,
            result = 0,
            jsbyte = null,
            latitude_change,
            longitude_change,
            factor = Math.pow(10, precision || 5);

        // Coordinates have variable length when encoded, so just keep
        // track of whether we've hit the end of the string. In each
        // loop iteration, a single coordinate is decoded.
        while (index < str.length) {

            // Reset shift, result, and jsbyte
            jsbyte = null;
            shift = 0;
            result = 0;

            do {
                jsbyte = str.charCodeAt(index++) - 63;
                result |= (jsbyte & 0x1f) << shift;
                shift += 5;
            } while (jsbyte >= 0x20);

            latitude_change = ((result & 1) ? ~(result >> 1) : (result >> 1));

            shift = result = 0;

            do {
                jsbyte = str.charCodeAt(index++) - 63;
                result |= (jsbyte & 0x1f) << shift;
                shift += 5;
            } while (jsbyte >= 0x20);

            longitude_change = ((result & 1) ? ~(result >> 1) : (result >> 1));

            lat += latitude_change;
            lng += longitude_change;

            coordinates.push([lat / factor, lng / factor]);
        }
        return coordinates;
    }
}
