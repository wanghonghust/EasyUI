cmake_minimum_required(VERSION 3.16)

project(EasyUI VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(QT_QML_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# ── QWindowKit ──
set(QWindowKit_BASE "${CMAKE_CURRENT_SOURCE_DIR}/third_party/qwindowkit")
set(QWindowKit_DIR_DEBUG "${QWindowKit_BASE}/debug/lib/cmake/QWindowKit")
set(QWindowKit_DIR_RELEASE "${QWindowKit_BASE}/release/lib/cmake/QWindowKit")

if(CMAKE_CONFIGURATION_TYPES)
    set(QWindowKit_DIR "${QWindowKit_DIR_RELEASE}")
elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(QWindowKit_DIR "${QWindowKit_DIR_DEBUG}")
else()
    set(QWindowKit_DIR "${QWindowKit_DIR_RELEASE}")
endif()

find_package(QWindowKit COMPONENTS Core Widgets Quick REQUIRED)
find_package(Qt6 6.2 COMPONENTS Quick Qml Network REQUIRED)

# ── Library ──
qt_add_library(EasyUI SHARED)

target_sources(EasyUI PRIVATE
    # Core
    src/EasyUI.h      src/EasyUI.cpp
    src/WindowHelper.h src/WindowHelper.cpp
    src/DynamicTableModel.h src/DynamicTableModel.cpp
    src/ToastManager.h     src/ToastManager.cpp

    # Markdown C++ backend
    src/markdown/CodeHighlighter.h     src/markdown/CodeHighlighter.cpp
    src/markdown/MarkdownDocument.h    src/markdown/MarkdownDocument.cpp
    src/markdown/MarkdownParser.h      src/markdown/MarkdownParser.cpp
    src/markdown/MarkdownSelectionHandler.h src/markdown/MarkdownSelectionHandler.cpp
    src/markdown/MarkdownStyle.h       src/markdown/MarkdownStyle.cpp
)

qt_add_qml_module(EasyUI
    URI EasyUI
    VERSION 1.0
    RESOURCES qmldir

    # ── Basic Controls ──
    QML_FILES
        qml/basic/EasyButton.qml
        qml/basic/EasyButtonGroup.qml

        qml/basic/EasyCheckbox.qml
        qml/basic/EasyCascader.qml
        qml/basic/EasyChipInput.qml
        qml/basic/EasyDropDown.qml
        qml/basic/EasyColorPicker.qml
        qml/basic/EasyDatePicker.qml
        qml/basic/EasyIcon.qml
        qml/basic/EasyIconFont.qml
        qml/basic/EasyInput.qml
        qml/basic/EasyIPInput.qml
        qml/basic/EasyMACInput.qml
        qml/basic/EasyNumberInput.qml
        qml/basic/EasyProgress.qml
        qml/basic/EasyRadio.qml
        qml/basic/EasyRadioGroup.qml
        qml/basic/EasySearchInput.qml
        qml/basic/EasySelect.qml
        qml/basic/EasySlider.qml
        qml/basic/EasySwitch.qml
        qml/basic/EasyTag.qml
        qml/basic/EasyTextArea.qml

    # ── Navigation ──
    QML_FILES
        qml/navigation/EasyBreadcrumb.qml
        qml/navigation/EasyCommandPalette.qml
        qml/navigation/EasyMenuBar.qml
        qml/navigation/EasyMenuButton.qml
        qml/navigation/EasyPagination.qml
        qml/navigation/EasySegmented.qml
        qml/navigation/EasyTabBar.qml
        qml/navigation/EasyTreeView.qml
        qml/navigation/EasyWizard.qml
        qml/navigation/EasyContextMenu.qml

    # ── Feedback ──
    QML_FILES
        qml/feedback/EasyAlert.qml
        qml/feedback/EasyBadge.qml
        qml/feedback/EasyDialog.qml
        qml/feedback/EasyDrawer.qml
        qml/feedback/EasyLoading.qml

        qml/feedback/EasyTooltip.qml
        qml/feedback/EasyToast.qml

    # ── Display ──
    QML_FILES
        qml/display/EasyAvatar.qml
        qml/display/EasyCard.qml
        qml/display/EasyCarousel.qml
        qml/display/EasyChart.qml
        qml/display/EasyCollapse.qml
        qml/display/EasyDivider.qml
        qml/display/EasyFileDropZone.qml
        qml/display/EasyGaussianBlur.qml
        qml/display/EasyFloatingActionButton.qml
        qml/display/EasyImageViewer.qml
        qml/display/EasyLyric.qml
        qml/display/EasyQRCode.qml
        qml/display/EasyRate.qml
        qml/display/EasyShadow.qml
        qml/display/EasySplitPane.qml

        qml/display/EasyTable.qml
        qml/display/EasyToggle.qml
        qml/display/EasyTimeline.qml
        qml/display/EasyEmpty.qml
        qml/display/EasySkeleton.qml
        qml/display/EasyScrollBar.qml
        qml/display/EasyWatermark.qml

    # ── Window ──
    QML_FILES
        qml/window/EasyFramelessWindow.qml
        qml/window/EasySigletonWindow.qml
        qml/window/EasySimpleWindow.qml
        qml/window/EasyIconButton.qml

    # ── Theme ──
    QML_FILES
        qml/theme/GlobalMask.qml
        qml/theme/EasyTheme.qml
        qml/theme/ThemeSettings.qml

    # ── Transfer ──
    QML_FILES
        qml/transfer/EasyTransfer.qml
        qml/transfer/TransferButton.qml
        qml/transfer/TransferButtons.qml
        qml/transfer/TransferDelegate.qml
        qml/transfer/TransferPanel.qml

    # ── Markdown View ──
    QML_FILES
        qml/markdownview/MarkdownBlock.qml
        qml/markdownview/MarkdownCodeBlock.qml
        qml/markdownview/MarkdownHeading.qml
        qml/markdownview/MarkdownHtmlBlock.qml
        qml/markdownview/MarkdownImage.qml
        qml/markdownview/MarkdownInlineText.qml
        qml/markdownview/MarkdownListItem.qml
        qml/markdownview/MarkdownTable.qml
        qml/markdownview/MarkdownView.qml

    # ── Standalone Helpers ──
    QML_FILES
        qml/StarItem.qml
        qml/TimePicker.qml

    # ── Icon Resources (dark) ──
    RESOURCES
        res/icons/dark/arrow-down.png
        res/icons/dark/arrow-up.png
        res/icons/dark/close.png
        res/icons/dark/dark.png
        res/icons/dark/light.png
        res/icons/dark/maximize.png
        res/icons/dark/maximize1.png
        res/icons/dark/minimize.png
        res/icons/dark/settings.png

    # ── Icon Resources (light) ──
    RESOURCES
        res/icons/light/arrow-down.png
        res/icons/light/arrow-up.png
        res/icons/light/close.png
        res/icons/light/dark.png
        res/icons/light/light.png
        res/icons/light/maximize.png
        res/icons/light/maximize1.png
        res/icons/light/minimize.png
        res/icons/light/more.png
        res/icons/light/settings.png

    # ── Icon Resources (common) ──
    RESOURCES
        res/icons/common/chat.png
        res/icons/common/comdown.png
        res/icons/common/email.png
        res/icons/common/flag.png
        res/icons/common/home.png
        res/icons/common/lock.png
        res/icons/common/notification.png
        res/icons/common/paste.png
        res/icons/common/position.png
        res/icons/common/power.png
        res/icons/common/previous.png
        res/icons/common/print.png
        res/icons/common/refresh.png
        res/icons/common/reply.png
        res/icons/common/scale.png
        res/icons/common/storage.png
        res/icons/common/team.png
        res/icons/common/trash.png
        res/icons/common/trash_email.png
        res/icons/common/user_center.png
        res/icons/common/user_center1.png

    # ── Shaders ──
    RESOURCES
        shaders/blur.vert.qsb
        shaders/blur_h.frag.qsb
        shaders/blur_v.frag.qsb

    # ── Fonts ──
    RESOURCES
        res/fonts/MaterialSymbolsOutlined.ttf
)

target_compile_definitions(EasyUI
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
    PUBLIC EASYUI_LIBRARY
)

target_link_libraries(EasyUI
    PRIVATE
        Qt6::Quick
        Qt6::Qml
        Qt6::Network
        QWindowKit::Core
        QWindowKit::Quick
)

target_include_directories(EasyUI PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

target_include_directories(EasyUI PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/markdown
)

set_target_properties(EasyUI PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER my.example.com
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
)

# ── Ensure source qmldir (with prefer directive) overrides auto-generated ──
add_custom_command(TARGET EasyUI POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "${CMAKE_CURRENT_SOURCE_DIR}/qmldir"
        "${CMAKE_BINARY_DIR}/EasyUI/"
    COMMENT "qmldir: source (prefer+singleton) over auto-generated..."
)

# ── Copy QWindowKit DLLs ──
if(WIN32)
    add_custom_command(TARGET EasyUI POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<IF:$<CONFIG:Debug>,${QWindowKit_BASE}/debug/bin/QWKCored.dll,${QWindowKit_BASE}/release/bin/QWKCore.dll>"
            "$<TARGET_FILE_DIR:EasyUI>/$<IF:$<CONFIG:Debug>,QWKCored.dll,QWKCore.dll>"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<IF:$<CONFIG:Debug>,${QWindowKit_BASE}/debug/bin/QWKQuickd.dll,${QWindowKit_BASE}/release/bin/QWKQuick.dll>"
            "$<TARGET_FILE_DIR:EasyUI>/$<IF:$<CONFIG:Debug>,QWKQuickd.dll,QWKQuick.dll>"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<IF:$<CONFIG:Debug>,${QWindowKit_BASE}/debug/bin/QWKWidgetsd.dll,${QWindowKit_BASE}/release/bin/QWKWidgets.dll>"
            "$<TARGET_FILE_DIR:EasyUI>/$<IF:$<CONFIG:Debug>,QWKWidgetsd.dll,QWKWidgets.dll>"
        COMMENT "Copying QWindowKit DLLs ($<CONFIG> configuration)"
    )
endif()
