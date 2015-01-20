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
TARGET = gymlogbook

CONFIG += sailfishapp

SOURCES += src/gymlogbook.cpp

OTHER_FILES += qml/gymlogbook.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/gymlogbook.spec \
    rpm/gymlogbook.yaml \
    translations/*.ts \
    qml/Database.js \
    qml/pages/NewSet.qml \
    Readme.md \
    qml/pages/Exercise.qml \
    qml/pages/ExerciseList.qml \
    qml/pages/NewExercise.qml \
    qml/pages/NewWorkout.qml \
    LICENSE.txt \
    qml/pages/EditWorkout.qml \
    qml/pages/WorkoutList.qml \
    qml/pages/EditDay.qml \
    qml/pages/SelectExercise.qml \
    qml/pages/ShowWorkout.qml \
    gymlogbook.desktop \
    rpm/gymlogbook.changes \
    qml/pages/About.qml \
    qml/pages/Settings.qml

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n
#TRANSLATIONS += translations/gymlogbook-de.ts

