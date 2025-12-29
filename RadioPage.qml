import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: radioPage
    title: "车载收音机"
    
    // 模拟数据属性
    property double frequency: 87.5
    property string band: "FM1"
    
    background: Rectangle { color: "#121212" }

    // --- 1. 顶部标题栏 (通用风格) ---
    header: ToolBar {
        height: 30
        background: Rectangle { color: "#1e1e2e" }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            ToolButton {
                text: "< 返回"
                font.pixelSize: 12
                contentItem: Text {
                    text: parent.text; color: "white"; font.bold: true; verticalAlignment: Text.AlignVCenter
                }
                onClicked: {
                    var stack = radioPage.StackView.view
                    if (stack) stack.pop()
                }
            }
            Label {
                text: "FM 收音机"
                color: "white"; font.bold: true; font.pixelSize: 14
                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            }
            Item { width: 40 }
        }
    }

    // --- 2. 主要内容区 ---
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        // A. 频率显示区域 (LCD 风格)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 90
            color: "#222222"
            radius: 10
            border.color: "#444"
            border.width: 1

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0
                
                // 波段显示
                Text {
                    text: radioPage.band
                    color: "#888"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }

                // 巨大频率数字
                Text {
                    text: radioPage.frequency.toFixed(1)
                    color: "#00E5FF" // 荧光蓝
                    font.pixelSize: 56
                    font.family: "Arial"
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }

                // 单位
                Text {
                    text: "MHz"
                    color: "#888"
                    font.pixelSize: 12
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            
            // 右侧装饰：立体声标志
            Text {
                text: "STEREO"
                color: "red"
                font.pixelSize: 8
                font.bold: true
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.margins: 8
                visible: true
            }
        }

        // B. 频谱可视动画 (装饰性)
        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 3
            Repeater {
                model: 20 // 20根柱子
                Rectangle {
                    width: 4
                    height: Math.random() * 20 + 5 // 初始高度
                    color: "#00E5FF"
                    opacity: 0.6
                    radius: 2
                    
                    // 动画定时器
                    Timer {
                        interval: 100
                        running: true
                        repeat: true
                        onTriggered: parent.height = Math.random() * 20 + 5
                    }
                }
            }
        }

        // C. 控制按钮区
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 50
            spacing: 20

            // 减频率
            Button {
                Layout.fillHeight: true
                Layout.preferredWidth: 60
                text: "<<"
                onClicked: tuneFreq(-0.1)
                background: Rectangle {
                    color: parent.pressed ? "#444" : "#333"
                    radius: 5
                }
                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }

            // 预设频道 (Grid)
            GridLayout {
                Layout.fillWidth: true
                columns: 3
                columnSpacing: 5
                rowSpacing: 5
                
                Repeater {
                    model: ["87.5", "98.1", "103.7", "101.1", "92.3", "107.0"]
                    delegate: Button {
                        text: modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 25
                        background: Rectangle {
                            color: radioPage.frequency.toFixed(1) === modelData ? "#007BFF" : "#333"
                            radius: 3
                        }
                        contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                        onClicked: radioPage.frequency = parseFloat(modelData)
                    }
                }
            }

            // 加频率
            Button {
                Layout.fillHeight: true
                Layout.preferredWidth: 60
                text: ">>"
                onClicked: tuneFreq(0.1)
                background: Rectangle {
                    color: parent.pressed ? "#444" : "#333"
                    radius: 5
                }
                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 20; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
            }
        }
    }

    // 逻辑函数：调频
    function tuneFreq(step) {
        var newFreq = frequency + step;
        if (newFreq > 108.0) newFreq = 87.5;
        if (newFreq < 87.5) newFreq = 108.0;
        frequency = newFreq;
    }
}