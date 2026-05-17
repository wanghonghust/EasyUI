cmake_minimum_required(VERSION 3.16)
project(EasyUI_Demo VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Qml)

# ---- EasyUI: auto-detect in-tree vs installed ----
if(TARGET EasyUI)
    # Already built as subdirectory of EasyChat — nothing to do
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../EasyUI/CMakeLists.txt")
    # Standalone build next to EasyChat source
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/../EasyUI ${CMAKE_BINARY_DIR}/EasyUI)
else()
    find_package(EasyUI REQUIRED)
endif()

qt_add_executable(EasyUI_Demo main.cpp)

qt_add_qml_module(EasyUI_Demo
    URI Demo
    VERSION 1.0
    QML_FILES main.qml
)

target_link_libraries(EasyUI_Demo PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Qml
    EasyUI
)

# ---- Copy DLLs + QML module to output directory (Windows) ----
if(WIN32)
    # EasyUI QML module output dir (qmldir + qmltypes) — set by QT_QML_OUTPUT_DIRECTORY
    set(_EASYUI_QML_MODULE "${CMAKE_BINARY_DIR}/EasyUI")

    add_custom_command(TARGET EasyUI_Demo POST_BUILD
        # EasyUI module subdir: qmldir + plugin DLL
        COMMAND ${CMAKE_COMMAND} -E make_directory "$<TARGET_FILE_DIR:EasyUI_Demo>/EasyUI"
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${_EASYUI_QML_MODULE}/qmldir"
            "$<TARGET_FILE_DIR:EasyUI>/EasyUIplugin.dll"
            "$<TARGET_FILE_DIR:EasyUI_Demo>/EasyUI/"
        # Main DLLs next to exe
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:EasyUI>"
            "$<TARGET_FILE_DIR:EasyUI>/QWKCore.dll"
            "$<TARGET_FILE_DIR:EasyUI>/QWKQuick.dll"
            "$<TARGET_FILE_DIR:EasyUI>/QWKWidgets.dll"
            "$<TARGET_FILE_DIR:EasyUI_Demo>"
        COMMENT "Copying EasyUI DLLs + module..."
    )
endif()
