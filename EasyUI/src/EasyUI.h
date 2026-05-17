#ifndef EASYUI_H
#define EASYUI_H

#ifdef _WIN32
    #ifdef EASYUI_STATIC
        #define EASYUI_EXPORT
    #elif EASYUI_LIBRARY
        #define EASYUI_EXPORT __declspec(dllexport)
    #else
        #define EASYUI_EXPORT __declspec(dllimport)
    #endif
#else
    #define EASYUI_EXPORT
#endif

class QQmlApplicationEngine;

class EASYUI_EXPORT EasyUI {
public:
    /**
     * @brief Initialize EasyUI library and register QWindowKit types
     * @param engine The QML application engine to register types with
     */
    static void initialize(QQmlApplicationEngine *engine);
};

#endif // EASYUI_H
