cmake_minimum_required(VERSION 3.16)

project(CarDashboard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 引入必要的模块
find_package(Qt6 6.2 REQUIRED COMPONENTS Quick QuickControls2 SerialPort Location Positioning Multimedia)

# --- 【新增】设置策略，消除 QTP0001 警告 ---
qt_policy(SET QTP0001 NEW) 

qt_standard_project_setup()

qt_add_executable(appCarDashboard
    main.cpp
    HardwareBackend.cpp
    HardwareBackend.h
)

qt_add_qml_module(appCarDashboard
    URI Main
    VERSION 1.0
    # --- 【新增】强制指定资源前缀为根目录 ---
    # 这样你的 main.cpp 里的 "qrc:/Main/Main.qml" 依然有效
    RESOURCE_PREFIX "/" 
    
    QML_FILES
        Main.qml
        NavigationPage.qml
        RadioPage.qml
        MusicPage.qml
        VideoPage.qml
        CarInfoPage.qml
)

target_link_libraries(appCarDashboard
    PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::SerialPort
    Qt6::Location
    Qt6::Positioning
    Qt6::Multimedia
)