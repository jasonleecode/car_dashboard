import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import Qt.labs.folderlistmodel 2.15

Page {
    id: musicPage
    title: "车载音乐"
    
    background: Rectangle { color: "#121212" }

    // --- 0. 配置区域 ---
    // 【重要】请修改为你电脑上的实际音乐路径
    property url musicFolder: "file:///Users/jason/Music" 

    // --- 1. 播放器后端 ---
    MediaPlayer {
        id: player
        audioOutput: AudioOutput {
            id: audioOutput
            volume: volSlider.value
        }
        // 自动切歌逻辑
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState && position === duration) {
                 if (playMode === 2) player.play(); // 单曲循环
                 else switchTrack(1); // 列表循环/随机
            }
        }
    }

    // --- 2. 状态变量 ---
    property int currentTrackIndex: -1
    property bool isPlaying: player.playbackState === MediaPlayer.PlayingState
    property int playMode: 0 // 0=循环, 1=随机, 2=单曲
    property var playModeIcons: ["🔁", "🔀", "🔂"]

    // 文件夹扫描模型
    FolderListModel {
        id: folderModel
        folder: musicPage.musicFolder
        nameFilters: ["*.mp3", "*.wav", "*.aac", "*.m4a", "*.flac"]
        showDirs: false
        onCountChanged: {
            // 列表加载完，默认选中第1首（不播放）
            if (count > 0 && currentTrackIndex === -1) {
                currentTrackIndex = 0
                var url = get(0, "fileUrl")
                if (url) player.source = url
            }
        }
    }

    // 切歌函数 (用于上一首/下一首按钮)
    function switchTrack(offset) {
        if (folderModel.count === 0) return;
        var nextIndex = currentTrackIndex;

        if (playMode === 1 && offset !== 0) {
            nextIndex = Math.floor(Math.random() * folderModel.count);
        } else {
            nextIndex = currentTrackIndex + offset;
            if (nextIndex >= folderModel.count) nextIndex = 0;
            if (nextIndex < 0) nextIndex = folderModel.count - 1;
        }
        
        // 调用播放
        playByIndex(nextIndex);
    }

    // 核心播放函数
    function playByIndex(index) {
        if (index < 0 || index >= folderModel.count) return;
        currentTrackIndex = index;
        
        // FolderListModel 的 get 方法获取 URL
        var fileUrl = folderModel.get(index, "fileUrl");
        player.source = fileUrl;
        player.play();
    }

    // --- 3. 界面布局 ---
    
    // 3.1 顶部栏
    header: ToolBar {
        height: 30
        background: Rectangle { color: "#1e1e2e" }
        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 5
            ToolButton {
                text: "< 返回"
                contentItem: Text { text: parent.text; color: "white"; font.bold: true; verticalAlignment: Text.AlignVCenter }
                onClicked: { player.stop(); var stack = musicPage.StackView.view; if (stack) stack.pop() }
            }
            Label {
                text: "本地音乐 (" + folderModel.count + "首)"
                color: "white"; font.bold: true; Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            }
            Item { width: 40 }
        }
    }

    // 3.2 中间内容区 (唱片 + 信息)
    Item {
        anchors.top: parent.top
        anchors.bottom: controlRow.top
        anchors.left: volumeArea.right
        anchors.right: parent.right
        
        RowLayout {
            anchors.centerIn: parent
            spacing: 20

            // 唱片
            Rectangle {
                width: 110; height: 110; radius: 55
                color: "#222"; border.color: "#333"; border.width: 2
                Rectangle { anchors.centerIn: parent; width: 65; height: 65; radius: 32.5; color: "#E53935" }
                Rectangle { anchors.centerIn: parent; width: 10; height: 10; radius: 5; color: "#121212" }
                RotationAnimation on rotation { from: 0; to: 360; duration: 5000; loops: Animation.Infinite; running: musicPage.isPlaying }
            }

            // 信息与控制
            ColumnLayout {
                spacing: 5
                Text {
                    text: currentTrackIndex >= 0 ? folderModel.get(currentTrackIndex, "fileName") : "No Music"
                    color: "white"; font.pixelSize: 15; font.bold: true
                    Layout.maximumWidth: 150; elide: Text.ElideRight
                }
                Text { text: "Local Audio"; color: "#888"; font.pixelSize: 12 }
                
                Item { height: 10; width: 1 }

                RowLayout {
                    spacing: 15
                    RoundButton { text: "|<"; onClicked: switchTrack(-1) }
                    RoundButton { 
                        text: musicPage.isPlaying ? "||" : "▶"
                        radius: 25; Layout.preferredWidth: 50; Layout.preferredHeight: 50
                        highlighted: true
                        onClicked: {
                            if (player.playbackState === MediaPlayer.PlayingState) player.pause();
                            else player.play();
                        }
                    }
                    RoundButton { text: ">|"; onClicked: switchTrack(1) }
                }
            }
        }
    }

    // 3.3 左侧音量条
    Item {
        id: volumeArea
        width: 50
        anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: controlRow.top
        z: 20
        Column {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 10; anchors.horizontalCenter: parent.horizontalCenter
            MouseArea {
                width: 40; height: 40; anchors.horizontalCenter: parent.horizontalCenter
                onClicked: { volPopup.visible = !volPopup.visible; if(volPopup.visible) hideTimer.restart() }
                Text { text: "🔊"; font.pixelSize: 20; anchors.centerIn: parent; color: volPopup.visible ? "#00E5FF" : "white" }
            }
            Text { text: Math.round(volSlider.value * 100); color: "white"; font.pixelSize: 10; anchors.horizontalCenter: parent.horizontalCenter }
        }
        Rectangle {
            id: volPopup; visible: false
            width: 36; height: 110; color: "#CC222222"; radius: 18; border.color: "#444"
            anchors.bottom: parent.bottom; anchors.bottomMargin: 55; anchors.horizontalCenter: parent.horizontalCenter
            Slider {
                id: volSlider; orientation: Qt.Vertical; anchors.centerIn: parent; height: parent.height - 20; width: 30
                from: 0; to: 1.0; value: 0.5; onMoved: hideTimer.restart()
            }
        }
        Timer { id: hideTimer; interval: 3000; onTriggered: volPopup.visible = false }
    }

    // 3.4 底部功能栏 + 进度条
    ColumnLayout {
        id: controlRow
        anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 5; spacing: 0

        RowLayout {
            Layout.fillWidth: true; Layout.bottomMargin: 2
            Button {
                flat: true; text: playModeIcons[playMode]
                contentItem: Text { text: parent.text; color: "#ccc"; font.pixelSize: 16; verticalAlignment: Text.AlignVCenter }
                background: Rectangle { color: parent.pressed ? "#333" : "transparent"; radius: 4 }
                onClicked: playMode = (playMode + 1) % 3
            }
            Item { Layout.fillWidth: true }
            Button {
                flat: true; text: "📜 播放清单"
                contentItem: Text { text: parent.text; color: playlistOverlay.visible ? "#00E5FF" : "#ccc"; font.bold: true }
                background: Rectangle { color: parent.pressed ? "#333" : "transparent"; radius: 4 }
                onClicked: playlistOverlay.visible = !playlistOverlay.visible
            }
        }

        Item {
            Layout.fillWidth: true; Layout.preferredHeight: 20
            Slider {
                id: progressSlider; anchors.fill: parent; from: 0; to: player.duration; value: player.position
                onMoved: player.setPosition(value)
                background: Rectangle {
                    x: 0; y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: parent.availableWidth; height: 4; color: "#444"
                    Rectangle { width: parent.parent.visualPosition * parent.width; height: parent.height; color: "#00E5FF" }
                }
                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: 12; height: 12; radius: 6; color: "white"
                }
            }
            Text { text: formatTime(player.position); color: "#ccc"; font.pixelSize: 10; anchors.left: parent.left; anchors.bottom: parent.top }
            Text { text: formatTime(player.duration); color: "#ccc"; font.pixelSize: 10; anchors.right: parent.right; anchors.bottom: parent.top }
        }
    }

    // --- 4. 播放清单浮窗 ---
    Rectangle {
        id: playlistOverlay
        visible: false
        color: "#E6111111" // 深色半透明背景
        radius: 12
        border.color: "#333"
        border.width: 1
        
        // 浮动位置
        anchors.top: parent.top; anchors.bottom: controlRow.top
        anchors.left: parent.left; anchors.right: parent.right
        anchors.margins: 10
        z: 50 // 最顶层

        ColumnLayout {
            anchors.fill: parent; anchors.margins: 10
            Label { text: "播放列表"; color: "white"; font.bold: true; Layout.alignment: Qt.AlignHCenter }
            Rectangle { height: 1; Layout.fillWidth: true; color: "#444" }

            ListView {
                id: listView
                Layout.fillWidth: true; Layout.fillHeight: true
                clip: true
                model: folderModel
                
                // 滚动条
                ScrollBar.vertical: ScrollBar { width: 4; policy: ScrollBar.AsNeeded }

                delegate: Rectangle {
                    width: listView.width
                    height: 35
                    color: index === currentTrackIndex ? "#2200E5FF" : "transparent" // 选中项背景高亮

                    RowLayout {
                        anchors.fill: parent; anchors.leftMargin: 10; anchors.rightMargin: 10
                        
                        // 正在播放的图标指示
                        Text { 
                            text: index === currentTrackIndex ? "▶" : (index + 1)
                            color: index === currentTrackIndex ? "#00E5FF" : "#666"
                            font.bold: true
                            font.pixelSize: 12
                            Layout.preferredWidth: 20
                        }
                        
                        // 文件名
                        Text {
                            text: fileName
                            color: index === currentTrackIndex ? "#00E5FF" : "#ddd" // 选中项文字变色
                            font.bold: index === currentTrackIndex
                            font.pixelSize: 12
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }

                    // --- 核心交互：点击即播 ---
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            currentTrackIndex = index
                            // 直接使用 delegate 上下文中的 fileUrl 属性
                            player.source = fileUrl 
                            player.play()
                            
                            // 如果你希望点击后列表自动关闭，请取消下面这行的注释：
                            // playlistOverlay.visible = false 
                        }
                    }
                }
            }
            
            Button {
                text: "关闭列表"
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredHeight: 30
                background: Rectangle { color: "#333"; radius: 15 }
                contentItem: Text { text: parent.text; color: "white"; font.pixelSize: 12; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
                onClicked: playlistOverlay.visible = false
            }
        }
    }

    function formatTime(ms) {
        if (!ms) return "00:00"
        var totalSec = Math.floor(ms / 1000)
        var m = Math.floor(totalSec / 60)
        var s = totalSec % 60
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
    }
}