import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Window

ApplicationWindow {
    id: window
    width: 320
    height: 240
    visible: true
    title: "Mini2440 Dashboard"
    color: "#121212"

    font.family: "Arial"
    font.pixelSize: 10

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: homePage
    }

    // --- 主页 ---
    Component {
        id: homePage
        Item {
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#1e1e2e" }
                    GradientStop { position: 1.0; color: "#000000" }
                }
            }

            // --- 顶部状态栏 ---
            RowLayout {
                id: topBar
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.margins: 4
                height: 20
                z: 10
                
                // GPS 状态显示
                Text {
                    text: Backend.gpsFixed ? "GPS: ON" : "GPS: No Fix"
                    color: Backend.gpsFixed ? "#00FF00" : "#888"
                    font.pixelSize: 10
                    Layout.fillWidth: true 
                }

                // 1. WiFi 图标 (新增)
                Canvas {
                    width: 16; height: 14
                    Layout.alignment: Qt.AlignVCenter
                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.strokeStyle = "white";
                        ctx.lineWidth = 1.5;
                        ctx.beginPath();
                        // 画三个弧
                        ctx.arc(8, 12, 2, Math.PI, 0); // 点
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(8, 12, 6, Math.PI * 1.25, Math.PI * 1.75); // 中弧
                        ctx.stroke();
                        ctx.beginPath();
                        ctx.arc(8, 12, 10, Math.PI * 1.25, Math.PI * 1.75); // 大弧
                        ctx.stroke();
                    }
                }

                // GPRS 信号
                Row {
                    spacing: 2
                    Repeater {
                        model: 4
                        Rectangle {
                            width: 3
                            height: 6 + (index * 2)
                            color: index < 3 ? "#FFFFFF" : "#555555"
                            anchors.bottom: parent.bottom
                        }
                    }
                    Text {
                        text: "4G"
                        color: "white"
                        font.bold: true
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // 2. 电池图标 (绑定后端数据)
                Item {
                    width: 24; height: 12
                    Rectangle {
                        id: batBody
                        width: 20; height: 12
                        color: "transparent"
                        border.color: "white"
                        border.width: 1
                        radius: 2
                        anchors.verticalCenter: parent.verticalCenter

                        Rectangle {
                            // 动态宽度绑定
                            width: (parent.width - 2) * Backend.batteryLevel
                            height: parent.height - 2
                            // 电量低变红，否则绿
                            color: Backend.batteryLevel < 0.2 ? "red" : "#00FF00"
                            anchors.left: parent.left
                            anchors.leftMargin: 1
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Rectangle {
                        width: 2; height: 4
                        color: "white"
                        anchors.left: batBody.right
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            // --- 功能网格 ---
            GridLayout {
                id: mainGrid
                anchors.centerIn: parent
                anchors.verticalCenterOffset: -5 
                columns: 4
                rowSpacing: 8
                columnSpacing: 8

                Repeater {
                    model: menuModel
                    delegate: Rectangle {
                        width: 68; height: 60 
                        color: mouseArea.pressed ? "#333344" : "#2a2a3a"
                        radius: 8
                        border.color: mouseArea.pressed ? highlightColor : "#444455"
                        border.width: 1

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 2
                            Rectangle {
                                Layout.alignment: Qt.AlignHCenter
                                width: 28; height: 28
                                radius: 14
                                color: model.highlightColor
                                opacity: 0.8
                                Text {
                                    anchors.centerIn: parent
                                    text: model.iconText
                                    color: "white"
                                    font.pixelSize: 14
                                    font.bold: true
                                }
                            }
                            Text {
                                Layout.alignment: Qt.AlignHCenter
                                text: model.name
                                color: "white"
                                font.pixelSize: 10 
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                if (model.name === "设置") {
                                    stackView.push(settingsPageComponent)
                                } 
                                else if (model.name === "导航") {
                                    stackView.push("NavigationPage.qml")
                                }
                                else if (model.name === "车辆信息") {
                                    stackView.push("CarInfoPage.qml")
                                }
                                else if (model.name === "音乐") {
                                    stackView.push("MusicPage.qml")
                                }
                                else if (model.name === "视频") {
                                    stackView.push("VideoPage.qml")
                                }
                                else if (model.name === "收音机") {
                                    stackView.push("RadioPage.qml")
                                }
                                else {
                                    stackView.push(detailPageComponent, {pageTitle: model.name})
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // --- 设置页面 (包含串口选择) ---
    Component {
        id: settingsPageComponent
        Page {
            background: Rectangle { color: "#121212" }
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
                        onClicked: stackView.pop()
                    }
                    Label {
                        text: "系统设置"
                        color: "white"
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Item { width: 30 }
                }
            }

            ColumnLayout {
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 20
                spacing: 15
                width: 280

                Label { text: "硬件端口配置"; color: "#888"; font.bold: true }

                // GPS 串口选择
                RowLayout {
                    Label { text: "GPS 信号端口:"; color: "white"; Layout.preferredWidth: 100 }
                    ComboBox {
                        Layout.fillWidth: true
                        height: 30
                        model: Backend.availablePorts
                        onActivated: (index) => { Backend.gpsPort = currentText }
                        Component.onCompleted: currentIndex = find(Backend.gpsPort)
                    }
                }

                // 电池 串口选择
                RowLayout {
                    Label { text: "电池监控端口:"; color: "white"; Layout.preferredWidth: 100 }
                    ComboBox {
                        Layout.fillWidth: true
                        height: 30
                        model: Backend.availablePorts
                        onActivated: (index) => { Backend.batteryPort = currentText }
                        Component.onCompleted: currentIndex = find(Backend.batteryPort)
                    }
                }
                
                // 刷新按钮
                Button {
                    text: "刷新端口列表"
                    Layout.alignment: Qt.AlignRight
                    onClicked: Backend.refreshPorts()
                }
            }
        }
    }

    // --- 通用详情页 (Placeholder) ---
    Component {
        id: detailPageComponent
        Page {
            property string pageTitle: ""
            background: Rectangle { color: "#121212" }
            header: ToolBar {
                height: 30
                background: Rectangle { color: "#1e1e2e" }
                RowLayout {
                    ToolButton {
                        text: "<"
                        contentItem: Text { text: parent.text; color: "white"; font.bold: true }
                        onClicked: stackView.pop()
                    }
                    Label { text: pageTitle; color: "white"; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter }
                }
            }
            Label { anchors.centerIn: parent; text: pageTitle + "\n功能开发中"; color: "white" }
        }
    }

    // --- 菜单数据 (已修改收音机) ---
    ListModel {
        id: menuModel
        ListElement { name: "导航";        iconText: "N"; highlightColor: "#007BFF" }
        ListElement { name: "车辆信息";    iconText: "I"; highlightColor: "#28A745" }
        ListElement { name: "行车记录";    iconText: "R"; highlightColor: "#DC3545" }
        ListElement { name: "电池监控";    iconText: "B"; highlightColor: "#FFC107" }
        ListElement { name: "音乐";        iconText: "M"; highlightColor: "#E83E8C" }
        ListElement { name: "视频";        iconText: "V"; highlightColor: "#6F42C1" }
        ListElement { name: "收音机";      iconText: "FM";highlightColor: "#17A2B8" } // 3. 修改此处
        ListElement { name: "设置";        iconText: "S"; highlightColor: "#6C757D" }
    }
}