#ifndef HARDWAREBACKEND_H
#define HARDWAREBACKEND_H

#include <QObject>
#include <QSerialPort>
#include <QSerialPortInfo>
#include <QStringList>

class HardwareBackend : public QObject
{
    Q_OBJECT
    // 暴露给 QML 的属性
    Q_PROPERTY(QStringList availablePorts READ availablePorts NOTIFY portsChanged)
    Q_PROPERTY(QString gpsPort READ gpsPort WRITE setGpsPort NOTIFY gpsPortChanged)
    Q_PROPERTY(QString batteryPort READ batteryPort WRITE setBatteryPort NOTIFY batteryPortChanged)
    Q_PROPERTY(double batteryLevel READ batteryLevel NOTIFY batteryLevelChanged)
    Q_PROPERTY(bool gpsFixed READ gpsFixed NOTIFY gpsStatusChanged)

public:
    explicit HardwareBackend(QObject *parent = nullptr);

    QStringList availablePorts() const;
    
    QString gpsPort() const;
    void setGpsPort(const QString &portName);

    QString batteryPort() const;
    void setBatteryPort(const QString &portName);

    double batteryLevel() const { return m_batteryLevel; }
    bool gpsFixed() const { return m_gpsFixed; }

public slots:
    void refreshPorts(); // 刷新串口列表

signals:
    void portsChanged();
    void gpsPortChanged();
    void batteryPortChanged();
    void batteryLevelChanged();
    void gpsStatusChanged();

private slots:
    void onGpsReadyRead();
    void onBatteryReadyRead();

private:
    QSerialPort m_gpsSerial;
    QSerialPort m_batSerial;
    QString m_gpsPortName;
    QString m_batPortName;
    QStringList m_portList;
    
    double m_batteryLevel = 0.8; // 默认 80%
    bool m_gpsFixed = false;
};

#endif // HARDWAREBACKEND_H