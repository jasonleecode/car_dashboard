import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import QtQuick.Dialogs // 用于文件选择对话框

Page {
    id: videoPage
    title: "车载影院"
    
    background: Rectangle { color: "black" }

    // --- 1. 播放器核心 ---
    MediaPlayer {
        id: player
        audioOutput: AudioOutput {
            id: audio
            volume: volumeSlider.value
        }
        videoOutput: videoOutput
        
        // 监听播放状态，播放结束自动重置
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState) {
                controls.visible = true
            }
        }
    }

    // --- 2. 视频显示区域 ---
    VideoOutput {
        id: videoOutput
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectFit // 保持比例，留黑边
        
        // 交互层：点击屏幕切换控制栏显示/隐藏
        MouseArea {
            anchors.fill: parent
            onClicked: controls.visible = !controls.visible
        }
    }

    // --- 3. 顶部标题栏 (浮层) ---
    ToolBar {
        id: topBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 40
        visible: controls.visible // 与底部栏同步
        background: Rectangle { color: "#80000000" } // 半透明黑

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 10
            
            ToolButton {
                text: "< 返回"
                contentItem: Text { text: parent.text; color: "white"; font.bold: true; verticalAlignment: Text.AlignVCenter }
                onClicked: {
                    player.stop() // 退出必须停止，否则声音还在
                    var stack = videoPage.StackView.view
                    if (stack) stack.pop()
                }
            }
            Label {
                text: "视频播放"
                color: "white"; font.bold: true; font.pixelSize: 16
                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
            }
            // 打开文件按钮 (方便调试)
            ToolButton {
                text: "📂 打开"
                contentItem: Text { text: parent.text; color: "white"; font.bold: true; verticalAlignment: Text.AlignVCenter }
                onClicked: fileDialog.open()
            }
        }
    }

    // --- 4. 底部控制栏 (浮层) ---
    Rectangle {
        id: controls
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: "#90000000" // 半透明底
        visible: true

        // 5秒无操作自动隐藏
        Timer {
            interval: 5000; running: controls.visible && player.playbackState === MediaPlayer.PlayingState
            onTriggered: controls.visible = false
        }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 15

            // 播放/暂停
            RoundButton {
                text: player.playbackState === MediaPlayer.PlayingState ? "⏸" : "▶"
                Layout.preferredWidth: 40; Layout.preferredHeight: 40
                radius: 20
                onClicked: player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play()
            }

            // 当前时间
            Text {
                text: formatTime(player.position)
                color: "white"; font.pixelSize: 12
            }

            // 进度条
            Slider {
                id: progressSlider
                Layout.fillWidth: true
                from: 0
                to: player.duration
                value: player.position
                
                // 拖动时，先暂停更新，松手后跳转
                onMoved: {
                    player.setPosition(value)
                }
            }

            // 总时间
            Text {
                text: formatTime(player.duration)
                color: "white"; font.pixelSize: 12
            }

            // 音量
            Text { text: "🔊"; color: "white" }
            Slider {
                id: volumeSlider
                Layout.preferredWidth: 80
                from: 0; to: 1.0; value: 1.0
            }
        }
    }

    // --- 5. 文件选择器 ---
    FileDialog {
        id: fileDialog
        title: "选择视频文件"
        nameFilters: ["Video files (*.mp4 *.avi *.mov *.mkv)", "All files (*)"]
        onAccepted: {
            player.source = selectedFile
            player.play()
            console.log("Loading video: " + selectedFile)
        }
    }

    // 辅助函数：毫秒转 mm:ss
    function formatTime(ms) {
        if (!ms) return "00:00"
        var totalSeconds = Math.floor(ms / 1000)
        var m = Math.floor(totalSeconds / 60)
        var s = totalSeconds % 60
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s)
    }
}