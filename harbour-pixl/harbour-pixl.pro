# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-pixl

CONFIG += sailfishapp
QT += dbus

SOURCES += src/harbour-pixl.cpp

OTHER_FILES += qml/harbour-pixl.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-pixl.changes.in \
    rpm/harbour-pixl.spec \
    rpm/harbour-pixl.yaml \
    harbour-pixl.desktop \
    qml/pages/about.qml \
    qml/pages/about2.qml \
    qml/components/food.qml \
    qml/components/animal.qml \
    qml/pages/data.js \
    qml/pages/aboutanimal.qml \
    qml/components/dialog.qml \
    qml/pages/help.qml \
    qml/components/dialog_reset.qml \
    qml/components/heart.qml \
    qml/pages/settings.qml \
    qml/components/dialog_firstupload.qml \
    qml/pages/invite.qml \
    qml/pages/logview.qml

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/harbour-pixl-de.ts

HEADERS +=

RESOURCES +=

