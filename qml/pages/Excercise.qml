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
        id: excercise
    }

    function refresh() {
        excercise.clear();
        DB.getExcercise(excercise, name, id);
        page.tablename = name + id;
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
            id: key
            x: Theme.paddingLarge
            anchors.top: info.bottom
            text: qsTr("Date - sets x reps x weight")

        }

        PullDownMenu {
            MenuItem {
                text: "Delete All"
                onClicked: remorse.execute( "Deleting All Entries",
                                               function() {
                                                   page.refresh();
                                               }
                                           )
            }
            MenuItem {
                text: "New set"
                onClicked: pageStack.push(Qt.resolvedUrl("NewSet.qml"), {table:page.tablename})
            }
        }

        RemorsePopup { id: remorse }

        SilicaListView {
            id: listView
            model: excercise

            width: parent.width - 2*Theme.paddingLarge
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: key.bottom
            anchors.bottom: parent.bottom
            delegate: ListItem {

                id: delegate
                menu: contextMenu
                ListView.onRemove: animateRemoval(listItem)

                function remove() {
                    remorseAction("Deleting", function() { print("Deleting.... not really") })
                }

                function parseContent(date) {
                    datepicker.date = new Date(model.year, model.month-1, model.day, 0, 0, 0);
                    line.text = datepicker.dateText + " - " + model.sets + " x " + model.reps + " x " +
                                model.weight + " kg";
                }

                Label {
                    id: line
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    Component.onCompleted: parseContent(model.date)
                    truncationMode: TruncationMode.Fade
                }
                Label {
                    id: lineEnd
                    text: model.status

                    horizontalAlignment: Text.AlignRight
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right

                    color: delegate.highlighted ? Theme.highlightColor : Theme.secondaryColor
                }

                //onClicked: pageStack.push(Qt.resolvedUrl("Excercise.qml"),{name:model.name,id:model.id,info:model.info})

                Component {
                    id: contextMenu
                    ContextMenu {
                        MenuItem {
                            text: "Set done"
                            onClicked: setStatus("Done")
                        }
                        MenuItem {
                            text: "Set failed"
                            onClicked: setFailed("Failed")
                        }

                        MenuItem {
                            text: "Modify"
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




/*
Page {
    id: page
    property string name
    property string id
    property string info
    property string tablename

    ListModel {
        id: excercise
    }

    function getData() {
        excercise.clear();
        DB.getExcercise(excercise, name, id);
        page.tablename = name + id;
    }

    DatePicker {
        id: datepicker

        visible: false
    }

    SilicaFlickable {

        anchors.fill: parent

        Column {
            id: header

            PageHeader {
                title: page.name
            }
            Label {
                x: Theme.paddingLarge
                text: page.info
                color: Theme.primaryColor
                width: page.width - 2*Theme.paddingLarge
                maximumLineCount: 10
                wrapMode: Text.WordWrap
                truncationMode: TruncationMode.Fade
            }

            Button {
                text: qsTr("New set")
                width: page.width - 2*Theme.paddingLarge
                onClicked: pageStack.push(Qt.resolvedUrl("NewSet.qml"), {table:page.tablename})
            }
            Label {
                x: Theme.paddingLarge
                text: qsTr("Date - sets x reps x weight")

            }

            SilicaListView {
                id: listView
                model: excercise

                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: header.bottom
                anchors.bottom: parent.bottom

                delegate: ListItem {
                    id: delegate
                    menu: contextMenu
                    ListView.onRemove: animateRemoval(listItem)
                    //height: childrenRect.height

                    function remove() {
                        remorseAction("Deleting", function() { print("Deleting.... not really") })
                    }
                    function transformDate(date) {
                        datepicker.date = new Date(model.year, model.month-1, model.day, 0, 0, 0);
                        date.text = datepicker.dateText + " - " + model.sets + " x " + model.reps + " x " + model.weight + " kg";
                    }

                    Label {
                        id: date
                        x: Theme.paddingLarge
                        width: 180
                        //anchors.verticalCenter: parent.verticalCenter
                        Component.onCompleted: transformDate(date)
                    }
                    /*Label {
                        id: sets
                        width: 60
                        text: model.sets
                        anchors.left: date.right
                        //anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        id: reps
                        width: 60
                        text: model.reps
                        anchors.left: sets.right
                        //anchors.verticalCenter: parent.verticalCenter
                    }
                    Label {
                        id: weight
                        width: 100
                        text: model.weight
                        anchors.left: reps.right
                        //anchors.verticalCenter: parent.verticalCenter
                    }*

                    Component {
                        id: contextMenu
                        ContextMenu {
                            MenuItem {
                                text: "Remove"
                                onClicked: remove()
                            }
                        }
                    }

                }
                VerticalScrollDecorator {}
            }
        }


        Component.onCompleted: page.getData()
    }
}
*/




