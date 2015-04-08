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

        var descending;

        // Get log order setting
        if(DB.getsett(13) != 0){
            descending = true;
        }
        else{
            descending = false;
        }

        // Load log from DB
        page.log = DB.log_get(descending);

        for(var i = 0; i < page.log.length; i++){
            listModel.append({"name": page.log[i].val, "info": page.log[i].info, "time": page.log[i].time})
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
        delegate: ListItem {
            id: delegate
            menu: contextMenuComponent
            contentHeight: logtext.height + 20

            Label {
                id: logtext
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

            Component {
                id: contextMenuComponent
                ContextMenu {
                    Label{
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeMedium
                        text: info
                    }
                    Label{
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: gettime(time)
                    }
                }
            }

            function gettime(time){
                var diff = Math.round((Date.now() - time)/1000);
                var res;
                if(diff < 13){
                    res = 'Just now';
                }
                else if(diff < 60){
                    res = diff + ' seconds ago';
                }
                else if(diff < 60*60){
                    diff = Math.round(diff/60);
                    res = (diff === 1) ? (diff + ' minute ago') : (diff + ' minutes ago');
                }
                else if(diff < 60*60*24){
                    diff = Math.round(diff/(60*60));
                    res = (diff === 1) ? (diff + ' hour ago') : (diff + ' hours ago');
                }
                else if(diff < 60*60*24*30.5){
                    diff = Math.round(diff/(60*60*24));
                    res = (diff === 1) ? (diff + ' day ago') : (diff + ' days ago');
                }
                else if(diff < 60*60*24*365){
                    diff = Math.round(diff/(60*60*24*30.5));
                    res = (diff === 1) ? (diff + ' month ago') : (diff + ' months ago');
                }
                else {
                    diff = Math.round(diff/(60*60*24*365));
                    res = (diff === 1) ? (diff + ' year ago') : (diff + ' years ago');
                }

                return res;
            }

        }

        VerticalScrollDecorator {}
    }
}
