import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string table
    property string type

    property string id

    DatePicker {
        id: datepicker
        visible: false
    }

    function loadValues() {

        if (typeof page.id == "string") {

            var values = DB.getSet(page.table, page.id);

            console.log(values[0])

            datepicker.date = new Date(values[0], values[1]-1, values[2], 0, 0, 0);
            sets.text = values[3];
            reps.text = values[4];
            weight.text = values[6];
            status.value = values[7];
        }
    }

    onAccepted: {
        if (typeof page.id == "string") {
            DB.updateSet(page.id, page.table, datepicker.year, datepicker.month, datepicker.day, sets.text, reps.text, weight.text, 0, status.value);
        }
        else {
            DB.newSet(page.table, datepicker.year, datepicker.month, datepicker.day, sets.text, reps.text, weight.text, 0, status.value);
        }
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
                title: qsTr("New set")
            }

            Component {
                id: pickerComponent
                DatePickerDialog {
                    id: datedialog
                }
            }


            TextField {
                id: datefield
                width: 250
                x: Theme.paddingLarge
                text: datepicker.dateText
                label: qsTr("Date")
                placeholderText: qsTr("Date")
                EnterKey.onClicked: parent.focus = true

                onClicked: {
                    var dialog = pageStack.push(pickerComponent, datepicker.date)
                    dialog.accepted.connect(function() {
                        datefield.text = dialog.dateText
                    })
                }
            }


            TextField {
                id: sets
                width: 120
                x: Theme.paddingLarge
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Sets")
                placeholderText: qsTr("Sets")
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: reps
                width: 120
                x: Theme.paddingLarge
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Reps")
                placeholderText: qsTr("Reps")
                EnterKey.onClicked: parent.focus = true
            }

            TextField {
                id: weight
                width: 250
                x: Theme.paddingLarge
                inputMethodHints: Qt.ImhFormattedNumbersOnly
                label: qsTr("Weight")
                placeholderText: qsTr("Weight")
                EnterKey.onClicked: parent.focus = true
            }

            ComboBox {
                id: status
                x: Theme.paddingLarge
                width: 480
                label: "Status"
                description: qsTr("Status")
                menu: ContextMenu {
                    MenuItem { text: "Not done" }
                    MenuItem { text: "Done" }
                    MenuItem { text: "Fail" }
                }
            }
        }
        Component.onCompleted: page.loadValues()
    }
}





