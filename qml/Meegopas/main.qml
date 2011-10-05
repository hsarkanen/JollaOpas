import QtQuick 1.1
import com.nokia.meego 1.0
import com.nokia.extras 1.0

PageStackWindow {
    id: appWindow
    initialPage: mainPage

    platformStyle: PageStackWindowStyle {
        id: defaultStyle
        background: theme.inverted?'image://theme/meegotouch-video-background':''
        backgroundFillMode: Image.Stretch
    }

    MainPage{id: mainPage}
    AboutDialog { id: about }

    InfoBanner {
        id: info
        text: qsTr("Problem with the internet connection")
    }

    ToolBarLayout {
        id: commonTools
        visible: false
        ToolIcon { iconId: "toolbar-back"; onClicked: { myMenu.close(); pageStack.pop(); } }
        ToolIcon { platformIconId: "toolbar-view-menu";
             anchors.right: parent===undefined ? undefined : parent.right
             onClicked: (myMenu.status == DialogStatus.Closed) ? myMenu.open() : myMenu.close()
        }
    }

    Menu {
        id: myMenu
        visualParent: pageStack
        MenuLayout {
            MenuItem { text: "About"; onClicked: about.open() }
            //MenuItem { text: "Settings"; onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml")) }
        }
    }
}
