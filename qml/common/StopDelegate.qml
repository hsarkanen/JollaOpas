import QtQuick 1.1
import "UIConstants.js" as UIConstants
import "ExtrasConstants.js" as ExtrasConstants

Component {
    id: stopDelegate
    Item {
        id: stop_item
        height: UIConstants.LIST_ITEM_HEIGHT_SMALL * appWindow.scaling_factor
        width: parent.width
        opacity: 0.0

        Component.onCompleted: PropertyAnimation {
            target: stop_item
            property: "opacity"
            to: 1.0
            duration: 125
        }
        BorderImage {
            height: parent.height
            width: appWindow.width
            anchors.horizontalCenter: parent.horizontalCenter
            visible: mouseArea.pressed
            source: theme.inverted ? '../../images/background.png': '../../images/background.png'
        }
        Column {
            id: time_column
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 100
            Text {
                id: diff
                anchors.right: time.right
                horizontalAlignment: Qt.AlignRight
                text: "+" + time_diff + " min"
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_SMALL * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
            Text {
                id: time
                text: (index === 0)? Qt.formatTime(departure_time, "hh:mm") : Qt.formatTime(arrival_time, "hh:mm")
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_LARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_FOREGROUND : UIConstants.COLOR_INVERTED_FOREGROUND
            }
        }
        Column {
            anchors.right: parent.right
            anchors.left: time_column.right
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: name
                width: parent.width
                horizontalAlignment: Qt.AlignRight
                elide: Text.ElideRight
                font.pixelSize: UIConstants.FONT_XLARGE * appWindow.scaling_factor
                color: !theme.inverted ? UIConstants.COLOR_SECONDARY_FOREGROUND : UIConstants.COLOR_INVERTED_SECONDARY_FOREGROUND
            }
        }
        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {}
        }
    }
}