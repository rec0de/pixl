import QtQuick 2.0

Item {
    width: 20
    height: 25
    x: 50
    y: 100
    z: 0
    property bool active: true

    // Couldnt figure out how to do static textures...

    Image {
      source: "../img/food.png"
      id: shadow
      width: 20
      height: 25
      x: 0
      y: 0
      z: 0
    }

    Timer {
        id: despawner
        interval: 20000
        running: true
        repeat: false
        onTriggered: parent.despawn()
    }

    function despawn(){
        active = false;
        destroy();
    }
}
