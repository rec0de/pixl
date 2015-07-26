import QtQuick 2.0

Item {
    x: 0
    y: 0
    z: 1000

    Component.onCompleted: {
        var today = new Date();
        if(today.getMonth() == 11 && Math.floor((x/5)%2) === 0){ // Uses zero based indexing for months
            tree.source = '../img/tree_xmas.png'; // Display christmas tree
        }
    }

    Image {
        source: "../img/tree.png"
        id: tree
        opacity: 1
        width: 80
        height: 110
        x: 0
        y: 0
    }
    Image {
        source: "../img/tree_shadow.png"
        id: treeshadow
        opacity: 1
        width: 80
        height: 20
        x: 0
        y: 90
        z: -1000
    }
}
