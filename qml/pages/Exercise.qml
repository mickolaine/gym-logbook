/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../Database.js" as DB


Page {
    id: page
    property string name
    property string id
    property string info
    property string tablename

    ListModel {
        id: exercise
    }

    function refresh() {
        exercise.clear();
        DB.getExercise(exercise, tablename);
        var data = DB.getExerciseByTable(tablename);
        header.title = data[0];
        info.text = data[1];
    }

    function visibility() {
        var weight = DB.getExerciseType(page.tablename);
        if (weight === "Weight") {
            return true;
        }
        else {
            return false;
        }
    }

    function unit() {
        if (visibility()) {
            return (" kg");
        }
        else {
            return (" s");
        }
    }

    DatePicker {
        id: datepicker
        visible: false
    }

    SilicaFlickable {

        anchors.fill: parent


        PageHeader {
            title: page.name
            id: header
        }
        Label {
            id: info
            x: Theme.paddingLarge
            anchors.top: header.bottom
            text: page.info
            color: Theme.primaryColor
            width: page.width - 2*Theme.paddingLarge
            maximumLineCount: 10
            wrapMode: Text.WordWrap
            truncationMode: TruncationMode.Fade
        }

        Label {
            id: key1
            x: Theme.paddingLarge
            height: 50 * visibility()
            anchors.top: info.bottom
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            verticalAlignment: Text.AlignBottom
            text: qsTr("Date - sets x reps x weight")
            visible: visibility()

        }

        Label {
            id: key2
            x: Theme.paddingLarge
            height: 50 * !visibility()
            anchors.top: key1.bottom
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.secondaryColor
            verticalAlignment: Text.AlignBottom
            text: qsTr("Date - sets x reps x time")
            visible: !visibility()
        }

        PullDownMenu {
            MenuItem {
                text: qsTr("Information")
                onClicked: {pageStack.push(Qt.resolvedUrl("ExerciseInfo.qml"), {table:page.tablename});}
            }
            MenuItem {
                text: qsTr("Edit exercise")
                onClicked: {pageStack.push(Qt.resolvedUrl("ExerciseEdit.qml"), {table:page.tablename});}
                //onClicked: {pageStack.push(Qt.resolvedUrl("ExerciseEdit.qml"))}
            }

            MenuItem {
                text: qsTr("New set")
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("NewSet.qml"), {table:page.tablename});
                    page.refresh();
                }
            }
        }

        RemorsePopup { id: remorse }

        SilicaListView {
            id: listView
            model: exercise

            width: parent.width - 2*Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: key2.bottom
            anchors.bottom: parent.bottom
            delegate: ListItem {

                id: delegate
                menu: contextMenu
                //ListView.onRemove: animateRemoval(listItem)

                function remove() {
                    remorseAction("Deleting", function() { print("Deleting.... not really") })
                }

                function parseContent() {
                    datepicker.date = new Date(model.year, model.month-1, model.day, 0, 0, 0);
                    line.text = datepicker.dateText + " - " + model.sets + " x " + model.reps + " x " +
                                model.data + unit();
                }
                function parseLocalNum(num) {
                    return +(num.replace(",", "."));
                }
                function changeStatus() {
                    if (lineEnd.text == "Not done") {
                        lineEnd.text = "Done";
                        DB.changeStatus(page.tablename, model.id, "Done");
                    }
                    else if (lineEnd.text == "Done") {
                        lineEnd.text = "Fail";
                        DB.changeStatus(page.tablename, model.id, "Fail");
                    }
                    else if (lineEnd.text == "Fail") {
                        lineEnd.text = "Not done";
                        DB.changeStatus(page.tablename, model.id, "Not done");
                    }
                }

                BackgroundItem {
                    id: bg1
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - bg2.width

                    Label {
                        id: line
                        anchors.verticalCenter: parent.verticalCenter
                        color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                        Component.onCompleted: parseContent()
                        truncationMode: TruncationMode.Fade
                    }
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("NewSet.qml"),{table:page.tablename,id:model.id});
                        page.refresh();
                    }
                }
                BackgroundItem {
                    id: bg2
                    width: 125
                    anchors.left: bg1.right
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    Label {
                        id: lineEnd
                        text: model.status

                        horizontalAlignment: Text.AlignRight
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.right: parent.right

                        color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
                    }
                    onClicked: changeStatus()
                }



                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Modify"
                            onClicked: {pageStack.push(Qt.resolvedUrl("NewSet.qml"),{table:page.tablename,id:model.id}); page.refresh();}
                        }
                        MenuItem {
                            text: "Remove"
                        }
                    }
                }
            }
            VerticalScrollDecorator {}
        }
        Component.onCompleted: page.refresh()
    }
}




