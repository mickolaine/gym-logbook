import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string dbname
    acceptPending: true
    acceptDestination: Qt.resolvedUrl("EditWorkout.qml")
    acceptDestinationProperties: {dbname:page.dbname}

    onOpened: {
        DB.addDay(days);
    }
    onDone: {
        page.dbname = DB.newWorkout(name.text, info.text, days);
        console.log("Check one");
        //console.log(listView.children);
    }

    onRejected: model.clear()

    function getTable() {
        console.log("Check three");
        return page.dbname;
    }

    ListModel {
        id: days
    }

    SilicaFlickable {
        contentHeight: page.height

        id: entry
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("Accept workout")
        }

        Column {
            id: column

            anchors.top: header.bottom
            width: page.width
            spacing: Theme.paddingLarge

            TextField {
                id: name
                x: Theme.paddingLarge
                label: "Name of workout plan"
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

        }

        SilicaListView {
            id: listView
            model: days

            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: column.bottom
            anchors.bottom: parent.bottom
            contentHeight: Theme.itemSizeMedium
            spacing: Theme.paddingLarge

            delegate: ListItem {
                id: delegate

                TextField {
                    id: daylabel
                    x: Theme.paddingLarge
                    label: model.day
                    placeholderText: model.day
                    width: parent.width - 1.5*add.width
                    onTextChanged: {days.set(index, {"day": text})}
                }

                IconButton {
                    id: add
                    anchors.left: daylabel.right
                    icon.source: "image://theme/icon-l-add"
                    onClicked: DB.addDay(days)
                    visible: DB.isLast(days, index)
                }
                IconButton {
                    id: del
                    anchors.left: daylabel.right
                    icon.source: "image://theme/icon-l-clear"
                    onClicked: DB.removeDay(days, index)
                    visible: !DB.isLast(days, index)
                }
            }
        }
    }
}




