import QtQuick 2.0
import QtQuick.Window 2.0
import QtMultimedia 5.0
import Sailfish.Silica 1.0
import 'data.js' as DB



Page {
    id: page
    property var animals
    property var guests
    property string messagetext: 'Something went wrong'
    property bool showmessage: false

    Component.onCompleted: {
        DB.initialize();


        // List local animals first
        page.animals = DB.getall();

        for(var i = 0; i < page.animals.length; i++){
            animalModel.append({"name": page.animals[i].name, "age": page.animals[i].age, "dna": page.animals[i].dna, "animal": true, "local": true})
        }

        // List non-local animals
        page.guests = DB.getnonlocal();

        for(var i = 0; i < page.guests.length; i++){
            animalModel.append({"name": page.guests[i].name + ' (g)', "age": page.guests[i].age, "dna": page.guests[i].dna, "animal": true, "local": false})
        }


        // Add Invite animal element
        animalModel.append({"name": 'Invite animal...', "animal": false})
    }


    function refresh(){
        // Reload all names

        // List local animals
        page.animals = DB.getall();
        animalModel.clear();

        for(var i = 0; i < page.animals.length; i++){
            animalModel.append({"name": page.animals[i].name, "age": page.animals[i].age, "dna": page.animals[i].dna, "animal": true, "local": true})
        }

        // List non-local animals
        page.guests = DB.getnonlocal();

        for(var i = 0; i < page.guests.length; i++){
            animalModel.append({"name": page.guests[i].name + ' (g)', "age": page.guests[i].age, "dna": page.guests[i].dna, "animal": true, "local": false})
        }

        // Invite animal element
        animalModel.append({"name": 'Invite animal...', "animal": false})

    }

    ListModel {
         id: animalModel
    }

    RemorsePopup {
        id: remorse
        onTriggered: DB.hardreset()
    }

    Timer {
        id: refresher
        interval: 4000
        running: Qt.application.active
        repeat: true
        onTriggered: refresh()
    }

    Rectangle {
        id: message
        visible: page.showmessage
        anchors.centerIn: parent
        width: page.width
        height: Theme.itemSizeLarge
        color: Theme.highlightColor
        z: 1000
        Label{
            visible: parent.visible
            anchors.centerIn: parent
            text: page.messagetext
            font.pixelSize: Theme.fontSizeLarge
        }
        MouseArea {
            anchors.fill : parent
            onClicked: parent.visible = false
        }
    }


    SilicaListView {
        id: listView
        model: animalModel
        anchors.fill: parent

        PullDownMenu {
            id: pullDownMenu
            MenuItem {
                id: resetMenuAction
                text: "Reset Game"
                onClicked: {
                    var dialog = pageStack.push("../components/dialog_reset.qml")
                    dialog.accepted.connect(function() {
                      remorse.execute('Reset Game');
                    })
                }
            }

            MenuItem {
                id: aboutMenuAction
                text: "About Pixl"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("about2.qml"))
                }
            }

            MenuItem {
                id: settingsMenuAction
                text: "Settings"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("settings.qml"))
                }
            }
        }

        header: PageHeader {
            title: "Animal List"
        }
        delegate: BackgroundItem {
            id: delegate

            Label {
                x: Theme.paddingLarge
                text: name
                anchors.verticalCenter: parent.verticalCenter
                color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
            }

            onClicked:{
                if(animal){
                  pageStack.push(Qt.resolvedUrl("aboutanimal.qml"), {name: name, dna: dna, age: age, local: local});
                }
                else{
                    pageStack.push(Qt.resolvedUrl("invite.qml"))
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
