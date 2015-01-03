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

    function getData() {
        DB.getExcercise(excercise, name, id);
        page.tablename = name + id;
    }

    DatePicker {
        id: datepicker

        visible: false
    }

    SilicaFlickable {
        contentHeight: page.height
        id: entry
        anchors.fill: parent
        width: parent.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        Column {
            id: header

            width: parent.width
            spacing: Theme.paddingLarge
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



            SilicaListView {
                id: listView
                model: excercise

                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                contentHeight: Theme.itemSizeMedium
                delegate: ListItem {
                    id: delegate
                    menu: contextMenu
                    ListView.onRemove: animateRemoval(listItem)

                    function remove() {
                        remorseAction("Deleting", function() { print("Deleting.... not really") })
                    }

                    Label {
                        id: date
                        x: Theme.paddingLarge
                        width: 120
                        text: datepicker.dateText
                    }
                    Label {
                        id: sets
                        width: 60
                        text: model.sets
                        anchors.left: date.right
                    }
                    Label {
                        id: reps
                        width: 60
                        text: model.reps
                        anchors.left: sets.right
                    }
                    Label {
                        id: weight
                        width: 100
                        text: model.weight
                        anchors.left: reps.right
                    }

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




