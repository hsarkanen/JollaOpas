TARGET=harbour-jollaopas
include(version.pri)
include(common.pri)
QT            += qml quick core network
CONFIG        += link_pkgconfig
CONFIG        += sailfishapp
PKGCONFIG     += qdeclarative5-boostable

CONFIG(release, debug|release):DEFINES += QT_NO_DEBUG_OUTPUT

QML_IMPORT_PATH = qml

OTHER_FILES += \
    qml/js/*.js \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/pages/AboutDialog.qml.in \
    qml/main.qml \
    harbour-jollaopas.desktop \
    rpm/harbour-jollaopas.yaml \
    rpm/harbour-jollaopas.spec \
    appicons/86x86/apps/harbour-jollaopas.png \
    appicons/108x108/apps/harbour-jollaopas.png \
    appicons/128x128/apps/harbour-jollaopas.png \
    appicons/172x172/apps/harbour-jollaopas.png \
    appicons/256x256/apps/harbour-jollaopas.png

appicons.files = appicons/*
appicons.path = /usr/share/icons/hicolor

INSTALLS += appicons

localization.files = localization
localization.path = /usr/share/$${TARGET}

INSTALLS += localization

lupdate_only{
SOURCES += \
    qml/pages/*.qml \
    qml/components/*.qml \
    qml/pages/AboutDialog.qml.in \
    qml/main.qml

TRANSLATIONS += \
    localization/fi.ts
}

HEADERS += \
    libmqtt/qmqtt_global.h \
    libmqtt/qmqtt.h \
    src/qmlmqttclient.h \
    src/qmlmqttsubscription.h \


PUBLIC_HEADERS += \
    libmqtt/qmqtt_client.h \
    libmqtt/qmqtt_frame.h \
    libmqtt/qmqtt_message.h \
    libmqtt/qmqtt_routesubscription.h \
    libmqtt/qmqtt_routedmessage.h \
    libmqtt/qmqtt_router.h \
    libmqtt/qmqtt_networkinterface.h \
    libmqtt/qmqtt_socketinterface.h \
    libmqtt/qmqtt_timerinterface.h

PRIVATE_HEADERS += \
    libmqtt/qmqtt_client_p.h \
    libmqtt/qmqtt_message_p.h \
    libmqtt/qmqtt_network_p.h \
    libmqtt/qmqtt_socket_p.h \
    libmqtt/qmqtt_ssl_socket_p.h \
    libmqtt/qmqtt_timer_p.h \
    libmqtt/qmqtt_websocket_p.h \
    libmqtt/qmqtt_websocketiodevice_p.h

SOURCES += \
    libmqtt/qmqtt_client_p.cpp \
    libmqtt/qmqtt_client.cpp \
    libmqtt/qmqtt_frame.cpp \
    libmqtt/qmqtt_message.cpp \
    libmqtt/qmqtt_network.cpp \
    libmqtt/qmqtt_routesubscription.cpp \
    libmqtt/qmqtt_router.cpp \
    libmqtt/qmqtt_socket.cpp \
    libmqtt/qmqtt_ssl_socket.cpp \
    libmqtt/qmqtt_timer.cpp \
    libmqtt/qmqtt_websocket.cpp \
    libmqtt/qmqtt_websocketiodevice.cpp

HEADERS += $$PUBLIC_HEADERS $$PRIVATE_HEADERS
RESOURCES += \
    jollaopas.qrc

SOURCES += src/main.cpp \
    src/qmlmqttclient.cpp \
    src/qmlmqttsubscription.cpp \

INCLUDEPATH += \
    src 

include(version.pri)
include(common.pri)
configure($${PWD}/qml/pages/AboutDialog.qml.in)

desktop.files = harbour-jollaopas.desktop
