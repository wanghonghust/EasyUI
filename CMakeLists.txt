cmake_minimum_required(VERSION 3.16)

project(EasyChat VERSION 0.1 LANGUAGES CXX C)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Dev: disable QML AOT cache so editing .qml doesn't need clean rebuild
# Remove or set to OFF for release builds
option(QML_NO_CACHEGEN "Disable QML ahead-of-time compilation" ON)
if(QML_NO_CACHEGEN)
    set(QT_QML_NO_CACHEGEN ON CACHE BOOL "Disable QML cachegen" FORCE)
endif()

find_package(Qt6 6.8 COMPONENTS Quick Sql QuickControls2 REQUIRED)

# 强制 Release 也生成调试信息
if(MSVC)
    string(REPLACE "/O2" "/Od" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
    string(REPLACE "/Ob2" "/Ob0" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")

    if(NOT CMAKE_CXX_FLAGS_RELEASE MATCHES "/Zi")
        set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
    endif()

    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /DEBUG")
    set(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /DEBUG")
endif()

set(app_icon_resource_windows "${CMAKE_CURRENT_SOURCE_DIR}/icon.rc")

# ========== cmark-gfm 配置 ==========

set(CMARK_GFM_DIR ${CMAKE_CURRENT_SOURCE_DIR}/cmark_gfm)

# 关键：定义静态库宏，防止 __declspec(dllimport)
add_compile_definitions(CMARK_GFM_STATIC_DEFINE)

# ========== 验证两个库文件都存在 ==========
if(NOT EXISTS ${CMARK_GFM_DIR}/cmark-gfm_static.lib)
    message(FATAL_ERROR "cmark-gfm library not found: ${CMARK_GFM_DIR}/cmark-gfm_static.lib")
endif()

# 新增：验证扩展库存在
if(NOT EXISTS ${CMARK_GFM_DIR}/cmark-gfm-extensions_static.lib)
    message(FATAL_ERROR "cmark-gfm-extensions library not found: ${CMARK_GFM_DIR}/cmark-gfm-extensions_static.lib")
endif()

if(NOT EXISTS ${CMARK_GFM_DIR}/cmark-gfm.h)
    message(FATAL_ERROR "cmark-gfm header not found")
endif()

# ========== 导入 cmark-gfm 核心库 ==========
add_library(cmark-gfm STATIC IMPORTED GLOBAL)
set_target_properties(cmark-gfm PROPERTIES
    IMPORTED_LOCATION "${CMARK_GFM_DIR}/cmark-gfm_static.lib"
    INTERFACE_INCLUDE_DIRECTORIES "${CMARK_GFM_DIR}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "C"
)

# ========== 新增：导入 cmark-gfm-extensions 扩展库 ==========
add_library(cmark-gfm-extensions STATIC IMPORTED GLOBAL)
set_target_properties(cmark-gfm-extensions PROPERTIES
    IMPORTED_LOCATION "${CMARK_GFM_DIR}/cmark-gfm-extensions_static.lib"
    INTERFACE_INCLUDE_DIRECTORIES "${CMARK_GFM_DIR}"
    IMPORTED_LINK_INTERFACE_LANGUAGES "C"
)

qt_add_executable(EasyChat
    main.cpp
    ${app_icon_resource_windows}
)

# 添加 C++ 源文件（不能放在 qt_add_qml_module 中）
target_sources(EasyChat PRIVATE
    handler.h handler.cpp
    ModelConfigManager.h ModelConfigManager.cpp
    ClipboardHelper.h
    views/codeeditor/FileIO.h views/codeeditor/FileIO.cpp
    views/codeeditor/FileTreeModel.h views/codeeditor/FileTreeModel.cpp
    markdownconverter.h markdownconverter.cpp
    openapi/openaiconfig.h openapi/openaiconfig.cpp
    openapi/chatmessage.h openapi/chatmessage.cpp
    openapi/chatsession.h openapi/chatsession.cpp
    openapi/chatmanager.h openapi/chatmanager.cpp
    openapi/promptmanager.h openapi/promptmanager.cpp
    openapi/websearchmanager.h openapi/websearchmanager.cpp
    openapi/toolregistry.h openapi/toolregistry.cpp
    openapi/openaimanager.h openapi/openaimanager.cpp
)

qt_add_qml_module(EasyChat
    URI EasyChat
    VERSION 1.0
    QML_FILES main.qml
    QML_FILES views/HomePage.qml
    QML_FILES views/DetailPage.qml
    QML_FILES views/routes.js
    RESOURCES icon.rc
    QML_FILES QWKButton.qml
    RESOURCES res/shared.qrc
    RESOURCES res/window-bar/close.svg res/window-bar/fullscreen.svg res/window-bar/maximize.svg res/window-bar/minimize.svg res/window-bar/more-line.svg res/window-bar/pin.svg res/window-bar/pin-fill.svg res/window-bar/restore.svg
    QML_FILES views/ChatPage.qml
    RESOURCES res/icons/send_dark.png res/icons/send_light.png res/icons/send_dark.png res/icons/stop_light.png
    QML_FILES views/ChatHistoryDialog.qml
    QML_FILES views/SettingsWindow.qml
    QML_FILES views/ComponentsPage.qml
    QML_FILES views/ComponentPage.qml
    QML_FILES views/ComponentSection.qml
    QML_FILES views/componentPages/EasyButtonPage.qml
    QML_FILES views/componentPages/EasyInputPage.qml
    QML_FILES views/componentPages/EasySelectPage.qml
    QML_FILES views/componentPages/EasySwitchPage.qml
    QML_FILES views/componentPages/EasySliderPage.qml
    QML_FILES views/componentPages/EasyDisplayPage.qml
    QML_FILES views/componentPages/EasyTablePage.qml
    QML_FILES views/componentPages/EasyFeedbackPage.qml
    QML_FILES views/componentPages/EasyNavPage.qml
    QML_FILES views/componentPages/EasyOtherPage.qml
    QML_FILES views/componentPages/EasyMenuBarPage.qml
    QML_FILES views/ThemePage.qml
    QML_FILES views/UserProfileWindow.qml
    QML_FILES views/ThemeSettingsWindow.qml
    QML_FILES views/AboutWindow.qml
    QML_FILES views/codeeditor/CodeEditorPage.qml

    QML_FILES views/components/ComponentDetailPage.qml
    QML_FILES views/components/EasyButtonExample.qml
    QML_FILES views/components/EasyInputExample.qml
    QML_FILES views/components/EasySelectExample.qml
    QML_FILES views/components/EasySwitchExample.qml
    QML_FILES views/components/EasySliderExample.qml
    QML_FILES views/components/EasyDisplayExample.qml
    QML_FILES views/components/EasyTableExample.qml
    QML_FILES views/components/EasyFeedbackExample.qml
    QML_FILES views/components/EasyNavExample.qml
    QML_FILES views/components/EasyOtherExample.qml
    QML_FILES views/components/EasyMenuBarExample.qml
    QML_FILES views/components/EasyTabBarExample.qml
    QML_FILES views/componentPages/EasyTabBarPage.qml
    QML_FILES views/components/EasyIconFontPage.qml
    RESOURCES
        views/components/doc/EasyButton.md
        views/components/doc/EasyInput.md
        views/components/doc/EasySelect.md
        views/components/doc/EasySwitch.md
        views/components/doc/EasySlider.md
        views/components/doc/EasyDisplay.md
        views/components/doc/EasyTable.md
        views/components/doc/EasyFeedback.md
        views/components/doc/EasyNav.md
        views/components/doc/EasyOther.md
        views/components/doc/EasyMenuBar.md
        views/components/doc/EasyTabBar.md
        views/components/doc/EasyCascader.md
        views/components/doc/EasyChart.md

        views/components/doc/EasyImageViewer.md
        views/components/doc/EasyCommandPalette.md
        views/components/doc/EasyWizard.md
        views/components/doc/EasyChipInput.md
        views/components/doc/EasyFileDropZone.md


        views/components/doc/EasyFloatingActionButton.md
        views/components/doc/EasyQRCode.md
        views/components/doc/EasyDropDown.md
        views/components/doc/EasyWatermark.md
        views/components/doc/EasyScrollBar.md

    # ── New app pages ──
    QML_FILES views/PromptLibraryPage.qml
    QML_FILES views/ShortcutsPanel.qml
    QML_FILES views/TokenStatsPanel.qml

    # ── New component detail pages ──
    QML_FILES views/componentPages/EasyCascaderPage.qml
    QML_FILES views/componentPages/EasyChartPage.qml

    QML_FILES views/componentPages/EasyImageViewerPage.qml
    QML_FILES views/componentPages/EasyCommandPalettePage.qml
    QML_FILES views/componentPages/EasyWizardPage.qml
    QML_FILES views/componentPages/EasyChipInputPage.qml
    QML_FILES views/componentPages/EasyFileDropZonePage.qml


    QML_FILES views/componentPages/EasyFloatingActionButtonPage.qml
    QML_FILES views/componentPages/EasyQRCodePage.qml
    QML_FILES views/componentPages/EasyDropDownPage.qml
    QML_FILES views/componentPages/EasyWatermarkPage.qml
    QML_FILES views/componentPages/EasyScrollBarPage.qml
    QML_FILES views/componentPages/EasyColorPickerPage.qml

    # ── New component example files ──
    QML_FILES views/components/EasyCascaderExample.qml
    QML_FILES views/components/EasyChartExample.qml

    QML_FILES views/components/EasyImageViewerExample.qml
    QML_FILES views/components/EasyCommandPaletteExample.qml
    QML_FILES views/components/EasyWizardExample.qml
    QML_FILES views/components/EasyChipInputExample.qml
    QML_FILES views/components/EasyFileDropZoneExample.qml


    QML_FILES views/components/EasyFloatingActionButtonExample.qml
    QML_FILES views/components/EasyQRCodeExample.qml
    QML_FILES views/components/EasyDropDownExample.qml
    QML_FILES views/components/EasyWatermarkExample.qml
    QML_FILES views/components/EasyScrollBarExample.qml
    QML_FILES views/components/EasyColorPickerExample.qml
    RESOURCES res/EasyChat.png
)

# Add EasyUI subdirectory
add_subdirectory(EasyUI)

set_target_properties(EasyChat PROPERTIES
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_include_directories(EasyChat PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/EasyUI
    ${CMAKE_CURRENT_SOURCE_DIR}/openapi
    ${CMARK_GFM_DIR}
)

# ========== 关键修正：同时链接两个库 ==========
target_link_libraries(EasyChat
    PRIVATE
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::Sql
        EasyUI
        cmark-gfm-extensions  # 扩展库（必须在核心库之前或按顺序）
        cmark-gfm             # 核心库
)


include(GNUInstallDirs)
install(TARGETS EasyChat
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR})


add_custom_command(TARGET EasyChat POST_BUILD
    # QML module: qmldir + plugin DLL in EasyUI/ subdir
    COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:EasyChat>/EasyUI"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_FILE_DIR:EasyUI>/qmldir"
        "$<TARGET_FILE_DIR:EasyUI>/EasyUIplugin.dll"
        "$<TARGET_FILE_DIR:EasyChat>/EasyUI/"
    # Main DLLs next to exe
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        $<TARGET_FILE:EasyUI>
        $<TARGET_FILE_DIR:EasyUI>/$<IF:$<CONFIG:Debug>,QWKCored.dll,QWKCore.dll>
        $<TARGET_FILE_DIR:EasyUI>/$<IF:$<CONFIG:Debug>,QWKQuickd.dll,QWKQuick.dll>
        $<TARGET_FILE_DIR:EasyUI>/$<IF:$<CONFIG:Debug>,QWKWidgetsd.dll,QWKWidgets.dll>
        $<TARGET_FILE_DIR:EasyChat>
    COMMENT "Copying EasyUI + QWindowKit DLLs..."
)

# ---- Demo project (optional) ----
option(BUILD_DEMO "Build EasyUI demo project" ON)
if(BUILD_DEMO)
    add_subdirectory(demo)
endif()

