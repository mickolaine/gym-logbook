import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Dialog {
    id: page
    property string table
    property string type

    onAccepted: {

        DB.newSet(page.table, datepicker.year, datepicker.month, datepicker.day, sets.text, reps.text, weight.text, 0, status.value)
    }

    DatePicker {
        id: datepicker
        visible: false
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
    }
}





