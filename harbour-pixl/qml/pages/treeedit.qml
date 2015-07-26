import QtQuick 2.0
import Sailfish.Silica 1.0
import 'data.js' as DB

Page {
    id: page
    allowedOrientations: Orientation.All
    property var trees: new Array()

    Component.onCompleted: {
        DB.initialize();

        // Load trees from DB
        var data = DB.tree_get();
        var tree_comp = Qt.createComponent("../components/tree.qml");

        if(data !== false){
            for(var i = 0; i < data.length; i++){
                var temp = tree_comp.createObject(page, {x: data[i].x, y: data[i].y});
                page.trees.push(temp);
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        id: flick

        PullDownMenu {
            id: pullDownMenu

            MenuItem {
                id: clearMenuAction
                text: "Clear"
                onClicked: {
                    for(var i = 0; i < trees.length; i++){
                        trees[i].destroy();
                    }
                    trees = new Array();
                    DB.tree_clear();
                }
            }
        }

        MouseArea{
            anchors.fill: parent
            onClicked: {
                var x = mouse.x - 40;
                var y = mouse.y - 55;
                x = Math.round(x/5)*5;
                y = Math.round(y/5)*5;
                var tree_comp = Qt.createComponent("../components/tree.qml");
                DB.tree_add(x, y);
                var temp = tree_comp.createObject(page, {x: x, y: y});
                page.trees.push(temp);
            }
        }

        Label {
            text:   'Tap anywhere to spawn trees. Please keep in mind that there is no collision checking for trees and moose will just glitch trough them. Have fun!'
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.WordWrap
            anchors {
                left: parent.left
                right: parent.right
                leftMargin: Theme.paddingMedium
                rightMargin: Theme.paddingMedium
                verticalCenter: parent.verticalCenter
            }

            MouseArea{
                anchors.fill: parent
                onClicked: parent.visible = false
            }
        }
    }
}
