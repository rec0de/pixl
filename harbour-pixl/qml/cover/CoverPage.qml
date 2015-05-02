import QtQuick 2.0
import Sailfish.Silica 1.0


CoverBackground {

    Image {
           source: "../img/cover.png"
           opacity: 0.1
           width: parent.width
           height: parent.height
           y: 0
           x: 0
       }

    function pause() {
        if(ticker.running){
            ticker.running = false;
            playpause.iconSource = "image://theme/icon-cover-play";
        }
        else
        {
            ticker.running = true;
            playpause.iconSource = "image://theme/icon-cover-pause";
        }

    }


    function tick() {
        shadow.x = animal.x;
        shadow.y = animal.absy + 40;
        animal.y = animal.absy - animal.yshift;

        // Moving state change
        if(Math.random()*100 < animal.statechange){
            animal.moving = ! animal.moving;
            animal.direction = (Math.random()*2)-1;
            if(animal.direction == 0){
                animal.direction = 1; // Avoid division by 0
            }

            animal.speed = animal.minspeed + (Math.random()*(animal.maxspeed - animal.minspeed));
        }

        // Speed change
        if(animal.moving && Math.random()*100 < animal.speedchange){
            animal.speed = animal.minspeed + (Math.random()*(animal.maxspeed - animal.minspeed));
        }


        // Move animal
        if(animal.moving){
            animal.absy = animal.absy + (animal.speed * animal.direction);
            if(animal.direction < 0){
                animal.x = animal.x + (animal.speed * (1 - animal.direction))
            }
            else{
                animal.x = animal.x + (animal.speed * (-1 - animal.direction))
            }


            // Keep animal on screen (x axis)
            if(animal.x < 0){
                animal.x = 0;
                animal.direction = (Math.random()*2)-1;
                if(animal.direction == 0){
                    animal.direction = 1; // Avoid division by 0
                }
            }
            else if(animal.x > rect.width - 45){
                animal.x = rect.width -45;
                animal.direction = (Math.random()*2)-1;
                if(animal.direction == 0){
                    animal.direction = 1; // Avoid division by 0
                }
            }

            // Keep animal on screen (y axis)
            if(animal.absy < 0){
                animal.absy = 0;
                animal.direction = (Math.random()*2)-1;
                if(animal.direction == 0){
                    animal.direction = 1; // Avoid division by 0
                }
            }
            else if(animal.absy > rect.height - 45){
                animal.absy = rect.height -45;
                animal.direction = (Math.random()*2)-1;
                if(animal.direction == 0){
                    animal.direction = 1; // Avoid division by 0
                }
            }
        }

        // Mirror image depending on direction
        if(animal.direction < 0){
            animal.mirror = true;
            shadow.mirror = true;
        }
        else{
            animal.mirror = false;
            shadow.mirror = false;
        }

        // Jumping animation if animal is moving
        if(animal.moving || animal.yshift > 3){
            animal.jumpindex = animal.jumpindex % animal.jumpforce;
            if(animal.jumpindex < (animal.jumpforce / 2)){
                animal.yshift = animal.jumpindex;
            }
            else{
                animal.yshift = animal.jumpforce - animal.jumpindex;
            }
            animal.jumpindex++;
        }
        else{
            animal.yshift = 0;
        }

    }


    Timer {
        id: ticker
        interval: 35
        running: false
        repeat: true
        onTriggered: tick()
    }


    Rectangle {
        id: rect
        width: parent.width
        height: parent.height
        color: 'transparent'
    }

    Image {
        source: "../img/moose1.png"
        mirror: false
        id: animal
        opacity: 1
        width: 45
        height: 45
        x: 70
        y: 150
        property int yshift: 0
        property int absy: 100
        property int jumpindex: 0
        property int jumpforce: 10
        property int statechange: 2 // Probability of state change in %
        property int speedchange: 2 // Probability of speed change in % while moving
        property real direction: .5 // Walking direction
        property real maxspeed: 3 // Max Walking speed
        property real minspeed: 1 // Min Walking Speed
        property real speed: animal.minspeed // Walking speed
        property bool moving: true
    }

    Image {
        source: "../img/moose_shadow.png"
        mirror: false
        id: shadow
        opacity: .5
        width: 45
        height: 10
        x: 70
        y: 195
    }

    Label {
        id: covertitle
        font.pixelSize: Theme.fontSizeLarge
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        text: "pixl"
    }

    CoverActionList {
        id: coverAction
        CoverAction {
            id: playpause
            iconSource: "image://theme/icon-cover-play"
            onTriggered: {
                pause()
             }
        }
   }

}


