import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Calculators")
            }

            BackgroundItem {
                id: backgroundworkouts

                Label {
                    x: Theme.paddingLarge
                    text:qsTr("Jim Wendler 5/3/1")
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: Theme.fontSizeExtraLarge
                }

                onClicked: pageStack.push(Qt.resolvedUrl("Wendler.qml"))
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

}

