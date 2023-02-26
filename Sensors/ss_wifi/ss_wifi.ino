#include <Adafruit_ADS1X15.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

#include <WiFi.h>
#include <HTTPClient.h>
#include <AsyncTCP.h>
#include <ESPAsyncWebSrv.h>

#define I2C_SDA 17
#define I2C_SCL 21
#define IMU_SDA 26
#define IMU_SCL 18

// const char* fmtMemCk = "Free: %d\tMaxAlloc: %d\t PSFree: %d\n";
// #define MEMCK Serial.printf(fmtMemCk,ESP.getFreeHeap(),ESP.getMaxAllocHeap(),ESP.getFreePsram())

const char *ssid = "HJHJHJ";
const char *password = "HJ1211HJ1211";

// Set web server port number to 80
AsyncWebServer server(80);

String server_url = "http://10.0.0.92:5001"; // Location to send POSTed data

Adafruit_ADS1115 ads;  /* Use this for the 16-bit version */
Adafruit_MPU6050 mpu;

const int fsr4Pin = 34;

unsigned long startMillis;  //some global variables available anywhere in the program
unsigned long lastMillis;
unsigned long timerDelay;

bool isUpload = false;

const unsigned long deviceID = 10000001;

void setupADS() {
  if (!ads.begin(0x48, &Wire)) {
    Serial.println("Failed to initialize ADS.");
    while (1);
  }
}

void setupMPU() {
  if (!mpu.begin(0x68, &Wire)) {
    Serial.println("Sensor init failed");
    while (1)
      yield();
  }
  //setupt motion detection
  mpu.setHighPassFilter(MPU6050_HIGHPASS_0_63_HZ);
  mpu.setMotionDetectionThreshold(1);
  mpu.setMotionDetectionDuration(20);
  mpu.setInterruptPinLatch(true);	// Keep it latched.  Will turn off when reinitialized.
  mpu.setInterruptPinPolarity(true);
  mpu.setMotionInterrupt(true);
}

void setupWifiConnection() {
  WiFi.begin(ssid, password);
  Serial.println("Connecting");
  while(WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }  
}

void setupTimer() {
  startMillis = millis();
  lastMillis = startMillis;
  timerDelay = 5000;
}

void registerDevice() {
  HTTPClient http;
  String serverPath = server_url + "/registerdevice";
  Serial.print("serverPath: "); Serial.println(serverPath);
  http.begin(serverPath.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String httpRequestData = "deviceID=" + String(deviceID);
  int httpResponseCode = http.POST(httpRequestData);
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  http.end();
}

void setupServer() {
  server.on("/start", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(200, "text/plain", "RecordingStatus: " + String(true));
    Serial.print("Recording Status: "); Serial.println(true);
    handleRecording(true);
  });
  server.on("/stop", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send(200, "text/plain", "RecordingStatus: " + String(false));
    Serial.print("Recording Status: "); Serial.println(false);
    handleRecording(false);
  });
  server.onNotFound([](AsyncWebServerRequest *request){
    request->send(404, "text/plain", "Page not found");
  });
  server.begin();
}

void handleStart() {
  handleRecording(true);
}

void handleStop() {
  handleRecording(false);
}

void handleRecording(bool isRecording) {
  isUpload = isRecording;

  HTTPClient http;
  String serverPath = server_url + "/isRecording";
  // Serial.print("serverPath: "); Serial.println(serverPath);
  http.begin(serverPath.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String httpRequestData = "deviceID=" + String(deviceID) + "&isRecording=" + String(isRecording);
  int httpResponseCode = http.POST(httpRequestData);
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  http.end();
}

void setup(void) {
  Serial.begin(115200);
  pinMode(fsr4Pin, INPUT);
  Wire.begin(I2C_SDA, I2C_SCL, 1000000);

  setupADS();
  Serial.println("ADS Found!");
  setupMPU();
  Serial.println("MPU6050 Found!");
  setupWifiConnection();
  Serial.print("Connected to WiFi network with IP Address: ");Serial.println(WiFi.localIP());
  registerDevice();
  Serial.println("Device Registered");
  setupServer();
  Serial.println("Server Setup Complete");

  setupTimer();
  Serial.println("Timer set to 5 seconds (timerDelay variable), it will take 5 seconds before publishing the first reading.");
}

bool check_upload() {
  // MEMCK;
  HTTPClient http;
  bool toUpload = false;
  String serverPath = server_url + "/uploadcheck";
  http.begin(serverPath.c_str());
  int httpResponseCode = http.GET();
  if (httpResponseCode>0) {
    // Serial.print("HTTP Response code: ");
    // Serial.println(httpResponseCode);
    String payload = http.getString();
    if (payload.equals("true")) {
      toUpload = true;
      // Serial.println("toUpload true");
    } else {
      toUpload = false;
      // Serial.println("toUpload false");
    }
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
    toUpload = false;
    // Serial.println("toUpload false");
  }
  http.end();
  return toUpload;
}

void upload() {
  // Serial.println("Collecting Data");
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

  // Serial.println("-----------------------------------------------------------");

  double fsr4Read = (double) analogRead(fsr4Pin);
  double fsr4voltage = fsr4Read * current_voltage / 4096;
  // Serial.print("voltage: ");Serial.println(fsr4voltage);

  double reading0, reading1, reading2, reading3, reading4;
  reading0 = adc0 * (current_voltage / 32767.0);
  reading1 = adc1 * (current_voltage / 32767.0);
  reading2 = adc2 * (current_voltage / 32767.0);
  reading3 = adc3 * (current_voltage / 32767.0);
  reading4 = fsr4voltage;

  String queryString = "reading0=" + String(reading0) 
                      + "&reading1=" + String(reading1)
                      + "&reading2=" + String(reading2)
                      + "&reading3=" + String(reading3)
                      + "&reading4=" + String(reading4);

  // Serial.print("0: "); Serial.print(adc0); Serial.print("  "); Serial.print(reading0); Serial.println("V");
  // Serial.print("1: "); Serial.print(adc1); Serial.print("  "); Serial.print(reading1); Serial.println("V");
  // Serial.print("2: "); Serial.print(adc2); Serial.print("  "); Serial.print(reading2); Serial.println("V");
  // Serial.print("3: "); Serial.print(adc3); Serial.print("  "); Serial.print(reading3); Serial.println("V");
  // Serial.print("4: "); Serial.print(fsr4Read); Serial.print("  "); Serial.print(reading4); Serial.println("V");

  if(mpu.getMotionInterruptStatus()) {
    /* Get new sensor events with the readings */
    sensors_event_t a, g, temp;
    mpu.getEvent(&a, &g, &temp);

    /* Print out the values */
    // Serial.print("AccelX:"); Serial.print(a.acceleration.x); Serial.print(","); 
    // Serial.print("AccelY:"); Serial.print(a.acceleration.y); Serial.print(",");
    // Serial.print("AccelZ:"); Serial.print(a.acceleration.z); Serial.print(", ");
    // Serial.print("GyroX:"); Serial.print(g.gyro.x); Serial.print(",");
    // Serial.print("GyroY:"); Serial.print(g.gyro.y); Serial.print(",");
    // Serial.print("GyroZ:"); Serial.print(g.gyro.z); Serial.println("");

    queryString = queryString + "&accelx=" + String(a.acceleration.x)
                              + "&accely=" + String(a.acceleration.y)
                              + "&accelz=" + String(a.acceleration.z)
                              + "&gyrox=" + String(g.gyro.x)
                              + "&gyroy=" + String(g.gyro.y)
                              + "&gyroz=" + String(g.gyro.z);
  }
  HTTPClient http;
  String serverPath = server_url + "/upload";
  // Serial.print("serverPath: "); Serial.println(serverPath);
  http.begin(serverPath.c_str());
  http.addHeader("Content-Type", "application/x-www-form-urlencoded");
  String httpRequestData = queryString;
  int httpResponseCode = http.POST(httpRequestData);
  if (httpResponseCode>0) {
    Serial.print("HTTP Response code: ");
    Serial.println(httpResponseCode);
  }
  else {
    Serial.print("Error code: ");
    Serial.println(httpResponseCode);
  }
  http.end();
}

void loop(void) {
  if(WiFi.status()== WL_CONNECTED){
    // if (millis() - lastMillis > timerDelay) {
    //   isUpload = check_upload();
    //   Serial.print("isUpload?: "); Serial.println(isUpload); 
    //   lastMillis = millis();
    // }
    if (isUpload) {
      upload();
      Serial.println("Uploaded");
    }
  }
  else {
    Serial.println("Wifi Not Connected");
  }
  delay(100);
}