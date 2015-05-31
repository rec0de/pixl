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
            animalModel.append({"name": page.animals[i].name, "age": page.animals[i].age, "dna": page.animals[i].dna, "animal": true, "local": true, "id": page.animals[i].id})
        }

        // List non-local animals
        page.guests = DB.getnonlocal();

        for(var i = 0; i < page.guests.length; i++){
            animalModel.append({"name": page.guests[i].name, "age": page.guests[i].age, "dna": page.guests[i].dna, "animal": true, "local": false, "id": page.guests[i].id})
        }


        // Add Invite animal element
        animalModel.append({"name": 'Invite animal...', "animal": false, "local": true})
    }


    function refresh(){
        // Reload all names

        // List local animals
        page.animals = DB.getall();
        animalModel.clear();

        for(var i = 0; i < page.animals.length; i++){
            animalModel.append({"name": page.animals[i].name, "age": page.animals[i].age, "dna": page.animals[i].dna, "animal": true, "local": true, "id": page.animals[i].id})
        }

        // List non-local animals
        page.guests = DB.getnonlocal();

        for(var i = 0; i < page.guests.length; i++){
            animalModel.append({"name": page.guests[i].name, "age": page.guests[i].age, "dna": page.guests[i].dna, "animal": true, "local": false, "id": page.guests[i].id})
        }

        // Invite animal element
        animalModel.append({"name": 'Invite animal...', "animal": false, "local": true})

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
                id: aboutMenuAction
                text: "About Pixl"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("about2.qml"))
                }
            }

            MenuItem {
                id: logMenuAction
                text: "Event Log"
                onClicked: {
                    pageStack.push(Qt.resolvedUrl("logview.qml"))
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

            Row{
                width: parent.width

                Rectangle{
                    // Spacer
                    height: parent.height
                    width: Theme.paddingMedium
                    color: 'transparent'
                }

                Rectangle{
                    color: animal ? Theme.highlightColor : 'transparent'
                    height: parent.height
                    width: height
                    radius: 90

                    Image{
                        source: !animal ? '../img/moose_sw.png' : '../img/moose'+(parseInt(dna.substr(2, 2), 2) + 1)+'.png'
                        visible: animal
                        smooth: false
                        height: Math.round(0.9 * (parent.height / Math.sqrt(2))) // Fit in Circle
                        width: Math.round(0.9 * (parent.width / Math.sqrt(2)))
                        anchors.centerIn: parent
                    }
                }

                Rectangle{
                    // Spacer
                    height: parent.height
                    width: Theme.paddingMedium
                    color: 'transparent'
                }

                Label {
                    x: Theme.paddingLarge
                    text: local ? name : name + ' (g)'
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }

            onClicked:{
                if(animal){
                  pageStack.push(Qt.resolvedUrl("aboutanimal.qml"), {name: name, dna: dna, age: age, local: local, id: id});
                }
                else{
                    pageStack.push(Qt.resolvedUrl("invite.qml"))
                }
            }
        }

        VerticalScrollDecorator {}
    }
}
