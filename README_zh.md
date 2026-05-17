# EasyChat
<p align="center">
  <strong>现代 AI 聊天客户端</strong> — 基于 Qt 6 / QML，自研组件库，Mica 模糊无边框窗口，流式 Markdown 渲染。
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Qt-6.8%2B-brightgreen" alt="Qt 6.8+">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT License">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/C%2B%2B-17-blue" alt="C++17">
</p>

**[English](README.md) · 中文**

---

## 功能特性

### AI 聊天

- 多会话聊天，兼容 OpenAI API
- 流式响应，实时 Markdown 渲染
- 推理模式（DeepSeek-R1、o1 风格思维链）
- 联网搜索集成
- 函数调用（工具调用），支持多轮对话
- 系统提示词自定义
- 每会话 Token 用量统计
- 聊天记录：置顶、分组、搜索、导入/导出
- 内置提示词库，含角色预设
- 模型配置管理（Base URL、API Key、最大 Token、供应商标识）

### EasyUI 组件库

50+ 生产级 QML 组件，覆盖 7 大分类：

| 分类 | 数量 | 组件 |
|------|------|------|
| **基础** | 23 | Button、ButtonGroup、Input、NumberInput、IPInput、MACInput、TextArea、SearchInput、Select、DatePicker、TimePicker、ColorPicker、Cascader、DropDown、Switch、Checkbox、Radio、RadioGroup、Slider、Progress、Tag、ChipInput、Icon、IconFont |
| **展示** | 22 | Card、Divider、Collapse、Shadow、Table、Avatar、Timeline、Empty、Skeleton、Carousel、Lyric、Chart、Toggle、Rate、ImageViewer、QRCode、Watermark、FloatingActionButton、FileDropZone、SplitPane、ScrollBar、Pagination |
| **反馈** | 7 | Dialog、Drawer、Alert、Toast、Tooltip、Loading、Badge |
| **导航** | 9 | MenuBar、MenuButton、ContextMenu、TabBar、Breadcrumb、TreeView、Segmented、CommandPalette、Wizard |
| **窗口** | 3 | FramelessWindow、SimpleWindow、SingletonWindow |
| **Markdown** | 9 | MarkdownView、MarkdownBlock、MarkdownCodeBlock、MarkdownHeading、MarkdownHtmlBlock、MarkdownImage、MarkdownInlineText、MarkdownListItem、MarkdownTable |
| **主题** | — | 完整主题引擎：暗色/亮色模式、主色、圆角、字号、自定义 CSS 注入 |

### 窗口与界面

- Windows 11 Mica / Acrylic 模糊效果（基于 [QWindowKit](https://github.com/stdware/qwindowkit)）
- 自定义窗口栏：最小化、最大化、关闭、全屏、置顶
- 系统托盘支持
- 高 DPI 适配
- 流畅的页面切换与动画

### Markdown 渲染

- 通过 [cmark-gfm](https://github.com/github/cmark-gfm) + 扩展支持 GitHub Flavored Markdown
- 自研 QML 渲染器（非 WebView）
- 代码块语法高亮（基于 [md4c](https://github.com/mity/md4c)）
- 表格、任务列表、删除线、图片、链接
- 适合流式输出的增量渲染

### 开发者工具

- 内置代码编辑器，支持语法高亮与文件树
- 组件库带实时示例页面和 API 文档
- 主题编辑器，实时预览

---

## 截图展示

### AI 聊天

<p align="center">
  <img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/main.png" alt="主聊天界面" width="700">
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/ai-assistant.png" alt="AI 助手" width="700">
</p>

### EasyUI 组件库

<table>
  <tr>
    <td align="center"><b>基础组件</b></td>
    <td align="center"><b>基础组件</b></td>
    <td align="center"><b>基础组件</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/button.png" alt="Button" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/input.png" alt="Input" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/select.png" alt="Select" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>基础组件</b></td>
    <td align="center"><b>基础组件</b></td>
    <td align="center"><b>基础组件</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/cascader.png" alt="Cascader" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/dropdown.png" alt="DropDown" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/chipInput.png" alt="ChipInput" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>基础组件</b></td>
    <td align="center"><b>基础组件</b></td>
    <td align="center"><b>基础组件</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/switch_check_radio_toggle.png" alt="Switch / Checkbox / Radio / Toggle" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/slider_rate_segmented.png" alt="Slider / Rate / Segmented" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/colorpicker.png" alt="ColorPicker" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>基础组件</b></td>
    <td align="center"><b>展示组件</b></td>
    <td align="center"><b>展示组件</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/material_icon.png" alt="Material Icon" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/divider_card_carousel_lyric_icon_markdownview.png" alt="Card / Carousel / MarkdownView" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/badge_tag_avatar_progress_loading_skeleton_empty_timeline.png" alt="Badge / Tag / Avatar / Progress / Timeline" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>展示组件</b></td>
    <td align="center"><b>展示组件</b></td>
    <td align="center"><b>展示组件</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/table_pagination_transfer.png" alt="Table / Pagination / Transfer" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/chart.png" alt="Chart" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/imgview.png" alt="ImageViewer" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>展示组件</b></td>
    <td align="center"><b>展示组件</b></td>
    <td align="center"><b>展示组件</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/qrcode.png" alt="QRCode" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/watermask.png" alt="Watermark" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/floating_action_button.png" alt="FloatingActionButton" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>展示组件</b></td>
    <td align="center"><b>反馈组件</b></td>
    <td align="center"><b>导航组件</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/filedropzone.png" alt="FileDropZone" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/alert_tooltip_dialog_drawer.png" alt="Alert / Tooltip / Dialog / Drawer" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/breadcrumb_tabbar_treeview_collapse.png" alt="Breadcrumb / TabBar / TreeView" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>导航组件</b></td>
    <td align="center"><b>导航组件</b></td>
    <td></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/menubar.png" alt="MenuBar" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/main/imgs/components/commandpalette.png" alt="CommandPalette" width="300"></td>
    <td></td>
  </tr>
</table>

---

## 技术栈

| 层级 | 技术 |
|------|------|
| 界面框架 | Qt 6.8+ / QML |
| 窗口装饰 | QWindowKit（无边框 + Mica） |
| Markdown 解析 | cmark-gfm + cmark-gfm-extensions |
| 语法高亮 | md4c |
| 数据存储 | SQLite (Qt Sql) |
| 网络通信 | Qt Network (HTTP/SSE) |
| 构建系统 | CMake 3.16+ |
| 编译器 | MSVC 2022 / GCC 11+ / Clang 15+ |

---

## 快速开始

### 环境依赖

| 依赖 | 版本 | 说明 |
|------|------|------|
| Qt | ≥ 6.8 | 模块：Quick、QuickControls2、Sql、Network |
| CMake | ≥ 3.16 | |
| C++ 编译器 | C++17 | MSVC 2022、GCC 11+、Clang 15+ |
| QWindowKit | — | 预编译库已包含在 `EasyUI/third_party/qwindowkit/` |

### 构建（Windows / MSVC）

```bash
# 配置
cmake -B build -S . -G "Ninja" \
  -DCMAKE_PREFIX_PATH="F:/QT/6.10.3/msvc2022_64" \
  -DCMAKE_BUILD_TYPE=Release

# 构建
cmake --build build
```

或使用快捷脚本：

```bash
.\build_release.bat
```

### 构建（Linux）

```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

### 构建（macOS）

```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

---

## 部署（Windows）

使用 `deploy.ps1` 生成独立可分发目录：

```powershell
.\deploy.ps1
```

脚本会自动完成：
1. 通过 VS 开发命令行编译 Release 版本
2. 复制 `EasyChat.exe`、`EasyUI.dll`、QWindowKit DLL 到 `deploy/`
3. 运行 `windeployqt` 解析 Qt 依赖
4. 复制 QML 模块目录（`EasyChat/`、`EasyUI/`）

输出：`deploy/` 目录，可直接分发。

环境变量：

| 变量 | 用途 | 默认值 |
|------|------|--------|
| `QT_DIR` | Qt 安装路径 | 自动检测常见路径 |
| `VSDEVCMD` | `VsDevCmd.bat` 路径 | 通过 `vswhere` 自动检测 |

---

## 项目结构

```
EasyChat/
├── main.cpp                       # C++ 入口
├── main.qml                       # QML 入口窗口
├── handler.h / handler.cpp        # QML 暴露的应用级工具类
├── markdownconverter.h / .cpp     # cmark-gfm → QML 桥接（C++）
├── ModelConfigManager.h / .cpp    # 模型配置持久化
├── ClipboardHelper.h / .cpp       # 系统剪贴板工具
│
├── EasyUI/                        # 自研 QML 组件库
│   ├── src/                       # C++ 后端
│   │   ├── EasyUI.h / .cpp        # 库初始化 + QML 插件注册
│   │   ├── ToastManager.h / .cpp  # Toast 命令式 API
│   │   ├── WindowHelper.h / .cpp  # 窗口控制工具
│   │   ├── DynamicTableModel.h / .cpp
│   │   └── markdown/              # C++ Markdown 数据结构
│   ├── qml/
│   │   ├── basic/                 # 输入 / 选择控件
│   │   ├── display/               # 数据展示 + 装饰
│   │   ├── feedback/              # 对话框、提示、通知
│   │   ├── navigation/            # 菜单、标签、面包屑
│   │   ├── window/                # 无边框窗口变体
│   │   ├── theme/                 # 主题引擎 + 设置面板
│   │   ├── transfer/              # 多栏穿梭框
│   │   └── markdownview/          # 自研 QML Markdown 渲染器
│   ├── third_party/qwindowkit/    # 预编译 QWindowKit DLL
│   └── CMakeLists.txt
│
├── openapi/                       # AI 聊天 C++ 后端
│   ├── openaimanager.h / .cpp     # HTTP 客户端 + 流式 SSE 解析
│   ├── chatmanager.h / .cpp       # 多会话生命周期管理
│   ├── chatsession.h / .cpp       # 单个聊天会话状态
│   ├── chatmessage.h / .cpp       # 消息模型（角色、内容、附件）
│   ├── openaiconfig.h / .cpp      # API 端点配置
│   ├── promptmanager.h / .cpp     # 提示词库增删改查
│   ├── websearchmanager.h / .cpp  # 联网搜索集成
│   └── toolregistry.h / .cpp      # 函数调用 / 工具注册
│
├── views/                         # QML 应用页面
│   ├── ChatPage.qml               # 主聊天界面
│   ├── HomePage.qml               # 仪表盘 / 会话列表
│   ├── SettingsWindow.qml         # 模型配置
│   ├── ThemeSettingsWindow.qml    # 主题定制
│   ├── PromptLibraryPage.qml      # 提示词管理
│   ├── ComponentsPage.qml         # 组件库浏览器
│   ├── CodeEditorPage.qml         # 内置代码编辑器
│   ├── componentPages/            # 各组件示例 + API 文档
│   └── components/                # 各组件代码示例
│
├── cmark_gfm/                     # cmark-gfm 静态库 + 头文件
├── md4c/                          # md4c 源码（语法高亮）
├── demo/                          # 最小化 EasyUI 独立示例项目
├── res/                           # 图标、字体、QRC 资源
├── deploy.ps1                     # 发布构建 + 部署脚本
├── build_release.bat              # 快捷 MSVC Release 构建脚本
├── CMakeLists.txt                 # 根 CMake 文件
└── LICENSE                        # MIT
```

---

## EasyUI 快速上手

### 在 EasyChat 仓库内（嵌入式使用）

```cpp
// main.cpp
#include <EasyUI.h>
QQmlApplicationEngine engine;
EasyUI::initialize(&engine);
```

```qml
// main.qml
import EasyUI

EasyFramelessWindow {
    EasyButton { text: "点我" }
}
```

### 独立项目使用

参见 `demo/` 目录，这是一个最小化的独立示例，将 EasyUI 作为 DLL 链接。

```bash
cmake -B build_demo -S demo -DCMAKE_PREFIX_PATH="F:/QT/6.10.3/msvc2022_64"
cmake --build build_demo
```

---

## 配置

### 模型提供商

EasyChat 兼容所有 OpenAI 格式的 API：

| 提供商 | Base URL |
|--------|----------|
| OpenAI | `https://api.openai.com/v1` |
| DeepSeek | `https://api.deepseek.com/v1` |
| Ollama（本地） | `http://localhost:11434/v1` |
| 自定义代理 | 任意兼容端点 |

通过 **设置** → 选择模型 → 填写 API Key、Base URL、最大 Token 即可配置。

### 主题定制

所有设置通过 `QSettings` 持久化：

- **模式**：暗色 / 亮色
- **主色**：任意十六进制颜色
- **圆角**：0–24px
- **字号**：12–24px
- **自定义 CSS**：注入任意样式表

---

## 架构

```
┌──────────────────────────────────────────┐
│  QML 层 (main.qml + views/)              │
│  ┌──────────┐  ┌─────────────────────┐  │
│  │ 聊天界面 │  │ 组件库              │  │
│  │(流式渲染)│  │ (EasyUI QML 插件)   │  │
│  └────┬─────┘  └──────────┬──────────┘  │
│       │                   │              │
├───────┼───────────────────┼──────────────┤
│  C++ 后端                │              │
│  ┌──────┐  ┌──────────┐  │              │
│  │OpenAI│  │Markdown  │  │              │
│  │Manager│ │Converter │  │              │
│  │(HTTP)│  │(gfm→QML) │  │              │
│  └──┬───┘  └────┬─────┘  │              │
│     │           │         │              │
│  ┌──┴───┐  ┌────┴─────┐  │              │
│  │cmark-│  │EasyUI src│  │              │
│  │gfm   │  │(C++ 实现)│  │              │
│  └──────┘  └──────────┘  │              │
│  ┌────────┐               │              │
│  │SQLite  │               │              │
│  │(Qt Sql)│               │              │
│  └────────┘               │              │
└──────────────────────────────────────────┘
```

- **QML ↔ C++ 桥接**：聊天会话、Markdown 解析、模型配置均以 QML 可调用类型暴露
- **流式传输**：C++ 解析 SSE 分块，信号发射，QML 增量渲染
- **EasyUI**：独立 CMake 目标（`EasyUI`），编译为共享库 + QML 插件，可独立使用

---

## 贡献

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/my-feature`
3. 提交修改：`git commit -m "Add my feature"`
4. 推送：`git push origin feature/my-feature`
5. 发起 Pull Request

### 添加新的 EasyUI 组件

1. 在 `EasyUI/qml/<分类>/` 中添加 `EasyMyComponent.qml`
2. 在 `views/componentPages/` 中创建 `EasyMyComponentPage.qml`
3. 在 `views/components/` 中创建 `EasyMyComponentExample.qml`
4. 在根 `CMakeLists.txt` 中注册两个 QML 文件
5. 构建并在组件浏览器中验证

---

## 常见问题

**Q：windeployqt 失败或 Qt DLL 缺失？**

确保 `QT_DIR` 环境变量指向 Qt MSVC 安装路径（如 `F:\QT\6.10.3\msvc2022_64`）。部署脚本会自动检测常见路径。

**Q：找不到 cmark-gfm 库？**

cmark-gfm 静态库需要预编译并放在 `cmark_gfm/` 目录下。Windows 下需确保 `cmark-gfm_static.lib` 和 `cmark-gfm-extensions_static.lib` 都存在。

**Q：找不到 QWindowKit DLL？**

预编译二进制文件应位于 `EasyUI/third_party/qwindowkit/`。如 Qt 版本不同，需从源码编译 QWindowKit。

**Q：可以只使用 EasyUI 而不用聊天功能吗？**

可以。EasyUI 是独立库。参见 `demo/` 目录的最小化示例。

---

## 致谢

- [QWindowKit](https://github.com/stdware/qwindowkit) — 无边框窗口 + Mica 模糊效果
- [cmark-gfm](https://github.com/github/cmark-gfm) — GitHub Flavored Markdown 解析器
- [md4c](https://github.com/mity/md4c) — Markdown / 语法高亮解析器
- [Material Symbols](https://fonts.google.com/icons) — 图标字体
- [Qt](https://www.qt.io/) — 跨平台 UI 框架

## 许可证

MIT License — 详见 [LICENSE](LICENSE)。