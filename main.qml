import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts
import Qt.labs.platform 1.1
import EasyUI

import ModelConfig 1.0
import Chat 1.0
import "views/routes.js" as Router

EasyFramelessWindow {
    id: window
    title: "AI助手"
    property var vendors: []
    width: 1200
    height: 600

    // 监听当前会话变化，更新窗口标题
    property var chatManager: ChatManager
    property var currentSession: chatManager.currentSession

    onCurrentSessionChanged: {
        if (currentSession && currentSession.title) {
            window.title = currentSession.title + " - AI助手"
        } else {
            window.title = "AI助手"
        }
    }
    titleBarActions: [
        EasyDropDown {
            id: moreDrop
            model: [{
                    "text": "主题设置",
                    "icon": EasyIcon.material.palette,
                    "onClick": () => {
                        if (themeSettingsLoader.status === Loader.Ready)
                            themeSettingsLoader.item.show(window)
                        else if (themeSettingsLoader.status !== Loader.Loading)
                            themeSettingsLoader.active = true
                    }
                }, {
                    "text": "关于",
                    "icon": EasyIcon.material.info,
                    "onClick": () => {
                        if (aboutLoader.status === Loader.Ready)
                            aboutLoader.item.showWindow(window)
                        else if (aboutLoader.status !== Loader.Loading)
                            aboutLoader.active = true
                    }
                }]
            popupWidth: 120

            EasyIconButton {
                icon: EasyIcon.material.more_vert
                btnRadius: 0
                hoverColor: EasyTheme.color.miniMaxBtnHover
            }
        }
    ]

    EasyToast {
        id: appToast
    }

    // ===== 命令面板（Popup 非 Item，需动态创建）=====
    property var commandPalette: null
    function _initCommandPalette() {
        var comp = Qt.createComponent(
                    "EasyUI/qml/navigation/EasyCommandPalette.qml")
        if (comp.status === Component.Ready) {
            commandPalette = comp.createObject(window)
            commandPalette.commands = [{
                                           "id": "home",
                                           "title": "回到首页",
                                           "category": "导航",
                                           "keywords": "home 首页",
                                           "icon": EasyIcon.material.home,
                                           "shortcut": "Ctrl+H"
                                       }, {
                                           "id": "chat",
                                           "title": "打开 AI 助手",
                                           "category": "导航",
                                           "keywords": "chat 对话 AI",
                                           "icon": EasyIcon.material.smart_toy,
                                           "shortcut": "Ctrl+1"
                                       }, {
                                           "id": "theme",
                                           "title": "打开主题设置",
                                           "category": "导航",
                                           "keywords": "theme 主题 设置",
                                           "icon": EasyIcon.material.palette,
                                           "shortcut": "Ctrl+Shift+T"
                                       }, {
                                           "id": "shortcuts",
                                           "title": "打开快捷键面板",
                                           "category": "导航",
                                           "keywords": "shortcuts 快捷键",
                                           "icon": EasyIcon.material.keyboard
                                       }, {
                                           "id": "components",
                                           "title": "打开组件库",
                                           "category": "导航",
                                           "keywords": "components 组件 库",
                                           "icon": EasyIcon.material.widgets,
                                           "shortcut": "Ctrl+2"
                                       }, {
                                           "id": "toggle_theme",
                                           "title": "切换深色/浅色模式",
                                           "category": "设置",
                                           "keywords": "dark light theme 深色 浅色 主题 切换",
                                           "icon": EasyIcon.material.dark_mode,
                                           "shortcut": "Ctrl+Shift+D"
                                       }]
            commandPalette.commandSelected.connect(function (id, data) {
                if (id === "toggle_theme") {
                    ThemeSettings.setDarkMode(!EasyTheme.isDark)
                } else if (id === "theme") {
                    if (themeSettingsLoader.status === Loader.Ready)
                        themeSettingsLoader.item.show(window)
                    else if (themeSettingsLoader.status !== Loader.Loading)
                        themeSettingsLoader.active = true
                } else {
                    window.activePath = id
                    updateWindowTitle(id)
                }
            })
        }
    }

    property var sideMenus: [{
            "title": "首页",
            "icon": EasyIcon.material.home,
            "url"// home
            : "home",
            "children": []
        }, {
            "title": "AI助手",
            "icon": EasyIcon.material.chat,
            "url"// chat
            : "chat",
            "children": []
        }, {
            "title": "组件库",
            "icon": EasyIcon.material.widgets,
            "children": [{
                    "title": "基础 Basic",
                    "icon": EasyIcon.material.check_box_outline_blank,
                    "children": [
                        {"title": "按钮 Button", "icon": EasyIcon.material.buttons_alt, "url": "component_button"},
                        {"title": "输入框 Input", "icon": EasyIcon.material.text_fields, "url": "component_input"},
                        {"title": "选择器 Select", "icon": EasyIcon.material.arrow_drop_down, "url": "component_select"},
                        {"title": "下拉菜单 DropDown", "icon": EasyIcon.material.arrow_drop_down_circle, "url": "component_dropdown"},
                        {"title": "级联选择 Cascader", "icon": EasyIcon.material.account_tree, "url": "component_cascader"},
                        {"title": "开关/复选/单选 Switch", "icon": EasyIcon.material.toggle_on, "url": "component_switch"},
                        {"title": "滑块/评分/分段 Slider", "icon": EasyIcon.material.tune, "url": "component_slider"},
                        {"title": "标签/徽标 Tag", "icon": EasyIcon.material.label, "url": "component_display"},
                        {"title": "颜色选择 ColorPicker", "icon": EasyIcon.material.palette, "url": "component_colorpicker"},
                        {"title": "标签输入 ChipInput", "icon": EasyIcon.material.label, "url": "component_chipinput"}
                    ]
                }, {
                    "title": "展示 Display",
                    "icon": EasyIcon.material.grid_view,
                    "children": [
                        {"title": "表格/分页/穿梭框 Table", "icon": EasyIcon.material.backup_table, "url": "component_table"},
                        {"title": "卡片/分割/折叠 Card", "icon": EasyIcon.material.dashboard, "url": "component_other"},
                        {"title": "图表 Chart", "icon": EasyIcon.material.monitoring, "url": "component_chart"},
                        {"title": "图片查看 ImageViewer", "icon": EasyIcon.material.image, "url": "component_imageviewer"},
                        {"title": "二维码 QRCode", "icon": EasyIcon.material.qr_code, "url": "component_qrcode"},
                        {"title": "水印 Watermark", "icon": EasyIcon.material.ink_marker, "url": "component_watermark"},
                        {"title": "悬浮按钮 FAB", "icon": EasyIcon.material.add_circle, "url": "component_fab"},
                        {"title": "文件拖放 FileDrop", "icon": EasyIcon.material.upload_file, "url": "component_filedropzone"},
                        {"title": "滚动条 ScrollBar", "icon": EasyIcon.material.swap_vert, "url": "component_scrollbar"}
                    ]
                }, {
                    "title": "反馈 Feedback",
                    "icon": EasyIcon.material.feedback,
                    "children": [
                        {"title": "弹窗 Dialog", "icon": EasyIcon.material.chrome_reader_mode, "url": "component_feedback"},
                        {"title": "菜单栏 MenuBar", "icon": EasyIcon.material.menu, "url": "component_menubar"}
                    ]
                }, {
                    "title": "导航 Navigation",
                    "icon": EasyIcon.material.explore,
                    "children": [
                        {"title": "标签页/面包屑/向导 Nav", "icon": EasyIcon.material.tab, "url": "component_nav"},
                        {"title": "命令面板 CommandPalette", "icon": EasyIcon.material.keyboard, "url": "component_commandpalette"}
                    ]
                }, {
                    "title": "其他 Other",
                    "icon": EasyIcon.material.more_horiz,
                    "children": [
                        {"title": "图标库 IconFont", "icon": EasyIcon.material.font_download, "url": "component_iconfont"}
                    ]
                }]
        }, {
            "title": "代码编辑器",
            "icon": EasyIcon.material.code,
            "url"// code
            : "codeeditor",
            "children": []
        }, {
            "title": "提示词库",
            "icon": EasyIcon.material.bookmark_manager,
            "url"// bookmark_manager
            : "prompts",
            "children": []
        }, {
            "title": "Token统计",
            "icon": EasyIcon.material.bar_chart,
            "url"// bar_chart
            : "stats",
            "children": []
        }, {
            "title": "快捷键",
            "icon": EasyIcon.material.keyboard,
            "url"// keyboard
            : "shortcuts",
            "children": []
        }]

    property string activePath: "home"
    property string pendingComponentKey: ""
    property int pendingPromptId: -1

    // 用户详情窗口 Loader
    Loader {
        id: userProfileLoader
        source: "views/UserProfileWindow.qml"
        active: false
        onLoaded: {
            item.showWindow(window)
        }
    }

    // 主题设置窗口 Loader
    Loader {
        id: themeSettingsLoader
        source: "views/ThemeSettingsWindow.qml"
        active: false
        onLoaded: {
            item.show(window)
        }
    }

    // 关于窗口 Loader
    Loader {
        id: aboutLoader
        source: "views/AboutWindow.qml"
        active: false
        onLoaded: {
            item.showWindow(window)
        }
    }

    // 页面标题映射
    property var pageTitles: ({
                                  "home": "首页",
                                  "chat": "AI助手",
                                  "components": "组件库",
                                  "component_button": "按钮",
                                  "component_input": "输入框",
                                  "component_select": "选择器",
                                  "component_switch": "开关与复选",
                                  "component_slider": "滑块与评分",
                                  "component_display": "数据展示",
                                  "component_table": "表格与分页",
                                  "component_feedback": "反馈与弹窗",
                                  "component_nav": "导航",
                                  "component_other": "其他",
                                  "component_menubar": "菜单栏",
                                  "component_tabbar": "标签页",
                                  "user_profile": "用户详情",
                                  "prompts": "提示词库",
                                  "stats": "Token 统计",
                                  "shortcuts": "快捷键",
                                  "component_cascader": "级联选择",
                                  "component_chart": "图表",
                                  "component_imageviewer": "图片查看器",
                                  "component_commandpalette": "命令面板",
                                  "component_wizard": "向导",
                                  "component_chipinput": "标签输入",
                                  "component_filedropzone": "文件拖放",
                                  "component_fab": "悬浮按钮",
                                  "component_qrcode": "二维码",
                                  "component_watermark": "水印",
                                  "component_dropdown": "下拉菜单",
        "component_scrollbar": "滚动条",
        "component_colorpicker": "颜色选择器"
                              })

    // 更新窗口标题
    function updateWindowTitle(path) {
        var title = pageTitles[path] || "AI助手"
        window.title = title
    }

    function loadData() {
        vendors = ConfigManager.listVendorsQml()
        console.log("Vendors count:", vendors.length)
    }

    Component.onCompleted: {
        leftSideExpanded = true
        var dbPath = Qt.applicationDirPath + "/config.db"
        var success = ConfigManager.initialize(dbPath, "my_secret")
        console.log("ConfigManager initialize:", success)
        var promptOk = PromptManager.initialize(dbPath)
        console.log("PromptManager initialize:", promptOk)
        if (success) {
            loadData()
        }
        _initCommandPalette()
    }

    leftContent: Rectangle {
        anchors.fill: parent
        color: "transparent"

        // 用户头像区域
        Rectangle {
            id: userAvatarArea
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            color: "transparent"

            property bool collapsed: !window.leftSideExpanded
            property string userName: "张三"
            height: collapsed ? 60 : 80

            // 圆形文字头像
            Rectangle {
                id: avatarRect
                anchors.top: parent.top
                anchors.topMargin: userAvatarArea.collapsed ? 12 : 16
                anchors.horizontalCenter: parent.horizontalCenter
                width: userAvatarArea.collapsed ? 36 : 48
                height: width
                radius: width / 2
                color: EasyTheme.color.primary

                Behavior on width {
                    NumberAnimation {
                        duration: 200
                    }
                }

                // 文字（名字首字）
                Text {
                    anchors.centerIn: parent
                    text: userAvatarArea.userName.length > 0 ? userAvatarArea.userName.charAt(
                                                                   0) : "?"
                    font.pixelSize: parent.width * 0.5
                    font.bold: true
                    color: "white"
                }
            }

            // 用户名（展开时显示）
            Label {
                visible: !userAvatarArea.collapsed
                anchors.top: avatarRect.bottom
                anchors.topMargin: 8
                anchors.horizontalCenter: parent.horizontalCenter
                text: userAvatarArea.userName
                font.pixelSize: 13
                font.bold: true
                color: EasyTheme.color.text
            }

            // 点击区域
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (userProfileLoader.status === Loader.Ready) {
                        userProfileLoader.item.showWindow(window)
                    } else if (userProfileLoader.status !== Loader.Loading) {
                        userProfileLoader.active = true
                    }
                }
            }
        }

        // 菜单栏
        EasyMenuBar {
            id: sideMenu
            anchors.top: userAvatarArea.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            menus: window.sideMenus
            activePath: window.activePath
            collapsed: !window.leftSideExpanded
            onItemClicked: item => {
                               if (item.children && item.children.length > 0)
                               return
                               if (item.url in Router.routes) {
                                   contentArea.pushUrlTo(item.url, {
                                                             "navigator": contentArea
                                                         })
                               }
                           }
        }
    }

    ColumnLayout {
        anchors.fill: parent

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: contentArea
                Layout.fillHeight: true
                Layout.fillWidth: true
                color: EasyTheme.color.background

                // 页面切换过渡层（点击导航后立即显示，遮盖加载卡顿）
                Rectangle {
                    id: transitionOverlay
                    anchors.fill: parent
                    color: EasyTheme.color.background
                    opacity: 0
                    visible: opacity > 0
                    z: pageContainer.z + 2

                    EasyLoading {
                        anchors.centerIn: parent
                        text: "加载中..."
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 80
                        }
                    }

                    function show() {
                        opacity = 1
                    }
                    function hide() {
                        opacity = 0
                    }
                }

                // 页面容器（懒加载 + LRU缓存限制，保持页面状态）
                Item {
                    id: pageContainer
                    anchors.fill: parent

                    property var pageCache: ({})
                    property var pageOrder: [] // LRU ordered keys
                    property var currentPage: null
                    property string currentPath: ""
                    property int maxCachedPages: 5

                    function evictCache() {
                        while (pageOrder.length > maxCachedPages) {
                            var oldest = pageOrder.shift()
                            var oldPage = pageCache[oldest]
                            if (oldPage && oldPage !== currentPage) {
                                oldPage.destroy()
                                delete pageCache[oldest]
                            }
                        }
                    }

                    function switchTo(path) {
                        if (!path)
                            return
                        if (path === currentPath && currentPage) {
                            transitionOverlay.hide()
                            return
                        }

                        // 隐藏当前页面：opacity=0 保持场景图完整，避免切回时重建卡顿
                        if (currentPage) {
                            currentPage.opacity = 0
                            currentPage.enabled = false
                            if (currentPage.hasOwnProperty("pageActive"))
                                currentPage.pageActive = false
                        }

                        // 从缓存获取或懒加载创建
                        var page = pageCache[path]
                        if (page) {
                            // Move to end of LRU
                            var idx = pageOrder.indexOf(path)
                            if (idx >= 0)
                                pageOrder.splice(idx, 1)
                            pageOrder.push(path)
                            finishSwitch(page, path)
                            return
                        }

                        var source = Router.routes[path]
                        if (!source) {
                            console.warn("PageContainer: no route for path:",
                                         path)
                            transitionOverlay.hide()
                            return
                        }

                        var component = Qt.createComponent(source)
                        if (component.status === Component.Ready) {
                            page = component.createObject(pageContainer, {
                                                              "anchors.fill": pageContainer,
                                                              "visible": false
                                                          })
                            pageCache[path] = page
                            pageOrder.push(path)
                            evictCache()
                            finishSwitch(page, path)
                        } else if (component.status === Component.Loading) {
                            component.statusChanged.connect(function onReady() {
                                if (component.status === Component.Ready) {
                                    component.statusChanged.disconnect(onReady)
                                    var p = component.createObject(
                                                pageContainer, {
                                                    "anchors.fill": pageContainer,
                                                    "visible": false
                                                })
                                    pageCache[path] = p
                                    pageOrder.push(path)
                                    evictCache()
                                    finishSwitch(p, path)
                                } else if (component.status === Component.Error) {
                                    component.statusChanged.disconnect(onReady)
                                    console.warn(
                                                "PageContainer: failed to load:",
                                                source, component.errorString())
                                    transitionOverlay.hide()
                                }
                            })
                        } else {
                            console.warn("PageContainer: error loading:",
                                         source, component.errorString())
                            transitionOverlay.hide()
                        }
                    }

                    function finishSwitch(page, path) {
                        if (page.hasOwnProperty("navigator"))
                            page.navigator = contentArea
                        if (window.pendingComponentKey && page.hasOwnProperty(
                                    "componentKey")) {
                            page.componentKey = window.pendingComponentKey
                            window.pendingComponentKey = ""
                        }
                        page.visible = true
                        page.opacity = 0
                        page.enabled = true
                        if (page.hasOwnProperty("pageActive"))
                            page.pageActive = true
                        currentPage = page
                        currentPath = path
                        fadeInAnim.target = page
                        fadeInAnim.start()
                        Qt.callLater(function () {
                            transitionOverlay.hide()
                        })
                    }

                    Connections {
                        target: window
                        function onActivePathChanged() {
                            pageContainer.switchTo(window.activePath)
                        }
                    }

                    NumberAnimation {
                        id: fadeInAnim
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 100
                    }

                    // 首次加载
                    Component.onCompleted: {
                        switchTo(window.activePath)
                    }
                }

                function pushUrlTo(path, params) {
                    if (path in Router.routes) {
                        if (path !== pageContainer.currentPath)
                            transitionOverlay.show()
                        window.activePath = path
                        updateWindowTitle(path)
                    }
                }

                function popUrl(transition) {
                    transitionOverlay.show()
                    window.activePath = "home"
                    updateWindowTitle("home")
                }

                function goTo(path) {
                    if (path in Router.routes) {
                        if (path !== pageContainer.currentPath)
                            transitionOverlay.show()
                        window.activePath = path
                        updateWindowTitle(path)
                    }
                }
            }
        }
    }
}
