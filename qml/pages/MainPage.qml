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
import "../js/UIConstants.js" as UIConstants
import "../js/reittiopas.js" as Reittiopas
import "../js/storage.js" as Storage
import "../js/helper.js" as Helper
import "../js/favorites.js" as Favorites
import "../js/recentitems.js" as RecentItems
import "../components"

Page {
    id: mainPage

    /* Current location acquired with GPS */
    property string currentCoord: ''
    property string currentName: ''

    /* Values entered in "To" field */
    property string toCoord: ''
    property string toName: ''

    /* Values entered in "From" field */
    property string fromCoord: ''
    property string fromName: ''

    property bool searchButtonDisabled: false

    property bool endpointsValid: (toCoord.length > 0 && (fromCoord.length > 0 || currentCoord.length > 0))

    onEndpointsValidChanged: {
        /* if we receive coordinates we are waiting for, start route search */
        if(state == "waiting_route" && endpointsValid) {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
            state = "normal"
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Activating) {
            appWindow.coverAlignment = Text.AlignHCenter
            appWindow.coverHeader = 'JollaOpas'
            appWindow.coverContents = appWindow.currentApi.charAt(0).toUpperCase() + appWindow.currentApi.slice(1)

            searchButtonDisabled = Storage.getSetting("search_button_disabled") == "true" ? true : false

            // Prevent the keyboard to popup instantly when swithcing back to mainPage
            mainPage.forceActiveFocus()
        }
    }

    function refreshFavoriteRoutes() {
            favoriteRoutesModel.clear()
            Favorites.getFavoriteRoutes('normal', appWindow.currentApi, favoriteRoutesModel)
    }

    function newRoute(name, coord) {
        /* clear all other pages from the stack */
        while(pageStack.depth > 1)
            pageStack.pop(null, true)

        /* bring application to front */
        QmlApplicationViewer.showFullScreen()

        /* Update time */
        timeSwitch.setTimeNow()

        /* Update new destination to "to" */
        to.updateLocation(name, 0, coord)

        /* Remove user input location and use gps location */
        from.clear()

        /* use current location if available - otherwise wait for it */
        if(currentCoord != "") {
            var parameters = {}
            setRouteParameters(parameters)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
        else {
            state = "waiting_route"
        }
    }

    Component.onCompleted: {
        timeSwitch.setTimeNow()
        appWindow.currentApi = Storage.getSetting("api")
        refreshFavoriteRoutes()
    }

    states: [
        State {
            name: "normal"
        },
        State {
            name: "waiting_route"
        }
    ]

    state: "normal"

    function setRouteParameters(parameters) {
        var walking_speed = Storage.getSetting("walking_speed")
        var change_margin = Storage.getSetting("change_margin")
        var change_reluctance = Storage.getSetting("change_reluctance")
        var walk_reluctance = Storage.getSetting("walk_reluctance")
        var currentDate = new Date()

        // Only add to recentitems if the place is not from favorites and
        // user specified start point
        if (fromName && from.selected_favorite < 0) {
            RecentItems.addRecentItem(fromName, fromCoord)
        }
        if (toName && to.selected_favorite < 0) {
            RecentItems.addRecentItem(toName, toCoord)
        }

        parameters.from_name = fromName ? fromName : currentName
        parameters.from = fromCoord ? fromCoord : currentCoord
        parameters.to_name = toName
        appWindow.fromName = parameters.from_name
        appWindow.toName = parameters.to_name
        parameters.to = toCoord

        if (timeSwitch.timeNow) {
            parameters.jstime = currentDate
        }
        else if (timeSwitch.dateToday) {
            currentDate.setHours(timeSwitch.myTime.getHours())
            currentDate.setMinutes(timeSwitch.myTime.getMinutes())
            parameters.jstime = currentDate
        }
        else {
            parameters.jstime = timeSwitch.myTime
        }
        parameters.timetype = "departure"
        if (!timeTypeSwitch.departure) {
            parameters.arriveBy = true
            parameters.timetype = "arrival"
        }
        parameters.walk_speed = walking_speed == "Unknown" ? "70" : walking_speed
        parameters.change_margin = change_margin == "Unknown" ? "3" : Math.floor(change_margin)
        parameters.change_reluctance = change_reluctance == "Unknown" ? "10" : Math.floor(change_reluctance)
        parameters.walk_reluctance = walk_reluctance == "Unknown" ? "2" : Math.floor(walk_reluctance)

        parameters.modes = ""
        if (Storage.getSetting("bus_disabled") === "false") {
            parameters.modes += "{mode:BUS},";
        }
        if (Storage.getSetting("tram_disabled") === "false") {
            parameters.modes += "{mode:TRAM},";
        }
        if (Storage.getSetting("metro_disabled") === "false") {
            parameters.modes += "{mode:SUBWAY},"
        }
        if (Storage.getSetting("train_disabled") === "false") {
            parameters.modes += "{mode:RAIL},";
        }
        if (Storage.getSetting("ferry_disabled") === "false") {
            parameters.modes += "{mode:FERRY},";
        }
        parameters.modes += "{mode:WALK}"
    }

    Rectangle {
        id: waiting
        color: "black"
        z: 250
        opacity: mainPage.state == "normal" ? 0.0 : 0.7

        Behavior on opacity {
            PropertyAnimation { duration: 200 }
        }

        anchors.fill: parent
        MouseArea {
            anchors.fill: parent
            enabled: mainPage.state != "normal"
            onClicked: mainPage.state = "normal"
        }
    }

    BusyIndicator {
        id: busyIndicator
        z: 260
        running: mainPage.state != "normal"
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: parent.height

        PullDownMenu {
            MenuItem { text: qsTr("Settings"); onClicked: { pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) } }
            MenuItem { text: qsTr("Manage favorite places"); onClicked: pageStack.push(Qt.resolvedUrl("FavoritesPage.qml")) }
            MenuItem {
                enabled: endpointsValid
                text: qsTr("Add as favorite route");
                onClicked: {
                    var fromNameToAdd = fromName ? fromName : currentName
                    var fromCoordToAdd = fromCoord ? fromCoord : currentCoord
                    var res = Favorites.addFavoriteRoute('normal', appWindow.currentApi, fromCoordToAdd, fromNameToAdd, toCoord, toName, favoriteRoutesModel)
                    if (res === "OK") {
                        displayPopupMessage(qsTr("Favorite route added"))
                    }
                    else {
                        displayPopupMessage(qsTr("Maximum amount of favorite routes is 4!"))
                    }
                }
            }
            MenuItem {
                visible: searchButtonDisabled
                enabled: endpointsValid
                text: qsTr("Search");
                onClicked: {
                    var parameters = {}
                    setRouteParameters(parameters)
                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }
            }
        }

        Spacing { id: topSpacing; anchors.top: parent.top; height: Theme.paddingMedium }

        Column {
            id: content_column
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: topSpacing.bottom

            Item {
                width: parent.width
                height: from.height + to.height

                LocationEntry {
                    id: from
                    type: qsTr("From")
                    isFrom: true
                    onLocationDone: {
                        fromName = name
                        fromCoord = coord
                    }
                    onCurrentLocationDone: {
                        currentName = name
                        currentCoord = coord
                    }
                    onLocationError: {
                        /* error in getting current position, cancel the wait */
                        mainPage.state = "normal"
                    }
                }

                Spacing { id: location_spacing; anchors.top: from.bottom; height: 5 }

                SwitchLocation {
                    anchors.top: from.top
                    anchors.topMargin: from.height - location_spacing.height - UIConstants.DEFAULT_MARGIN // Hack to place switch between `from` and `to` LocationEntries
                    z: 1
                    from: from
                    to: to
                }

                LocationEntry {
                    id: to
                    type: qsTr("To")
                    onLocationDone: {
                        toName = name
                        toCoord = coord
                    }
                    anchors.top: location_spacing.bottom
                }
            }

            TimeTypeSwitch {
                id: timeTypeSwitch
            }
            Spacing { height: 5 * Theme.pixelRatio }
            TimeSwitch {
                id: timeSwitch
            }
            Spacing { height: 5 * Theme.pixelRatio }

            Button {
                visible: !searchButtonDisabled
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: endpointsValid
                text: qsTr("Search")
                onClicked: {
                    var parameters = {}
                    setRouteParameters(parameters)
                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }
            }
        }

        Spacing { id: favorites_spacing; anchors.top: content_column.bottom; height: 5 * Theme.pixelRatio }

        Item {
            id: headeritem
            width: parent.width
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: favorites_spacing.bottom
            height: (favoriteRouteHeader.height + UIConstants.DEFAULT_MARGIN) * Theme.pixelRatio
            Text {
                id: favoriteRouteHeader
                color: Theme.highlightColor
                font.pixelSize: 36 * Theme.pixelRatio
                text: qsTr("Favorite routes")
            }
        }

        SilicaListView {
            id: favoriteRouteList
            anchors.top: headeritem.bottom
            anchors.bottom: parent.bottom
            spacing: 5 * Theme.pixelRatio
            width: parent.width
            model: favoriteRoutesModel
            delegate: favoriteRouteManageDelegate
            property Item contextMenu

            ViewPlaceholder {
                enabled: favoriteRouteList.count == 0
                // Not perfect, but shows the text on Jolla Phone, Jolla Tablet and Fairphone2 (was -300)
                verticalOffset: (favoriteRouteList.height - mainPage.height) * 0.5
                text: qsTr("No saved favorite routes")
            }

            Component {
                id: contextMenuComponent

                ContextMenu {
                    id: menu
                    property Item currentItem
                    MenuItem {
                        text: qsTr("Add to Cover")
                        onClicked: menu.currentItem.addToCover()
                    }
                    MenuItem {
                        text: qsTr("Remove")
                        onClicked: menu.currentItem.remove()
                    }
                }
            }
        }

        ListModel {
            id: favoriteRoutesModel
        }

        Component {
            id: favoriteRouteManageDelegate

            BackgroundItem {
                id: rootItem
                width: ListView.view.width
                height: menuOpen ? Theme.itemSizeSmall + favoriteRouteList.contextMenu.height : Theme.itemSizeSmall

                property bool menuOpen: favoriteRouteList.contextMenu != null && favoriteRouteList.contextMenu.parent === rootItem

                function addToCover() {
                    Favorites.addFavoriteRoute('cover', appWindow.currentApi, modelFromCoord, modelFromName, modelToCoord, modelToName)
                    displayPopupMessage( qsTr("Favorite route added to cover action.") )
                }

                function remove() {
                    remorse.execute(rootItem, qsTr("Deleting"), function() {
                        Favorites.deleteFavoriteRoute(modelRouteIndex, appWindow.currentApi, favoriteRoutesModel)
                    })
                }

                onClicked:{
                    var parameters = {}
                    setRouteParameters(parameters)
                    parameters.from_name = modelFromName
                    parameters.from = modelFromCoord
                    parameters.to_name = modelToName
                    parameters.to = modelToCoord
                    appWindow.fromName = parameters.from_name
                    appWindow.toName = parameters.to_name
                    pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                }

                onPressAndHold: {
                    if (!favoriteRouteList.contextMenu) {
                        favoriteRouteList.contextMenu = contextMenuComponent.createObject(favoriteRouteList)
                    }

                    favoriteRouteList.contextMenu.currentItem = rootItem
                    favoriteRouteList.contextMenu.open(rootItem)
                }

                Label {
                    id: label
                    height: Theme.itemSizeSmall
                    text: modelFromName + " - " + modelToName + " "
                    width: parent.width - reverseFavoriteRouteButton.width
                    color: Theme.primaryColor
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                }

                IconButton {
                    id: reverseFavoriteRouteButton
                    anchors.right: parent.right
                    icon.source: "image://theme/icon-m-shuffle"
                    onClicked:{
                        var parameters = {}
                        setRouteParameters(parameters)
                        parameters.from_name = modelToName
                        parameters.from = modelToCoord
                        parameters.to_name = modelFromName
                        parameters.to = modelFromCoord
                        appWindow.fromName = parameters.from_name
                        appWindow.toName = parameters.to_name
                        pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
                    }
                }
                RemorseItem { id: remorse }
            }
        }
    }

    // Added InfoBanner here as a workaround to display it correctly above all other UI elements, fixing the z-order from the one in main.qml isn't trivial
    InfoBanner {
        id: infoBanner
        z: 1
    }
    function displayPopupMessage(message) {
        infoBanner.displayError(message)
    }
}
