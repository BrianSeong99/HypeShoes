#include <Adafruit_ADS1X15.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define I2C_SDA 17
#define I2C_SCL 21
#define IMU_SDA 26
#define IMU_SCL 18

#define SERVICE_UUID        "74687624-a742-11ed-afa1-0242ac120002"
#define CHARACTERISTIC_UUID "746879ee-a742-11ed-afa1-0242ac120002"

#define MESSAGE_UUID "4ac8a682-9736-4e5d-932b-e9b31405049c"

#define DEVINFO_UUID (uint16_t)0x180a
#define DEVINFO_MANUFACTURER_UUID (uint16_t)0x2a29
#define DEVINFO_NAME_UUID (uint16_t)0x2a24
#define DEVINFO_SERIAL_UUID (uint16_t)0x2a25
#define READING_0_UUID (uint16_t)0x2a26
#define READING_1_UUID (uint16_t)0x2a27
#define READING_2_UUID (uint16_t)0x2a28
#define READING_3_UUID (uint16_t)0x2a29
#define READING_4_UUID (uint16_t)0x2a2a
#define ACCEL_X_UUID (uint16_t)0x2a2b
#define ACCEL_Y_UUID (uint16_t)0x2a2c
#define ACCEL_Z_UUID (uint16_t)0x2a2d
#define GYRO_X_UUID (uint16_t)0x2a2e
#define GYRO_Y_UUID (uint16_t)0x2a2f
#define GYRO_Z_UUID (uint16_t)0x2a30

#define DEVICE_MANUFACTURER "GIX514"
#define DEVICE_NAME "SShoes11"

BLECharacteristic *characteristicMessage;
bool deviceConnected = false;

BLECharacteristic *reading0characteristic;
BLECharacteristic *reading1characteristic;
BLECharacteristic *reading2characteristic;
BLECharacteristic *reading3characteristic;
BLECharacteristic *reading4characteristic;
BLECharacteristic *accelXcharacteristic;
BLECharacteristic *accelYcharacteristic;
BLECharacteristic *accelZcharacteristic;
BLECharacteristic *gyroXcharacteristic;
BLECharacteristic *gyroYcharacteristic;
BLECharacteristic *gyroZcharacteristic;


class MyServerCallbacks : public BLEServerCallbacks {
  void onConnect(BLEServer *server) {
    Serial.println("Connected");
    deviceConnected = true;
  };

  void onDisconnect(BLEServer *server) {
    Serial.println("Disconnected");
    deviceConnected = false;
  }
};

class MessageCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *characteristic) {
    std::string data = characteristic->getValue();
    Serial.println(data.c_str());
  }

  void onRead(BLECharacteristic *characteristic) {
    characteristic->setValue("Foobar");
  }
};


// TwoWire I2CADS = TwoWire(0);
// TwoWire I2CIMU = TwoWire(1);
Adafruit_ADS1115 ads;  /* Use this for the 16-bit version */

const int fsr4Pin = 34;

Adafruit_MPU6050 mpu;

// const uint16_t MPU_ADDR = 0x68; // I2C address of the MPU-6050
// int16_t AcX, AcY, AcZ, Tmp, GyX, GyY, GyZ;

void setup(void)
{
  Serial.begin(115200);
  
  pinMode(fsr4Pin, INPUT);
  Wire.begin(I2C_SDA, I2C_SCL, 1000000);
  if (!ads.begin(0x48, &Wire)) {
    Serial.println("Failed to initialize ADS.");
    while (1);
  }

  if (!mpu.begin(0x68, &Wire)) {
    Serial.println("Sensor init failed");
    while (1)
      yield();
  }
  Serial.println("MPU6050 Found!");

  //setupt motion detection
  mpu.setHighPassFilter(MPU6050_HIGHPASS_0_63_HZ);
  mpu.setMotionDetectionThreshold(1);
  mpu.setMotionDetectionDuration(20);
  mpu.setInterruptPinLatch(true);	// Keep it latched.  Will turn off when reinitialized.
  mpu.setInterruptPinPolarity(true);
  mpu.setMotionInterrupt(true);

  Serial.println("Starting BLE work!");

  // Setup BLE Server
  BLEDevice::init(DEVICE_NAME);
  BLEServer *server = BLEDevice::createServer();
  server->setCallbacks(new MyServerCallbacks());

  // Register message service that can receive messages and reply with a static message.
  BLEService *service = server->createService(SERVICE_UUID);
  characteristicMessage = service->createCharacteristic(MESSAGE_UUID, BLECharacteristic::PROPERTY_READ | BLECharacteristic::PROPERTY_NOTIFY | BLECharacteristic::PROPERTY_WRITE);
  characteristicMessage->setCallbacks(new MessageCallbacks());
  // characteristicMessage->addDescriptor(new BLE2902());
  service->start();

  // Register device info service, that contains the device's UUID, manufacturer and name.
  service = server->createService(DEVINFO_UUID);
  BLECharacteristic *characteristic = service->createCharacteristic(DEVINFO_MANUFACTURER_UUID, BLECharacteristic::PROPERTY_READ);
  characteristic->setValue(DEVICE_MANUFACTURER);
  characteristic = service->createCharacteristic(DEVINFO_NAME_UUID, BLECharacteristic::PROPERTY_READ);
  characteristic->setValue(DEVICE_NAME);
  characteristic = service->createCharacteristic(DEVINFO_SERIAL_UUID, BLECharacteristic::PROPERTY_READ);
  String chipId = String((uint32_t)(ESP.getEfuseMac() >> 24), HEX);
  characteristic->setValue(chipId.c_str());

  reading0characteristic = service->createCharacteristic(READING_0_UUID, BLECharacteristic::PROPERTY_READ);
  reading1characteristic = service->createCharacteristic(READING_1_UUID, BLECharacteristic::PROPERTY_READ);
  reading2characteristic = service->createCharacteristic(READING_2_UUID, BLECharacteristic::PROPERTY_READ);
  reading3characteristic = service->createCharacteristic(READING_3_UUID, BLECharacteristic::PROPERTY_READ);
  reading4characteristic = service->createCharacteristic(READING_4_UUID, BLECharacteristic::PROPERTY_READ);
  accelXcharacteristic = service->createCharacteristic(ACCEL_X_UUID, BLECharacteristic::PROPERTY_READ);
  accelYcharacteristic = service->createCharacteristic(ACCEL_Y_UUID, BLECharacteristic::PROPERTY_READ);
  accelZcharacteristic = service->createCharacteristic(ACCEL_Z_UUID, BLECharacteristic::PROPERTY_READ);
  gyroXcharacteristic = service->createCharacteristic(GYRO_X_UUID, BLECharacteristic::PROPERTY_READ);
  gyroYcharacteristic = service->createCharacteristic(GYRO_Y_UUID, BLECharacteristic::PROPERTY_READ);
  gyroZcharacteristic = service->createCharacteristic(GYRO_Z_UUID, BLECharacteristic::PROPERTY_READ);

  service->start();

  // Advertise services
  BLEAdvertising *advertisement = server->getAdvertising();
  BLEAdvertisementData adv;
  adv.setName(DEVICE_NAME);
  adv.setCompleteServices(BLEUUID(SERVICE_UUID));
  advertisement->setAdvertisementData(adv);
  advertisement->start();
}

void loop(void)
{
  if (deviceConnected) {
    Serial.println("Connected atm\n");
    int16_t adc0, adc1, adc2, adc3;
    float volts0, volts1, volts2, volts3;
    double current_voltage = 3.3;

    adc0 = ads.readADC_SingleEnded(0);
    adc1 = ads.readADC_SingleEnded(1);
    adc2 = ads.readADC_SingleEnded(2);
    adc3 = ads.readADC_SingleEnded(3);

    volts0 = ads.computeVolts(adc0);
    volts1 = ads.computeVolts(adc1);
    volts2 = ads.computeVolts(adc2);
    volts3 = ads.computeVolts(adc3);

    Serial.println("-----------------------------------------------------------");

    double fsr4Read = (double) analogRead(fsr4Pin);
    double fsr4voltage = fsr4Read * current_voltage / 4096;
    Serial.print("voltage: ");Serial.println(fsr4voltage);

    double reading0, reading1, reading2, reading3, reading4;
    reading0 = adc0 * (current_voltage / 32767.0);
    reading1 = adc1 * (current_voltage / 32767.0);
    reading2 = adc2 * (current_voltage / 32767.0);
    reading3 = adc3 * (current_voltage / 32767.0);
    reading4 = fsr4voltage;

    char txStringReading0[8], txStringReading1[8], txStringReading2[8], txStringReading3[8], txStringReading4[8];
    reading0characteristic->setValue(dtostrf(reading0, 5, 4, txStringReading0));
    reading0characteristic->notify();
    Serial.print("0: "); Serial.print(adc0); Serial.print("  "); Serial.print(reading0); Serial.println("V");
    reading1characteristic->setValue(dtostrf(reading1, 5, 4, txStringReading1));
    reading1characteristic->notify();
    Serial.print("1: "); Serial.print(adc1); Serial.print("  "); Serial.print(reading1); Serial.println("V");
    reading2characteristic->setValue(dtostrf(reading2, 5, 4, txStringReading2));
    reading2characteristic->notify();
    Serial.print("2: "); Serial.print(adc2); Serial.print("  "); Serial.print(reading2); Serial.println("V");
    reading3characteristic->setValue(dtostrf(reading3, 5, 4, txStringReading3));
    reading3characteristic->notify();
    Serial.print("3: "); Serial.print(adc3); Serial.print("  "); Serial.print(reading3); Serial.println("V");
    reading4characteristic->setValue(dtostrf(reading4, 5, 4, txStringReading4));
    reading4characteristic->notify();
    Serial.print("4: "); Serial.print(fsr4Read); Serial.print("  "); Serial.print(fsr4voltage); Serial.println("V");

// sensorvalue = analogRead(A0);

    // //in order to send the value we must convert it to characteristic
    // char txString[8];
    // dtostrf(sensorvalue, 1, 2, txString);
    // pCharacteristic->setValue(txString);
    // pCharacteristic->notify();
    // Serial.println("Sent value : " + String(txString));
    
    if(mpu.getMotionInterruptStatus()) {
      /* Get new sensor events with the readings */
      sensors_event_t a, g, temp;
      mpu.getEvent(&a, &g, &temp);

      /* Print out the values */
      Serial.print("AccelX:"); Serial.print(a.acceleration.x); Serial.print(","); 
      Serial.print("AccelY:"); Serial.print(a.acceleration.y); Serial.print(",");
      Serial.print("AccelZ:"); Serial.print(a.acceleration.z); Serial.print(", ");
      Serial.print("GyroX:"); Serial.print(g.gyro.x); Serial.print(",");
      Serial.print("GyroY:"); Serial.print(g.gyro.y); Serial.print(",");
      Serial.print("GyroZ:"); Serial.print(g.gyro.z); Serial.println("");
    }
  }

  delay(1000);
}