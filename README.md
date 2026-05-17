# EasyChat

<p align="center">
  <strong>Modern AI chat client</strong> — Qt 6 / QML, custom component library, Mica-blur frameless window, streaming Markdown rendering.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Qt-6.8%2B-brightgreen" alt="Qt 6.8+">
  <img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT License">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-lightgrey" alt="Platform">
  <img src="https://img.shields.io/badge/C%2B%2B-17-blue" alt="C++17">
</p>

**English · [中文](README_zh.md)**

---

## Features

### AI Chat

- Multi-session chat with OpenAI-compatible APIs
- Streaming responses with real-time Markdown rendering
- Reasoning mode (DeepSeek-R1, o1-style chain-of-thought)
- Web search integration
- Function calling (tool use) with multi-round support
- System prompt customization
- Per-session token usage statistics
- Chat history: pin, group, search, import/export
- Built-in prompt library with role presets
- Model configuration management (base URL, API key, max tokens, vendor code)

### EasyUI Component Library

50+ production-ready QML components across 7 categories:

| Category | Count | Components |
|----------|-------|------------|
| **Basic** | 23 | Button, ButtonGroup, Input, NumberInput, IPInput, MACInput, TextArea, SearchInput, Select, DatePicker, TimePicker, ColorPicker, Cascader, DropDown, Switch, Checkbox, Radio, RadioGroup, Slider, Progress, Tag, ChipInput, Icon, IconFont |
| **Display** | 22 | Card, Divider, Collapse, Shadow, Table, Avatar, Timeline, Empty, Skeleton, Carousel, Lyric, Chart, Toggle, Rate, ImageViewer, QRCode, Watermark, FloatingActionButton, FileDropZone, SplitPane, ScrollBar, Pagination |
| **Feedback** | 7 | Dialog, Drawer, Alert, Toast, Tooltip, Loading, Badge |
| **Navigation** | 9 | MenuBar, MenuButton, ContextMenu, TabBar, Breadcrumb, TreeView, Segmented, CommandPalette, Wizard |
| **Window** | 3 | FramelessWindow, SimpleWindow, SingletonWindow |
| **Markdown** | 9 | MarkdownView, MarkdownBlock, MarkdownCodeBlock, MarkdownHeading, MarkdownHtmlBlock, MarkdownImage, MarkdownInlineText, MarkdownListItem, MarkdownTable |
| **Theme** | — | Full theme engine: dark/light mode, primary color, corner radius, font size, custom CSS injection |

### Window & UI

- Windows 11 Mica/Acrylic blur via [QWindowKit](https://github.com/stdware/qwindowkit)
- Custom window bar: min/max/close, fullscreen, always-on-top
- System tray support
- High-DPI aware
- Smooth page transitions and animations

### Markdown Rendering

- GitHub Flavored Markdown via [cmark-gfm](https://github.com/github/cmark-gfm) + extensions
- Custom QML renderer (not a WebView)
- Code blocks with syntax highlighting (via [md4c](https://github.com/mity/md4c))
- Tables, task lists, strikethrough, images, links
- Streaming-friendly incremental rendering

### Developer Tools

- Built-in code editor with syntax highlighting and file tree
- Component library with live demo pages and API docs for every component
- Theme editor with real-time preview

---

## Screenshots

### AI Chat

<p align="center">
  <img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/main.png" alt="Main Chat Interface" width="700">
</p>

<p align="center">
  <img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/ai-assistant.png" alt="AI Assistant" width="700">
</p>

### EasyUI Components

<table>
  <tr>
    <td align="center"><b>Basic</b></td>
    <td align="center"><b>Basic</b></td>
    <td align="center"><b>Basic</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/button.png" alt="Button" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/input.png" alt="Input" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/select.png" alt="Select" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>Basic</b></td>
    <td align="center"><b>Basic</b></td>
    <td align="center"><b>Basic</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/cascader.png" alt="Cascader" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/dropdown.png" alt="DropDown" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/chipInput.png" alt="ChipInput" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>Basic</b></td>
    <td align="center"><b>Basic</b></td>
    <td align="center"><b>Basic</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/switch_check_radio_toggle.png" alt="Switch / Checkbox / Radio / Toggle" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/slider_rate_segmented.png" alt="Slider / Rate / Segmented" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/colorpicker.png" alt="ColorPicker" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>Basic</b></td>
    <td align="center"><b>Display</b></td>
    <td align="center"><b>Display</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/material_icon.png" alt="Material Icon" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/divider_card_carousel_lyric_icon_markdownview.png" alt="Card / Carousel / MarkdownView" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/badge_tag_avatar_progress_loading_skeleton_empty_timeline.png" alt="Badge / Tag / Avatar / Progress / Timeline" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>Display</b></td>
    <td align="center"><b>Display</b></td>
    <td align="center"><b>Display</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/table_pagination_transfer.png" alt="Table / Pagination / Transfer" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/chart.png" alt="Chart" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/imgview.png" alt="ImageViewer" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>Display</b></td>
    <td align="center"><b>Display</b></td>
    <td align="center"><b>Display</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/qrcode.png" alt="QRCode" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/watermask.png" alt="Watermark" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/floating_action_button.png" alt="FloatingActionButton" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>Display</b></td>
    <td align="center"><b>Feedback</b></td>
    <td align="center"><b>Navigation</b></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/filedropzone.png" alt="FileDropZone" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/alert_tooltip_dialog_drawer.png" alt="Alert / Tooltip / Dialog / Drawer" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/breadcrumb_tabbar_treeview_collapse.png" alt="Breadcrumb / TabBar / TreeView" width="300"></td>
  </tr>
  <tr>
    <td align="center"><b>Navigation</b></td>
    <td align="center"><b>Navigation</b></td>
    <td></td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/menubar.png" alt="MenuBar" width="300"></td>
    <td><img src="https://raw.githubusercontent.com/wanghonghust/EasyUI/refs/heads/main/imgs/components/commandpalette.png" alt="CommandPalette" width="300"></td>
    <td></td>
  </tr>
</table>

---

## Tech Stack

| Layer | Technology |
|-------|------------|
| UI Framework | Qt 6.8+ / QML |
| Window Decorations | QWindowKit (frameless + Mica) |
| Markdown Parsing | cmark-gfm + cmark-gfm-extensions |
| Syntax Highlighting | md4c |
| Storage | SQLite (Qt Sql) |
| HTTP / SSE | Qt Network |
| Build System | CMake 3.16+ |
| Compiler | MSVC 2022 / GCC 11+ / Clang 15+ |

---

## Quick Start

### Prerequisites

| Dependency | Version | Notes |
|------------|---------|-------|
| Qt | ≥ 6.8 | Modules: Quick, QuickControls2, Sql, Network |
| CMake | ≥ 3.16 | |
| C++ Compiler | C++17 | MSVC 2022, GCC 11+, Clang 15+ |
| QWindowKit | — | Prebuilt binaries included in `EasyUI/third_party/qwindowkit/` |

### Build (Windows / MSVC)

```bash
# Configure
cmake -B build -S . -G "Ninja" \
  -DCMAKE_PREFIX_PATH="F:/QT/6.10.3/msvc2022_64" \
  -DCMAKE_BUILD_TYPE=Release

# Build
cmake --build build
```

Or use the convenience script:

```bash
.\build_release.bat
```

### Build (Linux)

> **Note:** Linux build has not been tested yet.

```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

### Build (macOS)

> **Note:** macOS build has not been tested yet.

```bash
cmake -B build -S . -DCMAKE_BUILD_TYPE=Release
cmake --build build
```

---

## Deployment (Windows)

Use `deploy.ps1` to create a standalone distribution:

```powershell
.\deploy.ps1
```

The script performs:
1. Compiles Release build via VS dev command prompt
2. Copies `EasyChat.exe`, `EasyUI.dll`, QWindowKit DLLs to `deploy/`
3. Runs `windeployqt` to resolve Qt dependencies
4. Copies QML module directories (`EasyChat/`, `EasyUI/`)

Output: self-contained directory at `deploy/` ready for distribution.

Environment variables:

| Variable | Purpose | Default |
|----------|---------|---------|
| `QT_DIR` | Path to Qt installation | Auto-detect from common paths |
| `VSDEVCMD` | Path to `VsDevCmd.bat` | Auto-detect via `vswhere` |

---

## Project Structure

```
EasyChat/
├── main.cpp                       # C++ entry point
├── main.qml                       # QML entry window
├── handler.h / handler.cpp        # QML-exposed app-level utilities
├── markdownconverter.h / .cpp     # cmark-gfm → QML bridge (C++)
├── ModelConfigManager.h / .cpp    # Model configuration persistence
├── ClipboardHelper.h / .cpp       # System clipboard utility
│
├── EasyUI/                        # Custom QML component library
│   ├── src/                       # C++ backend
│   │   ├── EasyUI.h / .cpp        # Library init + QML plugin registration
│   │   ├── ToastManager.h / .cpp  # Imperative toast API
│   │   ├── WindowHelper.h / .cpp  # Window control utilities
│   │   ├── DynamicTableModel.h / .cpp
│   │   └── markdown/              # C++ markdown data structures
│   ├── qml/
│   │   ├── basic/                 # Input/selection controls
│   │   ├── display/               # Data display + decoration
│   │   ├── feedback/              # Dialogs, alerts, notifications
│   │   ├── navigation/            # Menus, tabs, breadcrumbs
│   │   ├── window/                # Frameless window variants
│   │   ├── theme/                 # Theme engine + settings panel
│   │   ├── transfer/              # Multi-column transfer widget
│   │   └── markdownview/          # Custom QML Markdown renderer
│   ├── third_party/qwindowkit/    # Prebuilt QWindowKit DLLs
│   └── CMakeLists.txt
│
├── openapi/                       # AI chat C++ backend
│   ├── openaimanager.h / .cpp     # HTTP client + streaming SSE parser
│   ├── chatmanager.h / .cpp       # Multi-session lifecycle management
│   ├── chatsession.h / .cpp       # Single chat session state
│   ├── chatmessage.h / .cpp       # Message model (role, content, attachments)
│   ├── openaiconfig.h / .cpp      # API endpoint configuration
│   ├── promptmanager.h / .cpp     # Prompt library CRUD
│   ├── websearchmanager.h / .cpp  # Web search integration
│   └── toolregistry.h / .cpp      # Function calling / tool registry
│
├── views/                         # QML app pages
│   ├── ChatPage.qml               # Main chat interface
│   ├── HomePage.qml               # Dashboard / session list
│   ├── SettingsWindow.qml         # Model configuration
│   ├── ThemeSettingsWindow.qml    # Theme customization
│   ├── PromptLibraryPage.qml      # Prompt management
│   ├── ComponentsPage.qml         # Component library browser
│   ├── CodeEditorPage.qml         # Built-in code editor
│   ├── componentPages/            # Per-component demo + API docs
│   └── components/                # Per-component example snippets
│
├── cmark_gfm/                     # cmark-gfm static libraries + headers
├── md4c/                          # md4c source (syntax highlighting)
├── demo/                          # Minimal standalone EasyUI demo project
├── res/                           # Icons, fonts, QRC resources
├── deploy.ps1                     # Release build + deployment script
├── build_release.bat              # Quick MSVC release build script
├── CMakeLists.txt                 # Root CMake file
└── LICENSE                        # MIT
```

---

## EasyUI Quick Start

### From EasyChat repo (in-tree)

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
    EasyButton { text: "Click me" }
}
```

### Standalone project

See `demo/` for a minimal self-contained example that links EasyUI as a DLL.

```bash
cmake -B build_demo -S demo -DCMAKE_PREFIX_PATH="F:/QT/6.10.3/msvc2022_64"
cmake --build build_demo
```

---

## Configuration

### Model Providers

EasyChat works with any OpenAI-compatible API:

| Provider | Base URL |
|----------|----------|
| OpenAI | `https://api.openai.com/v1` |
| DeepSeek | `https://api.deepseek.com/v1` |
| Ollama (local) | `http://localhost:11434/v1` |
| Custom proxy | Any compatible endpoint |

Configure via **Settings** → select model → set API key, base URL, max tokens.

### Theme Customization

All persisted via `QSettings`:

- **Mode**: Dark / Light
- **Primary Color**: Any hex color
- **Corner Radius**: 0–24px
- **Font Size**: 12–24px
- **Custom CSS**: Inject arbitrary stylesheets

---

## Architecture

```
┌─────────────────────────────────────────┐
│  QML Layer (main.qml + views/)          │
│  ┌──────────┐  ┌──────────────────────┐ │
│  │ Chat UI  │  │ Component Library    │ │
│  │ (stream  │  │ (EasyUI QML plugin)  │ │
│  │  render) │  │                      │ │
│  └────┬─────┘  └──────────┬───────────┘ │
│       │                   │             │
├───────┼───────────────────┼─────────────┤
│  C++ Backend              │             │
│  ┌──────┐  ┌──────────┐   │             │
│  │OpenAPI│  │Markdown  │   │             │
│  │Manager│  │Converter │   │             │
│  │(HTTP) │  │(gfm→QML) │   │             │
│  └──┬───┘  └────┬─────┘   │             │
│     │           │         │             │
│  ┌──┴───┐  ┌────┴─────┐  │             │
│  │cmark-│  │EasyUI src│  │             │
│  │gfm   │  │(C++ impl)│  │             │
│  └──────┘  └──────────┘  │             │
│  ┌────────┐               │             │
│  │SQLite  │               │             │
│  │(Qt Sql)│               │             │
│  └────────┘               │             │
└─────────────────────────────────────────┘
```

- **QML ↔ C++ bridge**: Chat sessions, markdown parsing, model config exposed as QML-invokable types
- **Streaming**: SSE chunks parsed in C++, emitted as signals, rendered incrementally in QML
- **EasyUI**: Separate CMake target (`EasyUI`), built as shared library with QML plugin, usable standalone

---

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/my-feature`
3. Commit changes: `git commit -m "Add my feature"`
4. Push: `git push origin feature/my-feature`
5. Open a pull request

### Adding a new EasyUI component

1. Add `EasyMyComponent.qml` to appropriate `EasyUI/qml/<category>/`
2. Create `EasyMyComponentPage.qml` in `views/componentPages/`
3. Create `EasyMyComponentExample.qml` in `views/components/`
4. Register both QML files in root `CMakeLists.txt`
5. Build and verify in the component browser

---

## FAQ

**Q: windeployqt fails or Qt DLLs are missing?**

Ensure `QT_DIR` environment variable points to your Qt MSVC installation (e.g., `F:\QT\6.10.3\msvc2022_64`). The deploy script auto-detects common paths.

**Q: cmark-gfm library not found?**

cmark-gfm static libraries must be prebuilt and placed in `cmark_gfm/`. On Windows, ensure both `cmark-gfm_static.lib` and `cmark-gfm-extensions_static.lib` are present.

**Q: QWindowKit DLLs not found?**

Prebuilt binaries are expected at `EasyUI/third_party/qwindowkit/`. Build QWindowKit from source if your Qt version differs.

**Q: Can I use EasyUI without the chat features?**

Yes. EasyUI is a standalone library. See `demo/` for a minimal example that only uses EasyUI components and the frameless window.

---

## Acknowledgements

- [QWindowKit](https://github.com/stdware/qwindowkit) — Frameless window + Mica blur
- [cmark-gfm](https://github.com/github/cmark-gfm) — GitHub Flavored Markdown parser
- [md4c](https://github.com/mity/md4c) — Markdown / syntax highlighting parser
- [Material Symbols](https://fonts.google.com/icons) — Icon font
- [Qt](https://www.qt.io/) — Cross-platform UI framework

## License

MIT License — see [LICENSE](LICENSE) for details.
