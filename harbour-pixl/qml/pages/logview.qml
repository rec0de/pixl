import QtQuick 2.0
import QtQuick.Window 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import 'data.js' as DB



Page {
    id: page
    property var log

    Component.onCompleted: {
        DB.initialize();

        // Load log from DB
        page.log = DB.log_get();

        for(var i = 0; i < page.log.length; i++){
            listModel.append({"name": page.log[i].val})
        }
    }


    ListModel {
         id: listModel
    }

    SilicaListView {
        id: listView
        model: listModel
        anchors.fill: parent

        header: PageHeader {
            title: "Event Log"
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                text: name
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.paddingMedium
                    rightMargin: Theme.paddingMedium
                }
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }
        }

        VerticalScrollDecorator {}
    }
}
