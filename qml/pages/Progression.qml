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
        var data = DB.getExerciseByTable(table);
        page.name = data[0];
        page.info = data[1];
    }

    onAccepted: {
        pageStack.push(Qt.resolvedUrl("Progression2.qml"), {table:page.table,
                                                            onerm:onermvalue.text,
                                                            progression:progression.currentIndex,
                                                            date:datepicker.date,
                                                            days:days.text,
                                                            linear:[sets.text, reps.text],
                                                            wendler:[wendlerswitch.checked]})
    }

    DatePicker {
        id: datepicker
        visible: false
    }

    SilicaFlickable {
        contentHeight: column.height
        id: entry
        anchors.fill: parent

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Plan progression")
            }

            Label {
                id: name
                x: Theme.paddingLarge
                text: page.name
                font.pixelSize: Theme.fontSizeLarge
                width: parent.width
                focus: true
            }

            Label {
                id: info
                x: Theme.paddingLarge
                text: page.info
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall
                focus: true
            }

            TextField {
                id: onermvalue
                text: DB.get1RMSet(page.table, false)
                label: qsTr("Weight to use in calculations")
                x: Theme.paddingLarge
                width: parent.width - 2*Theme.paddingLarge
                font.pixelSize: Theme.fontSizeExtraLarge
                horizontalAlignment: Text.AlignRight
                inputMethodHints: Qt.ImhFormattedNumbersOnly
            }

            ComboBox {
                id: progression
                //x: Theme.paddingLarge
                width: 480
                label: qsTr("Progression:")
                menu: ContextMenu {
                    MenuItem { text: qsTr("Wendler 5/3/1") }
                    MenuItem { text: qsTr("Linear") }
                }
                onCurrentIndexChanged: {
                    if (currentIndex === 1) {
                        sets.visible = true;
                        reps.visible = true;
                        wendlerswitch.visible = false;
                    }
                    else if (currentIndex === 0) {
                        sets.visible = false;
                        reps.visible = false;
                        wendlerswitch.visible = true;
                    }
                }
            }
            Row {
                x: Theme.paddingLarge
                TextField {
                    id: sets
                    placeholderText: qsTr("Sets")
                    label: qsTr("Sets")
                    text: "3"
                    //x: Theme.paddingLarge
                    //width: parent.width - 2*Theme.paddingLarge
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    width: 200
                    visible: false
                }

                TextField {
                    id: reps
                    placeholderText: qsTr("Reps")
                    label: qsTr("Reps")
                    text: "5"
                    //x: Theme.paddingLarge
                    //width: parent.width - 2*Theme.paddingLarge
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    width: 200
                    visible: false
                }
            }
            TextSwitch {
                id: wendlerswitch
                text: qsTr("Only last sets for each day")
                checked: false
                visible: true
            }

            Component {
                id: pickerComponent
                DatePickerDialog {
                    id: datedialog
                }
            }

            TextField {
                id: datefield
                width: 300
                //x: Theme.paddingLarge
                text: datepicker.dateText
                label: qsTr("Starting from date")
                //placeholderText: qsTr("Date")
                EnterKey.onClicked: parent.focus = true

                onClicked: {
                    var dialog = pageStack.push(pickerComponent, datepicker.date)
                    dialog.accepted.connect(function() {
                        datefield.text = dialog.dateText;
                        datepicker.date = dialog.date;
                    })
                }
            }

            Row {
                x: Theme.paddingLarge
                Label {
                    id: label1

                    text: qsTr("Every")
                    //width: parent.width - 2*Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.secondaryColor
                }
                TextField {
                    id: days
                    text: "7"
                    //label: "kg"
                    width: 100
                    inputMethodHints: Qt.ImhFormattedNumbersOnly
                    font.pixelSize: Theme.fontSizeMedium
                    horizontalAlignment: Text.AlignRight
                }
                Label {
                    id: label2
                    text: qsTr("days")
                    //width: parent.width - 2*Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.secondaryColor
                }
            }

        }
    }
}





