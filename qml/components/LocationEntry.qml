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
import Sailfish.Silica 1.0
import QtPositioning 5.3
import "../js/UIConstants.js" as UIConstants
import "../js/reittiopas.js" as Reittiopas
import "../js/storage.js" as Storage
import "../js/favorites.js" as Favorites
import "../js/recentitems.js" as RecentItems

Column {
    property alias type : label.text
    property alias font : label.font
    property alias label : labelContainer
    property alias lineHeightMode : label.lineHeightMode
    property alias lineHeight : label.lineHeight
    property alias textfield : textfield.text
    property alias suggestionAlias: suggestionTimer

    property string current_name : ''
    property string current_coord : ''

    Location {
        id: previousCoord

        coordinate: QtPositioning.coordinate(0, 0)
    }

    property string destination_name : ''
    property string destination_coord : ''

    property bool isFrom : false

    property bool destination_valid : (suggestionModel.count > 0)
    property alias selected_favorite : favoriteQuery.selectedFavoriteIndex
    property bool disable_favorites : false

    height: textfield.height + labelContainer.height
    width: parent.width

    signal locationDone(string name, string coord)
    signal currentLocationDone(string name, string coord)
    signal locationError()

    state: (destination_coord || current_coord) ? "validated" : destination_valid ? "sufficient" : "error"

    states: [
        State {
            name: "error"
            PropertyChanges { target: statusIndicator; color: "red" }
        },
        State {
            name: "sufficient"
            PropertyChanges { target: statusIndicator; color: "yellow" }
        },
        State {
            name: "validated"
            PropertyChanges { target: statusIndicator; color: "green" }
        }
    ]
    transitions: [
        Transition {
            ColorAnimation { duration: 100 }
        }
    ]

    Component.onCompleted: {
        Favorites.initialize()
        RecentItems.initialize()
    }

    function clear() {
        suggestionModel.clear()
        textfield.text = ''
        destination_coord = ''
        query.selectedIndex = -1
        locationDone("","")
    }

    function updateLocation(label, coord) {
        destination_name = label
        destination_coord = coord
        textfield.text = label
        locationDone(label, coord)
    }

    function updateCurrentLocation(label, coord) {
        current_name = label
        current_coord = coord
        textfield.placeholderText = label
        currentLocationDone(label, coord)
    }

    Timer {
        id: gpsTimer
        running: isFrom
        onTriggered: getCurrentCoord()
        triggeredOnStart: true
        interval: 200
        repeat: true
    }

    function positionValid(position) {
        if(position.latitudeValid && position.longitudeValid)
            return true
        else
            return false
    }

    function getCurrentCoord() {
        /* wait until position is accurate enough */
        if(positionValid(positionSource.position) && positionSource.position.horizontalAccuracy > 0 && positionSource.position.horizontalAccuracy < 100) {
            gpsTimer.stop()
            previousCoord.coordinate.latitude = positionSource.position.coordinate.latitude
            previousCoord.coordinate.longitude = positionSource.position.coordinate.longitude
            Reittiopas.get_reverse_geocode(previousCoord.coordinate.latitude.toString(),
                                                                         previousCoord.coordinate.longitude.toString(),
                                                                         currentLocationModel,
                                                                         Storage.getSetting('api'))
        } else {
            /* poll again in 200ms */
            gpsTimer.start()
        }
    }

    PositionSource {
        id: positionSource
        updateInterval: 500
        active: Qt.application.active
        onPositionChanged: {
            /* if we have moved >250 meters from the previous place, update current location */
            if(previousCoord.coordinate.latitude != 0 && previousCoord.coordinate.longitude != 0 &&
                    position.coordinate.distanceTo(previousCoord) > 250) {
                getCurrentCoord()
            }
        }
    }

    ListModel {
        id: currentLocationModel
        property bool done: true

        onDoneChanged: {
            if (done) {
                /* There should be always just one result since query size=1 */
                if(currentLocationModel.count > 0) {
                    updateCurrentLocation(currentLocationModel.get(0).label,
                                          currentLocationModel.get(0).coord)
                }
            }
        }
    }

    ListModel {
        id: suggestionModel
        property bool done: true

        onDoneChanged: {
            if (done) {
                /* if only result, take it into use */
                if(suggestionModel.count == 1) {
                    updateLocation(suggestionModel.get(0).label, suggestionModel.get(0).coord)
                } else {
                    /* just update the first result to main page */
                    locationDone(suggestionModel.get(0).label, suggestionModel.get(0).coord)
                }
            }
        }
    }

    ListModel {
        id: favoritesModel
    }

    ListModel {
        id: recentItemsModel
    }

    MySelectionDialog {
        id: query
        model: suggestionModel
        delegate: SuggestionDelegate {
            onClicked: {
                query.selectedIndex = index
                query.accept()
            }
        }

        onAccepted: {
            updateLocation(suggestionModel.get(selectedIndex).label,
                            suggestionModel.get(selectedIndex).coord)
        }
        onRejected: {}
    }

    FavoriteRecentItemSelectionDialog {
        id: favoriteQuery
        model: favoritesModel
        delegate: FavoritesDelegate {
            onClicked: {
                favoriteQuery.selectedRecentItemIndex = -1
                favoriteQuery.selectedFavoriteIndex = index
                favoriteQuery.accept()
            }
        }
        model2: recentItemsModel
        delegate2: RecentItemDelegate {
            onClicked: {
                favoriteQuery.selectedFavoriteIndex = -1
                favoriteQuery.selectedRecentItemIndex = index
                favoriteQuery.accept()
            }
        }

        onAccepted: {
            if(selectedRecentItemIndex == -1) {
                /* if positionsource used */
                if(selectedFavoriteIndex == 0) {
                    if(positionSource.position.latitudeValid && positionSource.position.longitudeValid) {
                        Reittiopas.get_reverse_geocode(positionSource.position.coordinate.latitude.toString(),
                                                                                positionSource.position.coordinate.longitude.toString(),
                                                                                currentLocationModel,
                                                                                Storage.getSetting('api'))
                    }
                    else {
                        favoriteQuery.selectedIndex = -1
                        displayPopupMessage( qsTr("Positioning service disabled from application settings") )
                    }
                }
                else {
                    updateLocation(favoritesModel.get(selectedFavoriteIndex).modelData,
                                   favoritesModel.get(selectedFavoriteIndex).coord)
                }
            }
            else {
                updateLocation(recentItemsModel.get(selectedRecentItemIndex).modelData,
                               recentItemsModel.get(selectedRecentItemIndex).coord)
            }
        }
    }

    Timer {
        id: suggestionTimer
        interval: 1200
        repeat: false
        triggeredOnStart: false
        onTriggered: {
            if(textfield.acceptableInput) {
                Reittiopas.get_geocode(textfield.text, suggestionModel, regions.getRegion())
            }
        }
    }

    Item {
        id: labelContainer
        anchors.rightMargin: 5
        height: label.height
        width: label.width + count.width
        Rectangle {
            height: parent.height
            width: label.width + count.width
            color: Theme.secondaryHighlightColor
            z: -1
            visible: labelMouseArea.pressed
        }
        Text {
            id: label
            font.pixelSize: 36 * Theme.pixelRatio
            color: Theme.highlightColor
            lineHeightMode: Text.FixedHeight
            lineHeight: font.pixelSize * 1.1 * Theme.pixelRatio
            anchors.left: parent.left
        }
        Bubble {
            id: count
            count: suggestionModel.count
            visible: (suggestionModel.count > 1)
            anchors.left: label.right
            anchors.leftMargin: 2
            anchors.verticalCenter: label.verticalCenter
        }

        MouseArea {
            id: labelMouseArea
            anchors.fill: parent
            enabled: (suggestionModel.count > 1)
            onClicked: {
                if(suggestionModel.count > 1) {
                    query.open()
                    textfield.focus = false
                }
            }
        }
    }

    Item {
        width: parent.width
        height: textfield.height
        MyTextfield {
            id: textfield
            anchors.left: parent.left
            anchors.right: disable_favorites ? parent.right : favoritePicker.left
            placeholderText: qsTr("Type a location")

            onTextChanged: {
                if (text.length === 0) {
                    clear()
                }
                else if(text != destination_name) {
                    suggestionModel.clear()
                    selected_favorite = -1
                    destination_coord = ""
                    destination_name = ""
                    locationDone("","")

                    if(acceptableInput)
                        suggestionTimer.restart()
                    else
                        suggestionTimer.stop()
                }
            }
            Rectangle {
                id: statusIndicator
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: -8
                smooth: true
                radius: 10 * Theme.pixelRatio
                height: 20 * Theme.pixelRatio
                width: 20 * Theme.pixelRatio
                opacity: 0.6
            }

            BusyIndicator {
                id: busyIndicator
                running: !suggestionModel.done
                anchors.centerIn: statusIndicator // Place this similarly to statusIndicator
                size: BusyIndicatorSize.Small
                MouseArea {
                    id: spinnerMouseArea
                    anchors.fill: parent
                    onClicked: {
                        suggestionModel.source = ""
                    }
                }
            }
            Keys.onReturnPressed: {
                textfield.focus = false
                parent.focus = true
            }
        }

        IconButton {
            id: favoritePicker
            enabled: !disable_favorites
            visible: !disable_favorites
            icon.source: (selected_favorite == 0) || (selected_favorite == -1) ? "image://theme/icon-m-favorite" : "image://theme/icon-m-favorite-selected"
            anchors.right: parent.right
            anchors.verticalCenter: textfield.verticalCenter
            anchors.verticalCenterOffset: -8
            onClicked: {
                favoritesModel.clear()
                Favorites.getFavorites(favoritesModel)
                favoritesModel.insert(0, {modelData: qsTr("Current location"),coord:"0,0"})
                recentItemsModel.clear()
                RecentItems.getRecentItems(recentItemsModel)
                favoriteQuery.open()
            }
            onPressAndHold: {
                if(destination_coord && favoriteQuery.selectedFavoriteIndex <= 0) {
                    if(("OK" == Favorites.addFavorite(textfield.text, destination_coord))) {
                        favoritesModel.clear()
                        Favorites.getFavorites(favoritesModel)
                        favoriteQuery.selectedFavoriteIndex = favoritesModel.count
                        displayPopupMessage( qsTr("Location added to favorite places") )
                    } else {
                        displayPopupMessage(qsTr("Location already in the favorite places"))
                    }

                }
            }
        }
    }
}
