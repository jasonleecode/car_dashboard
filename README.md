# Qt6 Car Dashboard UI (车机仪表盘 Demo)

<img width="317" height="217" alt="1766988732666" src="https://github.com/user-attachments/assets/49862b08-1213-42c9-9c39-354ad432a399" />

这是一个基于 **Qt 6 (C++)** 和 **QML** 构建的嵌入式车机（IVI）主界面原型程序。

该项目展示了如何使用 Qt Quick Controls 2 创建现代化的车载用户界面，包含主菜单网格布局、状态栏模拟以及页面导航逻辑。所有 UI 元素（包括图标、电池、信号）均通过 QML 矢量绘制，无需外部图片资源即可运行。

## ✨ 功能特性

* **主界面布局**：采用 `GridLayout` 实现的 2行 4列 宫格菜单（导航、车辆信息、娱乐等）。
* **状态栏模拟**：
    * 右上角：动态绘制的 GPRS 信号强度柱状图 & 电池电量图标。
    * 右下角：实时更新的日期和时间（精确到分钟）。
* **交互动画**：按钮点击时的缩放反馈与高亮边框效果。
* **页面导航**：使用 `StackView` 实现主页与功能详情页之间的平滑切换。
* **零依赖**：不依赖外部 `.png` 或 `.jpg` 资源，编译即运行，方便移植。

## 🛠 环境要求

* **Qt 版本**: Qt 6.2 或更高版本 (主要依赖 `Qt Quick` 和 `Qt Quick Controls 2` 模块)。
* **C++ 标准**: C++ 17。
* **构建工具**: CMake 3.16+。
* **编译器**: MSVC 2019+, GCC, 或 Clang。

## 🚀 如何构建与运行

### 方式一：使用 Qt Creator (推荐)
1.  打开 Qt Creator。
2.  选择 `文件` -> `打开文件或项目`，选中项目根目录下的 `CMakeLists.txt`。
3.  配置构建套件（Kit），确保选择 Qt 6 版本。
4.  点击左下角的 **运行 (Run)** 按钮 (或按 `Ctrl+R`)。

### 方式二：命令行构建
```bash
# 1. 创建构建目录
mkdir build
cd build

# 2. 生成构建文件 (请确保 qmake/cmake 在环境变量中)
cmake .. 

# 3. 编译
cmake --build .

# 4. 运行
./appCarDashboard  # Windows 下为 Debug/appCarDashboard.exe
