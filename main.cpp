#include <QQuickView>
#include <QQuickStyle>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#if defined (Q_OS_ANDROID)
#include <QtAndroid>
#endif


int main(int argc, char *argv[])
{
#if QT_VERSION < QT_VERSION_CHECK(6, 0, 0)
    //QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

#if defined (Q_OS_ANDROID)
    // Ask runtime permissions
    const QStringList permissions = {"android.permission.WRITE_EXTERNAL_STORAGE", "android.permission.READ_EXTERNAL_STORAGE", "android.permission.CAMERA"};
    for(auto const &a: permissions){
        auto result = QtAndroid::checkPermission(a);
            if(result == QtAndroid::PermissionResult::Denied){
            auto resultHash = QtAndroid::requestPermissionsSync(QStringList({a}));
        }
    }
#endif

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QQuickStyle::setStyle("Material");
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
         &app, [url](QObject *obj, const QUrl &objUrl) {
    if (!obj && url == objUrl)
        QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);
    return app.exec();
}
