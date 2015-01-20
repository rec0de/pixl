import QtQuick 2.0

// Animal DNA specs
//
// Example DNA:
// 00|11|000|111|000|1111|000|111|0000|111|000|111|0000|
// sh co viw mov stl dirc men ens enmv mis mas jpf sedu
//
// Shape: 1 of 4 shapes
// Color: 1 of 4 color variations
// Viewarea: 70 + DNA Value (0-7) * 15
// Movingchange: 1 + DNA Value (0-7)
// Stillchange: 1 + DNA Value (0-7)
// Directionchange: DNA Value (0-15)
// Maxenergy: 4 + DNA Value (0-7)
// Energystill: 0.001 + DNA Value (0-7) / 2000
// Minspeed: 0.5 + DNA Value (0-7) / 2
// Maxspeed: Minspeed + DNA Value (0-7)/1.5
// Energymoving: Energystill * (1 + maxspeed/10) * (1 + DNA Value (0-15)/15)
// Jumpforce: 7 + DNA Value (0-7)
// Searchduration: 300 + DNA Value (0-15)*100



Image {
    source: "../img/moose.png"
    mirror: false
    id: animal
    opacity: 1
    width: 45
    height: 45
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
    property bool searching: false // Animal is searching for something, higher attention.
    property bool mateable: true // Animal is ready to mate
    property bool still: false // Animal should not move now
    property bool startstill: false // Signal for animal to start stillreset timer
    property bool startmate: false // Signal for animal to start matereset timer
    property bool local: true // Is local animal (required for planned 'multiplayer')
    property int slowdownage: 90 // Animal will be slowed down from this age on (age in user unit, internal units are 400 times larger)
    property int grownupage: 20 // Animal will be slowed down from this age on (age in user unit, internal units are 400 times larger)
    property int matecooldown: 60*5*1000 // 5 minutes 'cooldown'

    // Database related
    property string name: 'Mr. Moose'
    property string dna: ''
    property int age: 0
    property int id

    Image {
        id: shadow
        source: "../img/moose_shadow.png"
        mirror: parent.mirror
        opacity: .5
        width: parent.width
        height: 10
        x: 0
        y: parent.height - 5 + parent.sshift
        z: 0
    }

    Text{
        id: name
        visible: false
        x: 50
        text: parent.name + ( parent.local ? '' : ' (g)') + '<br>' + Math.round((parent.energy / parent.maxenergy)*100) + '%' // Display name (add guest indicator if needed) and energy
        color: '#ffffff'
        font.pixelSize: 16
        font.family: pixels.name
    }

    MouseArea {
        anchors.fill: parent
        onClicked: showname()
    }

    function tick(){

        // Increment age
        age = age + 1;

        // Adjust size if age < 19 * 400
        if(age < 19*400){
            var factor = Math.sqrt(age/400 + 0.2)*0.08 + 0.65;
            animal.height = Math.round(factor * 45);
            animal.width = Math.round(factor * 45);
        }
        else{
            animal.width = 45;
            animal.height = 45;
        }

        // Check for stillreset signal
        if(startstill){
            startstill = false;
            stillreset.start();
        }

        // Check for stillreset signal
        if(startmate){
            startmate = false;
            matereset.start();
        }


        y = absy - yshift;
        sshift = yshift;

        // Moving state change
        if(Math.random()*100 < stillchange && !moving && !still){ // Dont start moving while still
            moving = ! moving;
            randomdirection();
        }
        else if(Math.random()*100 < movingchange && moving ){
           moving = ! moving;
        }

        // Look for food
        var searchprob = 0.12 * Math.pow(1.068, Math.round((energy / maxenergy)*100)) + 10; // Searching probability, depends on energy
        if((Math.floor(Math.random()*searchprob) == 10 || searching) && Math.round((energy / maxenergy)*100) < 91){ // Look for food aprox. every 20 ticks (if energy is below 91%)
            var dist;

            // Check for food within viewarea
            for (var i = 0; i < page.food.length; i++){
                dist = -1;
                if(page.food[i].active){
                    var dx = x - page.food[i].x
                    var dy = y - page.food[i].y
                    dist = Math.sqrt(dx*dx + dy*dy)
                    if(dist < viewarea){
                        xytodirection(page.food[i].x, page.food[i].y);
                        break;
                    }
                }
            }
            if(dist >= 0 && dist < eatarea){ // Found food & in eating area
                // Stop moving, exit search state and eat food
                moving = false;
                searching = false;
                searcher.stop();
                page.food[i].despawn();

                // Add 1 to animal energy level
                if(energy + 1 <= maxenergy){
                    energy = energy + 1;
                }
                else{
                    energy = maxenergy;
                }
            }
            else if(dist >= 0 && dist < viewarea){ // Found food
                // Start moving in food direction and enter searching state (if not already active)
                moving = true;

                if(!searching){
                   searching = true;
                   searcher.restart();
                }
            }
        }

        // Look for other moose
        if(Math.floor(Math.random()*20) == 5){ // Look for moose aprox. every 20 ticks

            // Check for other moose within viewarea
            for (i = 0; i < page.animals.length; i++){
                dist = -1;
                if(page.animals[i].alive && (page.animals[i].x !== x || page.animals[i].y !== y)){ // Exclude 'own' animal
                    dx = x - (page.animals[i].x + 50)
                    dy = y - page.animals[i].y
                    dist = Math.sqrt(dx*dx + dy*dy)
                    if(dist < viewarea && dist > 0){
                        if(dist < 30){
                            // Stop movement
                            moving = false;
                            page.animals[i].moving = false;

                            // Mate with certain probability based on energy and age if both animals are local, age over 20 , matable and not already mating
                            var multa = 1/(energy / maxenergy)+ Math.pow(1.3,((age/400)-80));
                            var multb = 1/(page.animals[i].energy / page.animals[i].maxenergy) + Math.pow(1.3,((page.animals[i].age/400)-80));
                            var multplicator = (multa * multb)*5; // 5 if both animals have 100% and youger than 80, higher if animals are hungry
                            if(page.animals[i].mateable && mateable && !still && !page.animals[i].still && local && page.animals[i].local && age >= grownupage*400 && page.animals[i].age >= grownupage*400 && Math.floor(Math.random()*multplicator) === 1){

                                // Align faces
                                if(page.animals[i].x > x){
                                    page.animals[i].mirror = false;
                                    mirror = true;
                                }
                                else{
                                    page.animals[i].mirror = true;
                                    mirror = false;
                                }

                                // Spawn heart particle
                                var heart_comp = Qt.createComponent("../components/heart.qml");
                                var heartx = (x + page.animals[i].x)/2;
                                var hearty = ((y + page.animals[i].y)/2)-5;
                                var temp = heart_comp.createObject(page, {x: heartx, y: hearty});
                                page.hearts.push(temp);

                                // Don't move for 2 seconds
                                page.animals[i].still = true;
                                still = true;
                                stillreset.start();
                                page.animals[i].startstill = true; // Apparently I cannot start the timer from here, so I set a var which gets checked by the other animal in tick()

                                // Spawn new animal
                                createanimal(combinedna(dna, page.animals[i].dna), x + Math.floor(Math.random()*10), y + Math.floor(Math.random()*10), animal.id, page.animals[i].id);
                                console.log('Spawning');
                                mateable = false;
                                page.animals[i].mateable = false;
                                matereset.start();
                                page.animals[i].startmate = true; // Apparently I cannot start the timer from here, so I set a var which gets checked by the other animal in tick()
                            }
                            else if(Math.floor(Math.random()*10) === 5){ // Otherwise play with other moose with 1/10 probability
                                //TODO, planned for sometime
                            }
                        }
                        else{
                          if(Math.floor(Math.random()*10) === 1){
                            xytodirection(page.animals[i].x + 50, page.animals[i].y);
                          }
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
            mirror = true;
        }
        else{
            mirror = false;
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
        shadow.visible = false;
        alive = false;

        // Log death
        page.log('death', animal.name, animal.dna)

        destroy(8000);
    }

    function importfromdna(dna){
        if(dna.length === 40){
            animal.dna = dna;

            var shape = dna.substr(0, 2);
            var basepath = '../img/moose';

            var color = parseInt(dna.substr(2, 2), 2) + 1;
            source = basepath + color + '.png';

            viewarea = 70 + parseInt(dna.substr(4, 3), 2) * 15;
            movingchange = 1 + parseInt(dna.substr(7, 3), 2);
            stillchange = 1 + parseInt(dna.substr(10, 3), 2);
            directionchange = parseInt(dna.substr(13, 4), 2);
            maxenergy = 4 + parseInt(dna.substr(17, 3), 2);
            energystill = 0.001 + parseInt(dna.substr(20, 3), 2)/2000;
            minspeed = 0.5 + parseInt(dna.substr(27, 3), 2)/2;
            maxspeed = minspeed + parseInt(dna.substr(30, 3), 2)/1.5
            energymoving = energystill * (1 + maxspeed / 10) * (1 + parseInt(dna.substr(24, 4), 2)/15)
            jumpforce = 7 + parseInt(dna.substr(33, 3), 2);
            searchingduration = 300 + parseInt(dna.substr(36, 4), 2)*100;
        }
    }

    function showname(){
        // Toggle nametag
        name.visible = !name.visible;
        if(page.paused){
            // Display animal info
            animalstats.a_name = animal.name;
            animalstats.a_dna = animal.dna;
            animalstats.a_age = animal.age;
            animalstats.a_local = animal.local;
            animalstats.a_id = animal.id;
            animalstats.a_energy = Math.round((animal.energy / animal.maxenergy)*100) + '%';
            animalstats.visible = true;
        }
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

        // Slow down old animals
        if(page.slowdown && age > 400*slowdownage){
            var agesquared = age*age;
            var constant = 0.94*400*slowdownage;
            var multiplier = (constant*constant)/agesquared;
            speed = speed * multiplier;
        }

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

    function combinedna(dna1, dna2){
        var crossoverpoint = Math.floor(Math.random()*40);
        var part1;
        var part2;

        // Crossover
        if(Math.floor(Math.random()*2) == 1){
          part1 = dna1.substr(crossoverpoint);
          part2 = dna2.substr(0, crossoverpoint);
        }
        else{
          part1 = dna2.substr(crossoverpoint);
          part2 = dna1.substr(0, crossoverpoint);
        }

        var rawdna = part1 + part2;

        // Mutation
        var dna = mutate(rawdna);
        return dna;
    }

    function mutate(dna){
        for(var i = 0; i < dna.length; i++){
           if(Math.floor(Math.random()*100) == 1){
               if(dna[i] === '1'){
                   dna = dna.substr(0, i) + '0' + dna.substr(i+1);
               }
               else{
                   dna = dna.substr(0, i) + '1' + dna.substr(i+1);
               }
           }
        }
        return dna;
    }

    Timer {
        id: searcher
        interval: searchingduration
        running: false
        repeat: false
        onTriggered: parent.searching = false;
    }

    Timer {
        id: stillreset
        interval: 2000
        running: false
        repeat: false
        onTriggered: parent.still = false;
    }

    Timer {
        id: matereset
        interval: matecooldown
        running: false
        repeat: false
        onTriggered: parent.still = false;
    }

}
