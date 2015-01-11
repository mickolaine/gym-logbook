import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string dbname
    acceptPending: true
    acceptDestination: Qt.resolvedUrl("EditWorkout.qml")
    acceptDestinationProperties: {dbname:page.dbname}

    onOpened: DB.addworkout(days);
    onDone: {
        page.dbname = DB.newWorkout(name.text, info.text, split.value);
    }

    onRejected: model.clear()

    function getTable() {
        return page.dbname;
    }

    ListModel {
        id: days
    }

    SilicaFlickable {
        //contentHeight: page.height

        id: entry
        anchors.fill: parent

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Workout")
            }

            TextField {
                id: name
                x: Theme.paddingLarge
                label: "Name"
                placeholderText: "Name"
                width: parent.width
                focus: true
            }

            TextArea {
                id: info
                x: Theme.paddingLarge
                label: "Additional information"
                placeholderText: "Additional information"
                width: parent.width
                focus: true
            }

            Label {
                id: workoutslabel
                x: Theme.paddingLarge
                text: qsTr("How many different workouts:")
                width: parent.width
            }

            /*Button {
                id: addworkout
                x: Theme.paddingLarge
                text: qsTr("Add workout")
                onClicked: DB.addworkout(days)
            }*/

            SilicaListView {
                id: listView
                model: days

                spacing: Theme.paddingLarge
                width: parent.width
                //anchors.horizontalCenter: parent.horizontalCenter

                anchors.bottom: parent.bottom

                delegate: ListItem {
                    id: delegate

                    TextField {
                        id: daylabel
                        x: Theme.paddingLarge
                        label: model.day
                        placeholderText: model.day
                        width: parent.width - 2*pause.width
                    }

                    IconButton {
                        id: pause
                        anchors.left: daylabel.right
                        icon.source: "image://theme/icon-l-add"
                        onClicked: DB.addworkout(days)
                    }
                }
            }
        }
    }
}




