cmake_minimum_required(VERSION 3.16)

project(CarDashboard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 添加 SerialPort 模块
find_package(Qt6 6.2 REQUIRED COMPONENTS Quick QuickControls2 SerialPort)

qt_standard_project_setup()

qt_add_executable(appCarDashboard
    main.cpp
    HardwareBackend.cpp
    HardwareBackend.h
)

qt_add_qml_module(appCarDashboard
    URI Main
    VERSION 1.0
    QML_FILES Main.qml
)

# 链接 SerialPort 库
target_link_libraries(appCarDashboard
    PRIVATE Qt6::Quick Qt6::QuickControls2 Qt6::SerialPort
)