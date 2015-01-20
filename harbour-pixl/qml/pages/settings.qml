import QtQuick 2.0
import Sailfish.Silica 1.0
import 'data.js' as DB

Page {
    id: page

    Component.onCompleted: {
        if(DB.getsett(0) == 1){
            daytime.currentIndex = 1;
        }
        else if(DB.getsett(0) == 0){
            daytime.currentIndex = 0;
        }
        else{
            daytime.currentIndex = 2;
        }

        if(DB.getsett(1) == 1){
            debug.checked = true;
        }

        if(DB.getsett(2) != 0){
            slowage.checked = true;
        }

        if(DB.getsett(3) != -1){
            foodrate.value = DB.getsett(3);
        }
        else{
            foodrate.value = 85; // Use default if DB value is not set
        }
    }

    function updatedaytime(){
        DB.setsett(0, daytime.currentIndex);
    }

    function switchdebug(){
        var dbug = DB.getsett(1);
        if(dbug != 1){
            DB.setsett(1, 1); // Activate Debug
            debug.checked = true;
        }
        else{
            DB.setsett(1, 0); // Deactivate Debug
            debug.checked = false;
        }
    }

    function switchslowage(){
        var slow = DB.getsett(2);
        if(slow != 0){
            DB.setsett(2, 0); // Deactivate Slowdown
            slowage.checked = false;
        }
        else{
            DB.setsett(2, 1); // Activate Slowdown
            slowage.checked = true;
        }
    }


    // Save new foodrate to DB
    function updatefoodrate(){
        DB.setsett(3, foodrate.value);
    }


    SilicaFlickable {
        anchors.fill: parent
        height: parent.height
        contentHeight: col.height + 10
        id: flick

        VerticalScrollDecorator{}

        Column {
            id: col
            width: parent.width
            anchors.margins: Theme.paddingLarge
            spacing: Theme.paddingMedium

            PageHeader {
                title: "Settings"
            }

            SectionHeader {
                text: "General"
            }

            TextSwitch {
                id: slowage
                text: "High age slowdown"
                description: "Makes old animals slower"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchslowage()
                }
            }

            ComboBox {
                label: "Daytime"
                id: daytime

                menu: ContextMenu {
                    MenuItem { text: "Day" }
                    MenuItem { text: "Night" }
                    MenuItem { text: "Cycle" }
                }
                onCurrentIndexChanged: updatedaytime();
            }

            Slider {
                id: foodrate
                width: parent.width
                minimumValue: 20
                maximumValue: 150
                value: 85
                stepSize: 1
                label: 'Food spawn rate (lower = more)'
                valueText: value
                onValueChanged: {
                    updatefoodrate()
                }
            }

            SectionHeader {
                text: "Debug"
            }

            RemorsePopup {
                id: remorse
                onTriggered: DB.hardreset()
            }

            RemorsePopup {
                id: remorse2
                onTriggered: DB.log_clear()
            }

            TextSwitch {
                id: debug
                text: "Debug mode"
                description: "Activate additional debug tools"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchdebug()
                }
            }

            Button {
               text: "Reset Log"
               anchors.horizontalCenter: parent.horizontalCenter
               onClicked:{
                    remorse2.execute('Reset Log');
               }
            }

            Button {
               text: "Reset Game"
               anchors.horizontalCenter: parent.horizontalCenter
               onClicked:{
                   var dialog = pageStack.push("../components/dialog_reset.qml")
                   dialog.accepted.connect(function() {
                    remorse.execute('Reset Game');
                   })
               }
            }

        }
    }

}
