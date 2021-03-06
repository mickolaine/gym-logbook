import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent

        PullDownMenu {
            MenuItem {
                text: qsTr("About...")
                onClicked: pageStack.push(Qt.resolvedUrl("About.qml"))
            }
            /*MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("Settings.qml"))
            }*/
        }

        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge
            PageHeader {
                title: qsTr("Gym Logbook")
            }

            BackgroundItem {
                id: backgroundworkouts

                Label {
                    x: Theme.paddingLarge
                    text:qsTr("Workout routines")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeExtraLarge
                }

                onClicked: pageStack.push(Qt.resolvedUrl("WorkoutList.qml"))
            }

            BackgroundItem {
                id: backgroundexercises

                Label {
                    x: Theme.paddingLarge
                    text:qsTr("Exercises")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeExtraLarge
                }

                onClicked: pageStack.push(Qt.resolvedUrl("ExerciseList.qml"))
            }

        }
    }
    Component.onCompleted: { DB.open(); DB.updateDB(); }
}


