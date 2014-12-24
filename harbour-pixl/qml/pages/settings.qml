import QtQuick 2.0
import Sailfish.Silica 1.0
import 'data.js' as DB

Page {
    id: page

    Component.onCompleted: {
        if(DB.getsett(0) == 1){
            nightmode.checked = true;
        }

        if(DB.getsett(1) == 1){
            debug.checked = true;
        }

        if(DB.getsett(2) != 0){
            slowage.checked = true;
        }
    }

    function switchnight(){
        var night = DB.getsett(0);
        if(night != 1){
            DB.setsett(0, 1); // Activate Night Mode
            nightmode.checked = true;
        }
        else{
            DB.setsett(0, 0); // Deactivate Night Mode
            nightmode.checked = false;
        }
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
                id: nightmode
                text: "Night mode"
                description: "Darker, eye friendly theme"
                automaticCheck: false
                checked: false
                onClicked: {
                    switchnight()
                }
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

            SectionHeader {
                text: "Debug"
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

        }
    }

}
