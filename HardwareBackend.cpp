#include "HardwareBackend.h"
#include <QDebug>

HardwareBackend::HardwareBackend(QObject *parent) : QObject(parent)
{
    refreshPorts();
}

void HardwareBackend::refreshPorts()
{
    m_portList.clear();
    const auto infos = QSerialPortInfo::availablePorts();
    for (const QSerialPortInfo &info : infos) {
        m_portList.append(info.portName());
    }
    // 为了模拟器调试，如果没找到串口，加几个假的
    if (m_portList.isEmpty()) {
        m_portList << "ttySAC1" << "ttySAC2" << "COM1" << "COM2";
    }
    emit portsChanged();
}

QStringList HardwareBackend::availablePorts() const { return m_portList; }

QString HardwareBackend::gpsPort() const { return m_gpsPortName; }

void HardwareBackend::setGpsPort(const QString &portName)
{
    if (m_gpsPortName == portName) return;
    m_gpsPortName = portName;
    
    m_gpsSerial.close();
    m_gpsSerial.setPortName(portName);
    m_gpsSerial.setBaudRate(QSerialPort::Baud9600);
    if (m_gpsSerial.open(QIODevice::ReadOnly)) {
        connect(&m_gpsSerial, &QSerialPort::readyRead, this, &HardwareBackend::onGpsReadyRead);
        qDebug() << "GPS Port Opened:" << portName;
    }
    emit gpsPortChanged();
}

QString HardwareBackend::batteryPort() const { return m_batPortName; }

void HardwareBackend::setBatteryPort(const QString &portName)
{
    if (m_batPortName == portName) return;
    m_batPortName = portName;

    m_batSerial.close();
    m_batSerial.setPortName(portName);
    m_batSerial.setBaudRate(QSerialPort::Baud115200); // 假设电池模块波特率
    if (m_batSerial.open(QIODevice::ReadOnly)) {
        connect(&m_batSerial, &QSerialPort::readyRead, this, &HardwareBackend::onBatteryReadyRead);
        qDebug() << "Battery Port Opened:" << portName;
    }
    emit batteryPortChanged();
}

// 简单的 GPS NMEA 解析逻辑 (示例)
void HardwareBackend::onGpsReadyRead()
{
    while (m_gpsSerial.canReadLine()) {
        QByteArray data = m_gpsSerial.readLine();
        // 简单判断: 如果收到 $GPGGA 且包含数据，认为已定位
        if (data.startsWith("$GPGGA")) {
            bool hasFix = !data.contains(",,,"); // 粗略判断
            if (m_gpsFixed != hasFix) {
                m_gpsFixed = hasFix;
                emit gpsStatusChanged();
            }
        }
    }
}

// 简单的电池协议解析: 假设收到 "BAT:85"
void HardwareBackend::onBatteryReadyRead()
{
    while (m_batSerial.canReadLine()) {
        QByteArray line = m_batSerial.readLine().trimmed();
        if (line.startsWith("BAT:")) {
            bool ok;
            int val = line.mid(4).toInt(&ok);
            if (ok) {
                m_batteryLevel = val / 100.0; // 转换成 0.0 - 1.0
                emit batteryLevelChanged();
            }
        }
    }
}