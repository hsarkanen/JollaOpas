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

Dialog {
    property alias model: view.model
    property alias delegate: view.delegate
    property alias model2: view2.model
    property alias delegate2: view2.delegate

    anchors.fill: parent

    Text {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            id: favoritesheaderitem
            color: Theme.highlightColor
            z: 1
            font.pixelSize: 36 * Theme.pixelRatio
            text: qsTr("Favorites")
    }

    Spacing { id: favoritesHeaderBottomSpacer; height: 30; anchors.top: favoritesheaderitem.bottom }

    SilicaListView {
        width: parent.width
        id: view
        anchors.top: favoritesHeaderBottomSpacer.bottom
        anchors.bottom: headerTopSpacer.top

        VerticalScrollDecorator {}
    }

    Spacing { id: headerTopSpacer; height: 50; anchors.bottom: recentsearchesheaderitem.top }

    Text {
            anchors.top: parent.verticalCenter
            anchors.left: parent.left
            anchors.leftMargin: Theme.paddingSmall
            id: recentsearchesheaderitem
            color: Theme.highlightColor
            z: 1
            font.pixelSize: 36 * Theme.pixelRatio
            text: qsTr("Recent searches")
    }


    Spacing { id: recentItemsHeaderBottomSpacer; height: 30; anchors.top: recentsearchesheaderitem.bottom }

    SilicaListView {
        id: view2
        width: parent.width
        anchors.top: recentItemsHeaderBottomSpacer.bottom
        anchors.bottom: parent.bottom

        VerticalScrollDecorator {}
    }

    property int selectedFavoriteIndex
    property int selectedRecentItemIndex
}
