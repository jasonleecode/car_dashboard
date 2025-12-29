import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: carInfoPage
    title: "车辆信息"
    
    background: Rectangle { color: "#121212" }

    // --- 模拟数据 ---
    property int currentSpeed: 0
    property int currentRpm: 0
    
    Timer {
        interval: 100; running: true; repeat: true
        onTriggered: {
            var time = new Date().getTime() / 1000;
            var factor = (Math.sin(time) + 1) / 2; 
            carInfoPage.currentSpeed = factor * 120; 
            carInfoPage.currentRpm = factor * 3000 + 800; 
        }
    }

    // --- 1. 顶部标题栏 ---
    header: ToolBar {
        height: 30
        background: Rectangle { color: "#1e1e2e" }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            ToolButton {
                text: "< 返回"
                font.pixelSize: 12
                contentItem: Text { text: parent.text; color: "white"; font.bold: true; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    var stack = carInfoPage.StackView.view
                    if (stack) stack.pop()
                }
            }
            Label {
                text: "车辆实时监控"
                color: "white"; font.bold: true; font.pixelSize: 14
                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            }
            Item { width: 40 }
        }
    }

    // --- 2. 主内容区 (仪表盘) ---
    RowLayout {
        // 【修改点】不再使用 centerIn，改为固定在顶部
        anchors.top: parent.top
        anchors.topMargin: 30 // 避开顶部标题栏(30px)，并多留10px间距
        anchors.horizontalCenter: parent.horizontalCenter
        
        width: parent.width * 0.95
        height: parent.height * 0.55 // 【修改点】稍微减小高度占比 (原来是0.7)，防止挤到底部
        spacing: 20

        // 左侧：转速表 (RPM)
        DashboardGauge {
            id: rpmGauge
            Layout.fillWidth: true
            Layout.fillHeight: true
            value: carInfoPage.currentRpm
            maxValue: 8000
            label: "RPM"
            unit: "x1000"
            accentColor: "#FF9800" 
            isRpm: true 
        }

        // 右侧：速度表 (Speed)
        DashboardGauge {
            id: speedGauge
            Layout.fillWidth: true
            Layout.fillHeight: true
            value: carInfoPage.currentSpeed
            maxValue: 240
            label: "KM/H"
            unit: "Speed"
            accentColor: "#00E5FF" 
        }
    }

    // --- 3. 底部数字信息 ---
    // 保持在底部，因为上面仪表盘高度减小并上移了，现在不会重叠了
    RowLayout {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 10 
        spacing: 30
        
        InfoItem { label: "水温"; value: "90°C"; icon: "🌡" }
        InfoItem { label: "油量"; value: "65%";  icon: "⛽" }
        InfoItem { label: "里程"; value: "1284 km"; icon: "🛣" }
    }

    component InfoItem : Column {
        property string label: ""
        property string value: ""
        property string icon: ""
        spacing: 2
        Text { 
            text: icon; font.pixelSize: 16; anchors.horizontalCenter: parent.horizontalCenter; color: "#aaa"
        }
        Text { 
            text: value; color: "white"; font.bold: true; font.pixelSize: 12; anchors.horizontalCenter: parent.horizontalCenter
        }
        Text { 
            text: label; color: "#666"; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    component DashboardGauge : Item {
        id: gauge
        property real value: 0
        property real maxValue: 240
        property string label: ""
        property string unit: ""
        property color accentColor: "white"
        property bool isRpm: false 

        Canvas {
            id: canvas
            anchors.fill: parent
            antialiasing: true
            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();
                var cx = width / 2;
                var cy = height / 2;
                // 稍微减小半径，留出文字空间
                var radius = Math.min(width, height) / 2 - 5; 
                
                ctx.beginPath();
                ctx.arc(cx, cy, radius, Math.PI * 0.75, Math.PI * 2.25);
                ctx.lineWidth = 3;
                ctx.strokeStyle = "#333";
                ctx.stroke();

                var totalTicks = 10; 
                var stepAngle = (270 * Math.PI / 180) / totalTicks;
                var startAngle = Math.PI * 0.75;
                
                ctx.textAlign = "center";
                ctx.textBaseline = "middle";
                ctx.font = "bold 9px Arial"; // 稍微调小刻度字体
                
                for (var i = 0; i <= totalTicks; i++) {
                    var angle = startAngle + i * stepAngle;
                    var p1x = cx + (radius - 2) * Math.cos(angle);
                    var p1y = cy + (radius - 2) * Math.sin(angle);
                    var p2x = cx + (radius - 8) * Math.cos(angle);
                    var p2y = cy + (radius - 8) * Math.sin(angle);
                    
                    ctx.beginPath();
                    ctx.moveTo(p1x, p1y);
                    ctx.lineTo(p2x, p2y);
                    ctx.lineWidth = 2;
                    ctx.strokeStyle = (i > 7 && gauge.isRpm) ? "red" : "white"; 
                    ctx.stroke();
                    
                    var tx = cx + (radius - 18) * Math.cos(angle);
                    var ty = cy + (radius - 18) * Math.sin(angle);
                    ctx.fillStyle = "#aaa";
                    var numText = Math.floor((i / totalTicks) * gauge.maxValue);
                    if (gauge.isRpm) numText = numText / 1000; 
                    ctx.fillText(numText.toString(), tx, ty);
                }
            }
        }

        Column {
            anchors.centerIn: parent
            anchors.verticalCenterOffset: 25 
            Text {
                text: Math.floor(gauge.value)
                color: "white"
                font.pixelSize: 22
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
            Text {
                text: gauge.label
                color: gauge.accentColor
                font.pixelSize: 10
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        Item {
            id: needleContainer
            anchors.fill: parent
            property real angleRange: 270
            property real startAngle: -135
            property real currentAngle: startAngle + (Math.min(gauge.value, gauge.maxValue) / gauge.maxValue) * angleRange

            Rectangle {
                width: parent.width / 2 - 12
                height: 2
                color: gauge.accentColor
                radius: 1
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.horizontalCenter 
                transformOrigin: Item.Left
                rotation: needleContainer.currentAngle
                Behavior on rotation { SmoothedAnimation { velocity: 300; duration: 200 } }
            }
            Rectangle {
                width: 10; height: 10; radius: 5; color: "#111"; border.color: "#555"; border.width: 1; anchors.centerIn: parent
            }
        }
    }
}