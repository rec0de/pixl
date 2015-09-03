import QtQuick 2.0

Item {
    id: food
    width: 20
    height: 25
    x: 50
    y: 100
    z: 0
    property bool active: true
    property bool manual: false // True if food was spawned manually by user

    Image {
      source: (manual ? "../img/bigfood.png" : "../img/food.png")
      id: shadow
      width: 20
      height: 25
      x: 0
      y: 0
      z: 0
    }

    Timer {
        id: despawner
        interval: (manual ? 40000 : 20000)
        running: ticker.running
        repeat: false
        onTriggered: parent.despawn()
    }

    function despawn(){
        food.active = false;
        food.destroy();
    }
}
