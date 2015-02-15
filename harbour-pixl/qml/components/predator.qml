import QtQuick 2.0

Image {
    source: "../img/monster.png"
    mirror: false
    id: animal
    opacity: 1
    width: 35
    height: 50
    smooth: false
    x: 0
    y: 0
    z: 2
    // Animal Properties

    //In DNA
    property int viewarea: 100 // Radius of the area in wich the animal will find food, ect
    property int movingchange: 2 // Probability of state change from moving to still in %
    property int stillchange: 2 // Probability of state change from still to moving in %
    property int directionchange: 4 // Probability of direction change while moving in %
    property int maxenergy: 5 // Makimum energy the animal can store
    property int jumpforce: 10
    property real energystill: .001 // Energy consumed while still
    property real energymoving: .002 // Energy consumed while moving
    property real maxspeed: 4 // Max Walking speed
    property real minspeed: 1 // Min Walking Speed
    property int searchingduration: 500 // Max. duration of searching state

    //Not in DNA
    property int yshift: 0
    property int sshift: 0 // Shadow shifting
    property int absy: 0
    property int jumpindex: 0
    property int eatarea: 20 // Radius of the area in wich food can be eaten
    property real energy: maxenergy // Current energy of the animal
    property real speed: minspeed // Walking speed
    property real xspeed: 1 // Speed on x axis
    property real yspeed: 1 // Speed on y axis
    property bool alive: true
    property bool moving: true
    property bool searching: false // Animal is searching for something, higher attention

    Image {
        id: shadow
        source: "../img/predator_shadow.png"
        mirror: parent.mirror
        opacity: .5
        width: parent.width
        height: 10
        x: 0
        y: parent.height - 5 + parent.sshift
        z: 0
    }

    function tick(){

        y = absy - yshift;
        sshift = yshift;

        // Moving state change
        if(Math.random()*100 < stillchange && !moving){
            moving = ! moving;
            randomdirection();
        }
        else if(Math.random()*100 < movingchange && moving ){
           moving = ! moving;
        }

        // Look for moose
        if(Math.floor(Math.random()*10) == 5 || searching){ // Look for moose aprox. every 10 ticks

            // Check for moose within viewarea
            var dist;
            for (var i = 0; i < page.animals.length; i++){
                dist = -1;
                if(page.animals[i].alive){ // Exclude dead animals
                    var dx = x - (page.animals[i].x + 50)
                    var dy = y - page.animals[i].y
                    dist = Math.sqrt(dx*dx + dy*dy)
                    if(dist < viewarea && dist > 0){
                        if(dist < 30){
                            // Stop movement
                            moving = false;
                        }
                        else{
                            searching = true;
                            searcher.start();
                            xytodirection(page.animals[i].x + 50, page.animals[i].y);
                        }
                    }
                }
            }


        }

        // Move animal
        if(moving){
            absy = absy + yspeed;
            x = x + xspeed;


            // Keep animal on screen (x axis)
            if(x < 0){
                x = 0;
                randomdirection();
            }
            else if(x > rect.width - 45){
                x = rect.width -45;
                randomdirection();
            }

            // Keep animal on screen (y axis)
            if(absy < 60){ // 60 = menu height
                absy = 60;
                randomdirection();
            }
            else if(absy > rect.height - 45){
                absy = rect.height -45;
                randomdirection();
            }

        }

        // Mirror image depending on direction
        if(xspeed > 0){
            mirror = false;
        }
        else{
            mirror = true;
        }

        // Jumping animation if animal is moving
        if(moving || yshift > 3){
            jumpindex = jumpindex % jumpforce;
            if(jumpindex < (jumpforce / 2)){
                yshift = jumpindex;
            }
            else{
                yshift = jumpforce - jumpindex;
            }
            jumpindex++;
        }
        else{
            yshift = 0;
        }

        // Subtract energy consumed from energy level
        if(moving){
            energy = energy - energymoving;
        }
        else{
            energy = energy - energystill;
        }

        // Die if energy <= 0
        if(energy <= 0){
            die();
        }
    }

    // End tick function

    function die(){
        source = '../img/tombstone.png';
        width = 45;
        height = 45;
        shadow.visible = false;
        alive = false;

        destroy(8000);
    }

    function generate(){
            viewarea = 70 + Math.floor(Math.random()*8) * 15;
            movingchange = 1 + Math.floor(Math.random()*8);
            stillchange = 1 + Math.floor(Math.random()*8);
            directionchange = Math.floor(Math.random()*16);
            maxenergy = 4 + Math.floor(Math.random()*8);
            energystill = 0.001 + Math.floor(Math.random()*8)/2000;
            minspeed = 0.5 + Math.floor(Math.random()*8)/2;
            maxspeed = minspeed + Math.floor(Math.random()*8)/1.5
            energymoving = energystill * (1 + maxspeed / 10) * (1 + Math.floor(Math.random()*8)/15)
            jumpforce = 7 + Math.floor(Math.random()*8);
            searchingduration = 300 + Math.floor(Math.random()*16)*100;
    }


    function xytodirection(ox, oy){
        var dx = x - ox;
        var dy = y - oy;


        // I am apparently too stupid to solve this with clean math, so...
        while(Math.abs(dx) + Math.abs(dy) > maxspeed){
            dx = dx * 0.7;
            dy = dy * 0.7;
        }
        xspeed = - dx;
        yspeed = - dy;

    }

    function randomdirection(){
        // Change speed
        speed = minspeed + (Math.random()*(maxspeed - minspeed));

        // Determine absolute value of xspeed and yspeed first
        var absx = (Math.random()*speed);
        var absy = speed - absx;

        // Determine if each value is negative / positive
        if(Math.floor(Math.random()*2) == 1){
            xspeed = - absx;
        }
        else{
            xspeed = absx;
        }
        if(Math.floor(Math.random()*2) == 1){
            yspeed = - absy;
        }
        else{
            yspeed = absy;
        }
    }

    Timer {
        id: searcher
        interval: searchingduration
        running: false
        repeat: false
        onTriggered: parent.searching = false;
    }

}
