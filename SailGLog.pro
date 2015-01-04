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
TARGET = SailGLog

CONFIG += sailfishapp

SOURCES += src/SailGLog.cpp

OTHER_FILES += qml/SailGLog.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/SailGLog.changes.in \
    rpm/SailGLog.spec \
    rpm/SailGLog.yaml \
    translations/*.ts \
    SailGLog.desktop \
    qml/pages/NewProgram.qml \
    qml/pages/NewExcercise.qml \
    qml/pages/Workouts.qml \
    qml/Database.js \
    qml/pages/ExcerciseList.qml \
    qml/pages/Excercise.qml \
    qml/pages/NewSet.qml \
    Readme.md

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n
TRANSLATIONS += translations/SailGLog-de.ts

