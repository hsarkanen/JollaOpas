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
import "../js/storage.js" as Storage
import "../js/favorites.js" as Favorites

CoverBackground {
    Label {
        id: coverHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: Theme.paddingSmall
        anchors.horizontalCenter: parent.horizontalCenter
        maximumLineCount: 2
        horizontalAlignment: Text.AlignHCenter
        color: Theme.highlightColor
        text: appWindow.coverHeader
        wrapMode: Text.Wrap
    }

    Label {
        id: label
        anchors.top: coverHeader.bottom
        anchors.left: parent.left
        anchors.margins: Theme.paddingSmall
        anchors.horizontalCenter: parent.horizontalCenter
        maximumLineCount: 6
        horizontalAlignment: appWindow.coverAlignment
        font.pixelSize: Theme.fontSizeSmall
        text: appWindow.coverContents
        elide: Text.ElideRight
        wrapMode: Text.NoWrap
        clip: true
    }

    CoverActionList {
        id: coverAction

        CoverAction {
            iconSource: "image://theme/icon-cover-favorite"
            onTriggered: {
                startCoverSearch("straight")
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-shuffle"
            onTriggered: {
                startCoverSearch("reverse")
            }
        }
    }

    function startCoverSearch(direction) {
        pageStack.clear()
        appWindow.activate()
        var coverRoutesItem = []
        var res = Favorites.getFavoriteRoutes('cover', Storage.getSetting("api"), coverRoutesItem)
        if (res == "Unknown") {
            appWindow.mainPage = pageStack.push(Qt.resolvedUrl("MainPage.qml"))
            appWindow.mainPage.displayPopupMessage( qsTr("Please save a route and add it to cover action by long-press.") )
        }
        else {
            var parameters = {}
            var walking_speed = Storage.getSetting("walking_speed")
            var change_margin = Storage.getSetting("change_margin")
            var change_reluctance = Storage.getSetting("change_reluctance")
            var walk_reluctance = Storage.getSetting("walk_reluctance")
            parameters.modes = ""

            parameters.from_name = direction == "straight" ? coverRoutesItem.modelFromName : coverRoutesItem.modelToName
            parameters.from = direction == "straight" ? coverRoutesItem.modelFromCoord : coverRoutesItem.modelToCoord
            parameters.to_name = direction == "straight" ? coverRoutesItem.modelToName : coverRoutesItem.modelFromName
            parameters.to = direction == "straight" ? coverRoutesItem.modelToCoord : coverRoutesItem.modelFromCoord

            parameters.jstime = new Date()
            parameters.timetype = "departure"
            parameters.walk_speed = walking_speed == "Unknown"?"70":walking_speed
            parameters.change_margin = change_margin == "Unknown"?"3":Math.floor(change_margin)
            parameters.change_reluctance = change_reluctance == "Unknown"?"10":Math.floor(change_reluctance)
            parameters.walk_reluctance = walk_reluctance == "Unknown"?"2":Math.floor(walk_reluctance)

            if(Storage.getSetting("bus_disabled") === "false") {
                parameters.modes += "BUS,";
            }
            if(Storage.getSetting("tram_disabled") === "false") {
                parameters.modes += "TRAM,";
            }
            if(Storage.getSetting("metro_disabled") === "false") {
                parameters.modes += "SUBWAY,"
            }
            if(Storage.getSetting("train_disabled") === "false") {
                parameters.modes += "RAIL,";
            }
            if(Storage.getSetting("ferry_disabled") === "false") {
                parameters.modes += "FERRY,";
            }
            parameters.modes += "WALK"

            appWindow.mainPage = pageStack.push(Qt.resolvedUrl("MainPage.qml"), {}, PageStackAction.Immediate)
            pageStack.push(Qt.resolvedUrl("ResultPage.qml"), { search_parameters: parameters })
        }
    }
}
