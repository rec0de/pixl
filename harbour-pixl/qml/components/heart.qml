import QtQuick 2.0

Item {
    width: 25
    height: 25
    x: 0
    y: 0
    z: 1000
    property bool active: true


    Image {
      source: "../img/heart.png"
      id: heart
      width: 25
      height: 25
      opacity: .9
      x: 0
      y: 0
      z: 0
    }

    Timer {
        id: despawner
        interval: 2000
        running: true
        repeat: false
        onTriggered: parent.despawn()
    }

    function despawn(){
        active = false;
        destroy();
    }
}
