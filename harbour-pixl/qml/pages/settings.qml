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

        if(DB.getsett(11) != 0){
            spawnpred.checked = true;
        }

        if(DB.getsett(12) != 0){
            showmsg.checked = true;
        }

        if(DB.getsett(13) != 0){
            logorder.checked = true;
        }

        if(DB.getsett(16) != 0){
            statusicons.checked = true;
        }

        if(DB.getsett(17) == 1){
            pauseonmsg.checked = true;
        }

        if(DB.getsett(3) != -1){
            foodrate.value = DB.getsett(3);
        }
        else{
            foodrate.value = 85; // Use default if DB value is not set
        }
        if(DB.getsett(10) > 22){
            // Only display story reset if story has been completed
            storyreset.visible = true;
        }
    }

    function updatedaytime(){
        DB.setsett(0, daytime.currentIndex);
    }

    function switchdebug(){
        var val = DB.getsett(1);
        if(val != 1){
            DB.setsett(1, 1); // Activate Debug
            debug.checked = true;
        }
        else{
            DB.setsett(1, 0); // Deactivate Debug
            debug.checked = false;
        }
    }

    function switchslowage(){
        var val = DB.getsett(2);
        if(val != 0){
            DB.setsett(2, 0); // Deactivate Slowdown
            slowage.checked = false;
        }
        else{
            DB.setsett(2, 1); // Activate Slowdown
            slowage.checked = true;
        }
    }

    function switchpred(){
        var val = DB.getsett(11);
        if(val != 0){
            DB.setsett(11, 0); // Deactivate predators
            spawnpred.checked = false;
        }
        else{
            DB.setsett(11, 1); // Activate predators
            spawnpred.checked = true;
        }
    }

    function switchmsg(){
        var val = DB.getsett(12);
        if(val != 0){
            DB.setsett(12, 0); // Deactivate messages
            showmsg.checked = false;
        }
        else{
            DB.setsett(12, 1); // Activate messages
            showmsg.checked = true;
        }
    }

    function switchlogorder(){
        var val = DB.getsett(13);
        if(val != 0){
            DB.setsett(13, 0); // Show oldest first
            logorder.checked = false;
        }
        else{
            DB.setsett(13, 1); // Show newest first
            logorder.checked = true;
        }
    }

    function switchstatus(){
        var val = DB.getsett(16);
        if(val != 0){
            DB.setsett(16, 0); // Do not display status icons
            statusicons.checked = false;
        }
        else{
            DB.setsett(16, 1); // Display status icons
            statusicons.checked = true;
        }
    }

    function switchpausemsg(){
        var val = DB.getsett(17);
        if(val != 1){
            DB.setsett(17, 1); // Activate pause on msg
            pauseonmsg.checked = true;
        }
        else{
            DB.setsett(17, 0); // Deactivate pause on msg
            pauseonmsg.checked = false;
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

            TextSwitch {
                id: spawnpred
                text: "Predators"
                description: "Activates predator spawning"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchpred()
                }
            }

            TextSwitch {
                id: showmsg
                text: "Log messages on main screen"
                description: "Shows log notifications in-game"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchmsg()
                }
            }

            TextSwitch {
                id: pauseonmsg
                text: "Pause on message"
                description: "Pauses game on new log message"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchpausemsg()
                }
            }

            TextSwitch {
                id: logorder
                text: "Reverse log message order"
                description: "Shows newest messages first"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchlogorder()
                }
            }

            TextSwitch {
                id: statusicons
                text: "Status icons"
                description: "Displays small icons next to moose"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchstatus()
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

            Button {
               text: "Edit trees"
               visible: true
               anchors.horizontalCenter: parent.horizontalCenter
               onClicked:{
                    pageStack.push(Qt.resolvedUrl("treeedit.qml"));
               }
            }

            SectionHeader {
                text: "Debug"
            }

            RemorsePopup {
                id: remorse
                onTriggered: {
                    DB.hardreset();
                    Qt.quit();
                }
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
               text: "Restart Story"
               id: storyreset
               visible: false
               anchors.horizontalCenter: parent.horizontalCenter
               onClicked:{
                    DB.setsett(10, 0);
                    storyreset.visible = false;
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
