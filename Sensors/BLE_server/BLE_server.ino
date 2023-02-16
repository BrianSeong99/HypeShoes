/*
    Based on Neil Kolban example for IDF: https://github.com/nkolban/esp32-snippets/blob/master/cpp_utils/tests/BLE%20Tests/SampleServer.cpp
    Ported to Arduino ESP32 by Evandro Copercini
    updates by chegewara
*/

#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

// See the following for generating UUIDs:
// https://www.uuidgenerator.net/

#define SERVICE_UUID        "74687624-a742-11ed-afa1-0242ac120002"
#define CHARACTERISTIC_UUID "746879ee-a742-11ed-afa1-0242ac120002"

#define MESSAGE_UUID "4ac8a682-9736-4e5d-932b-e9b31405049c"

#define DEVINFO_UUID (uint16_t)0x180a
#define DEVINFO_MANUFACTURER_UUID (uint16_t)0x2a29
#define DEVINFO_NAME_UUID (uint16_t)0x2a24
#define DEVINFO_SERIAL_UUID (uint16_t)0x2a25

#define DEVICE_MANUFACTURER "Foobar"
#define DEVICE_NAME "SShoes11"

BLECharacteristic *characteristicMessage;
bool deviceConnected = false;


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

void setup() {
  Serial.begin(115200);
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
  service->start();

  // Advertise services
  BLEAdvertising *advertisement = server->getAdvertising();
  BLEAdvertisementData adv;
  adv.setName(DEVICE_NAME);
  adv.setCompleteServices(BLEUUID(SERVICE_UUID));
  advertisement->setAdvertisementData(adv);
  advertisement->start();

  Serial.println("Ready");
}

void loop() {
  // put your main code here, to run repeatedly:
  if (deviceConnected) {
    sensorvalue = analogRead(A0);

    //in order to send the value we must convert it to characteristic
    char txString[8];
    dtostrf(sensorvalue, 1, 2, txString);
    pCharacteristic->setValue(txString);
    pCharacteristic->notify();
    Serial.println("Sent value : " + String(txString));
  }
  delay(2000);
}