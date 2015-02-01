import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string table
    property string name
    property string info
    property string type

    onOpened: {
        if (page.table !== ""){
            var data = DB.getExerciseByTable(table);
            name.text = data[0];
            info.text = data[1];
            if (data[2] === "Weight") {
                type.currentIndex = 0;
            } else if (data[2] === "Time") {
                type.currentIndex = 1;
            }
        }
    }

    onAccepted: {
        DB.updateExercise(name.text, info.text, type.value, page.table);
        pageStack.find( function(p) {
            try { p.refresh(); } catch (e) {};
            return false;
        } );
    }

    onRejected: model.clear()

    SilicaFlickable {
        contentHeight: column.height
        id: entry
        anchors.fill: parent

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Edit exercise")
            }

            TextField {
                id: name
                x: Theme.paddingLarge
                label: "Name"
                labelVisible: true
                placeholderText: "Name, eg. Bench press"
                width: parent.width
                focus: true
            }

            TextArea {
                id: info
                x: Theme.paddingLarge
                label: "Additional information"
                labelVisible: true
                placeholderText: "Additional information"
                width: parent.width
                focus: true
            }

            ComboBox {
                id: type
                x: Theme.paddingLarge
                width: 480
                label: "Measure:"
                description: qsTr("Type of the exercise.")
                menu: ContextMenu {
                    MenuItem { text: "Weight" }
                    MenuItem { text: "Time" }
                }
            }
        }
    }
}





