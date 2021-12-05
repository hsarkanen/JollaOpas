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
import "../js/recentitems.js" as RecentItems
import "../js/theme.js" as Theme
import "../components"

Page {
    SilicaFlickable {
        id: settingsContent
        anchors.fill: parent
        contentHeight: content_column.height

        VerticalScrollDecorator {}

        Component.onCompleted: {
            Storage.initialize()
            var setting = Storage.getSetting("api")
            currentApi.set_value(setting == "Unknown" ? "helsinki" : setting)
            setting = Storage.getSetting("tram_disabled")
            tramSwitch.set_value(setting == "Unknown" ? "false" : setting)
            setting = Storage.getSetting("bus_disabled")
            busSwitch.set_value(setting == "Unknown" ? "false" : setting)
            setting = Storage.getSetting("ferry_disabled")
            ferrySwitch.set_value(setting == "Unknown" ? "false" : setting)
            setting = Storage.getSetting("metro_disabled")
            metroSwitch.set_value(setting == "Unknown" ? "false" : setting)
            setting = Storage.getSetting("train_disabled")
            trainSwitch.set_value(setting == "Unknown" ? "false" : setting)
            setting = Storage.getSetting("walking_speed")
            walkingSpeed.set_value(setting == "Unknown" ? "70" : setting)
            setting = Storage.getSetting("change_margin")
            changeMargin.set_value(setting == "Unknown" ? "3" : Math.floor(setting))
            setting = Storage.getSetting("change_reluctance")
            changeReluctance.set_value(setting == "Unknown" ? "10" : Math.floor(setting))
            setting = Storage.getSetting("walk_reluctance")
            walkReluctance.set_value(setting == "Unknown" ? "2" : Math.floor(setting))
            setting = Storage.getSetting("search_interval")
            searchInterval.set_value(setting == "Unknown" ? "15" : Math.floor(setting))
            setting = Storage.getSetting("default_zoom_level")
            defaultZoomLevel.set_value(setting == "Unknown" ? "5" : Math.floor(setting))
            setting = Storage.getSetting("search_button_disabled")
            searchButtonSwitch.set_value(setting == "Unknown" ? "false" : setting)
        }

        function reset_all_defaults() {
            tramSwitch.set_value("false");
            busSwitch.set_value("false");
            ferrySwitch.set_value("false");
            metroSwitch.set_value("false");
            trainSwitch.set_value("false");
            walkingSpeed.set_value("70");
            changeMargin.set_value("3");
            changeReluctance.set_value("10");
            walkReluctance.set_value("2");
            searchInterval.set_value("15");
            defaultZoomLevel.set_value("5");
            searchButtonSwitch.set_value("false");
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Reset to defaults");
                onClicked: {
                    settingsContent.reset_all_defaults();
                }
            }
            MenuItem { text: qsTr("About"); onClicked: pageStack.push(Qt.resolvedUrl("AboutDialog.qml")) }
        }

        Column {
            id: content_column
            width: parent.width

            PageHeader {
                title: qsTr("Settings")
            }

            SectionHeader {
                text: qsTr("Region")
            }

            ComboBox {
                id: currentApi
                function set_value(value) {
                    for(var i = 0; i < regions.count; ++i) {
                        if (regions.get(i).identifier === value) {
                            currentApi.currentIndex = i;
                            break;
                        }
                    }
                }

                label: qsTr("Active region")
                menu: ContextMenu {
                    id: regionMenu

                    function set_value(text, value) {
                        Storage.setSetting("api", value)
                        appWindow.currentApi = value
                        appWindow.coverContents = text
                        busSwitch.visible = regions.getRegion().busEnabled
                        tramSwitch.visible = regions.getRegion().tramEnabled
                        trainSwitch.visible = regions.getRegion().trainEnabled
                        metroSwitch.visible = regions.getRegion().metroEnabled
                        ferrySwitch.visible = regions.getRegion().ferryEnabled
                        appWindow.mainPage.refreshFavoriteRoutes()
                    }

                    Repeater {
                        model: regions

                        delegate: MenuItem {
                            text: qsTranslate("main", model.name)
                            property string value: model.identifier
                            onClicked: regionMenu.set_value(text, value)
                        }
                    }
                }
            }

            SectionHeader {
                text: qsTr("Route search")
            }
            TextSwitch {
                id: busSwitch
                visible: regions.getRegion().busEnabled
                function updateDescription() {
                    if (busSwitch.checked)
                        busSwitch.description = qsTr("Route results will contain Buses")
                    else
                        busSwitch.description = qsTr("Route results will not contain Buses")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    busSwitch.checked = val
                    busSwitch.updateDescription()
                }
                text: qsTr("Bus")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("bus_disabled", (!checked).toString())
                    busSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: ferrySwitch
                visible: regions.getRegion().ferryEnabled
                function updateDescription() {
                    if (ferrySwitch.checked)
                        ferrySwitch.description = qsTr("Route results will contain Ferry")
                    else
                        ferrySwitch.description = qsTr("Route results will not contain Ferry")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    ferrySwitch.checked = val
                    ferrySwitch.updateDescription()
                }
                text: qsTr("Ferry")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("ferry_disabled", (!checked).toString())
                    ferrySwitch.updateDescription()
                }
            }
            TextSwitch {
                id: tramSwitch
                visible: regions.getRegion().tramEnabled
                function updateDescription() {
                    if (tramSwitch.checked)
                        tramSwitch.description = qsTr("Route results will contain Trams")
                    else
                        tramSwitch.description = qsTr("Route results will not contain Trams")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    tramSwitch.checked = val
                    tramSwitch.updateDescription()
                }
                text: qsTr("Tram")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("tram_disabled", (!checked).toString())
                    tramSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: metroSwitch
                visible: regions.getRegion().metroEnabled
                function updateDescription() {
                    if (metroSwitch.checked)
                        metroSwitch.description = qsTr("Route results will contain Metro")
                    else
                        metroSwitch.description = qsTr("Route results will not contain Metro")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    metroSwitch.checked = val
                    metroSwitch.updateDescription()
                }
                text: qsTr("Metro")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("metro_disabled", (!checked).toString())
                    metroSwitch.updateDescription()
                }
            }
            TextSwitch {
                id: trainSwitch
                visible: regions.getRegion().trainEnabled
                function updateDescription() {
                    if (trainSwitch.checked)
                        trainSwitch.description = qsTr("Route results will contain Trains")
                    else
                        trainSwitch.description = qsTr("Route results will not contain Trains")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    trainSwitch.checked = val
                    trainSwitch.updateDescription()
                }
                text: qsTr("Train")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("train_disabled", (!checked).toString())
                    trainSwitch.updateDescription()
                }
            }

            Slider {
                id: changeMargin
                function set_value(value) {
                    changeMargin.value = value
                    changeMargin.updateLabel()
                }
                function updateLabel() {
                    changeMargin.label = qsTr("Change Margin") + " (" + changeMargin.value + " " + qsTr("minutes") + ")"
                }
                width: parent.width
                minimumValue: 0
                maximumValue: 10
                value: 5
                stepSize: 1
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("change_margin", changeMargin.value)
                    changeMargin.updateLabel()
                }
            }

            Slider {
                id: changeReluctance
                function set_value(value) {
                    changeReluctance.value = value
                    changeReluctance.updateLabel()
                }
                function updateLabel() {
                    changeReluctance.label = qsTr("Change Reluctance") + " (" + changeReluctance.value + ")"
                }
                width: parent.width
                minimumValue: 1
                maximumValue: 20
                value: 10
                stepSize: 1
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("change_reluctance", changeReluctance.value)
                    changeReluctance.updateLabel()
                }
            }

            Slider {
                id: walkReluctance
                function set_value(value) {
                    walkReluctance.value = value
                    walkReluctance.updateLabel()
                }
                function updateLabel() {
                    walkReluctance.label = qsTr("Walk Reluctance") + " (" + walkReluctance.value + ")"
                }
                width: parent.width
                minimumValue: 1
                maximumValue: 20
                value: 2
                stepSize: 1
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("walk_reluctance", walkReluctance.value)
                    walkReluctance.updateLabel()
                }
            }

            ComboBox {
                id: walkingSpeed
                function set_value(value) {
                    var idx = {"70": 0, "100": 1, "120": 2, "150": 3}[value]
                    walkingSpeed.currentIndex = idx
                }

                label: qsTr("Walking speed")
                menu: ContextMenu {
                    MenuItem {
                        text: qsTr("Walking 70 m/min")
                        onClicked: Storage.setSetting('walking_speed','70')
                    }
                    MenuItem {
                        text: qsTr("Fast Walking 100 m/min")
                        onClicked: Storage.setSetting('walking_speed','100')
                    }
                    MenuItem {
                        text: qsTr("Very Fast Walking 120 m/min")
                        onClicked: Storage.setSetting('walking_speed','120')
                    }
                    MenuItem {
                        text: qsTr("Running 150 m/min")
                        onClicked: Storage.setSetting('walking_speed','150')
                    }
                }
            }

            Slider {
                id: searchInterval
                function set_value(value) {
                    searchInterval.value = value
                    searchInterval.updateLabel()
                }
                function updateLabel() {
                    searchInterval.label = qsTr("Search interval") + " (" + searchInterval.value + ")"
                }
                width: parent.width
                minimumValue: 5
                maximumValue: 120
                value: 15
                stepSize: 5
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("search_interval", searchInterval.value)
                    searchInterval.updateLabel()
                }
            }

            SectionHeader {
                text: qsTr("Map")
            }
            Slider {
                id: defaultZoomLevel
                function set_value(value) {
                    defaultZoomLevel.value = value
                    defaultZoomLevel.updateLabel()
                }
                function updateLabel() {
                    defaultZoomLevel.label = qsTr("Default zoom level") + " (" + defaultZoomLevel.value + ")"
                }
                width: parent.width
                minimumValue: 1
                maximumValue: 10
                value: 5
                stepSize: 1
                handleVisible: true
                onValueChanged: {
                    Storage.setSetting("default_zoom_level", defaultZoomLevel.value)
                    defaultZoomLevel.updateLabel()
                }
            }

            SectionHeader {
                text: qsTr("UI tweaks")
            }
            TextSwitch {
                id: searchButtonSwitch
                function updateDescription() {
                    if (searchButtonSwitch.checked)
                        searchButtonSwitch.description = qsTr("Search button is located below parameters")
                    else
                        searchButtonSwitch.description = qsTr("Search button is located in the PullDown menu")
                }

                function set_value(value) {
                    var val = !(value === "true")
                    searchButtonSwitch.checked = val
                    searchButtonSwitch.updateDescription()
                }
                text: qsTr("Search button")
                description: ""
                onCheckedChanged: {
                    Storage.setSetting("search_button_disabled", (!checked).toString())
                    searchButtonSwitch.updateDescription()
                }
            }

            SectionHeader {
                text: qsTr("Search history")
            }
            Button {
                id: clearSearchHistoryButton
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Clear search history")
                onClicked: {
                    RecentItems.deleteRecentItems()
                    // Reinitialize so the table exist when returning to the MainPage the table
                    // exists again
                    RecentItems.initialize()
                }
            }
            Spacing { height: 30 }
        }
    }
}
