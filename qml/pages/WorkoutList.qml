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

    ListModel {
        id: workouts
    }

    function refresh() {
        workouts.clear();
        DB.getWorkoutlist(workouts);
    }

    SilicaFlickable {

        anchors.fill: parent


        PageHeader {
            title: qsTr("Workout routines")
            id: header
        }

        PullDownMenu {
            /*MenuItem {
                text: "Delete All"
                onClicked: remorse.execute( "Deleting All Entries",
                                               function() {
                                                   DB.clear();
                                                   page.refresh()
                                               }
                                           )
            }*/
            MenuItem {
                text: "New workout"
                onClicked: pageStack.push(Qt.resolvedUrl("NewWorkout.qml"))
            }
        }

        RemorsePopup { id: remorse }

        SilicaListView {
            id: listView
            model: workouts

            width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: header.bottom
            anchors.bottom: parent.bottom
            contentHeight: Theme.itemSizeMedium
            delegate: ListItem {
                id: delegate
                menu: contextMenu
                contentHeight: line1.height + line2.height + 20

                function remove() {
                    remorseAction("Deleting", function() {
                        DB.deleteWorkout(model.id);
                        page.refresh();
                    });
                }

                Label {
                    id: line1
                    x: Theme.paddingLarge
                    text: model.name
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
                Label {
                    id: line2
                    text: model.info
                    width: page.width - 2*Theme.paddingLarge
                    horizontalAlignment: Text.AlignLeft
                    truncationMode: TruncationMode.Fade
                    x: Theme.paddingLarge
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.secondaryColor
                    wrapMode: Text.WordWrap
                    maximumLineCount: 2
                    anchors {
                        top: line1.bottom
                        left: parent.left
                        right: parent.right
                        leftMargin: Theme.paddingLarge
                    }


                }

                onClicked: pageStack.push(Qt.resolvedUrl("ShowWorkout.qml"),{dbname:model.dbname})

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
        Component.onCompleted: page.refresh()
    }
}

