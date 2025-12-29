import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Page {
    id: navPage
    title: "导航系统"
    
    // 背景色
    background: Rectangle { color: "#121212" }

    // --- 自定义标题栏 (包含返回按钮) ---
    header: ToolBar {
        height: 30
        background: Rectangle { color: "#1e1e2e" }
        
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            
            // 返回按钮
            ToolButton {
                text: "< 返回"
                font.pixelSize: 12
                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    verticalAlignment: Text.AlignVCenter
                }
                // StackView 会自动作为 parent 的属性注入进来
                // 如果是在 Main.qml 的 StackView 里 push 的，这里可以直接调用 stackView.pop()
                // 但更稳健的写法是查找父级 StackView
                onClicked: {
                    var stack = navPage.StackView.view
                    if (stack) {
                        stack.pop()
                    }
                }
            }
            
            Label {
                text: "地图导航"
                color: "white"
                font.bold: true
                font.pixelSize: 14
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
            }
            
            // 占位，保持标题居中
            Item { width: 40 }
        }
    }

    // --- 这里放你的地图内容 ---
    // 考虑到 Mini2440 性能，暂时放一张模拟图或简易 Canvas
    Rectangle {
        anchors.fill: parent
        color: "#eec" // 模拟地图底色
        
        Label {
            anchors.centerIn: parent
            text: "地图加载中..."
            color: "black"
        }
        
        // 模拟一个车标
        Rectangle {
            width: 10; height: 10
            color: "red"
            radius: 5
            x: 100; y: 100
        }
    }
}