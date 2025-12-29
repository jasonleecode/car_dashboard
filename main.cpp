#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QUrl>
#include <QString>
#include "HardwareBackend.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // 实例化后端逻辑
    HardwareBackend hardwareBackend;

    QQmlApplicationEngine engine;
    
    // 将 C++ 对象注入到 QML 上下文中，名字叫 "Backend"
    engine.rootContext()->setContextProperty("Backend", &hardwareBackend);

    const QUrl url(QStringLiteral("qrc:/Main/Main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}