#include <Adafruit_ADS1X15.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

#include <WiFi.h>
#include <HTTPClient.h>

#define I2C_SDA 17
#define I2C_SCL 21
#define IMU_SDA 26
#define IMU_SCL 18

const char *ssid = "HJHJHJ";
const char *password = "HJ1211HJ1211";

String server_url = "http://10.0.0.92:5001/"; // Location to send POSTed data

unsigned long lastTime = 0;
unsigned long timerDelay = 5000;

// Adafruit_ADS1115 ads;  /* Use this for the 16-bit version */
// Adafruit_MPU6050 mpu;

const int fsr4Pin = 34;

void setup(void) {
  Serial.begin(115200);
  
  // pinMode(fsr4Pin, INPUT);
  // Wire.begin(I2C_SDA, I2C_SCL, 1000000);
  // if (!ads.begin(0x48, &Wire)) {
  //   Serial.println("Failed to initialize ADS.");
  //   while (1);
  // }

  // if (!mpu.begin(0x68, &Wire)) {
  //   Serial.println("Sensor init failed");
  //   while (1)
  //     yield();
  // }
  // Serial.println("MPU6050 Found!");

  // //setupt motion detection
  // mpu.setHighPassFilter(MPU6050_HIGHPASS_0_63_HZ);
  // mpu.setMotionDetectionThreshold(1);
  // mpu.setMotionDetectionDuration(20);
  // mpu.setInterruptPinLatch(true);	// Keep it latched.  Will turn off when reinitialized.
  // mpu.setInterruptPinPolarity(true);
  // mpu.setMotionInterrupt(true);

  WiFi.begin(ssid, password);
  Serial.println("Connecting");
  while(WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to WiFi network with IP Address: ");
  Serial.println(WiFi.localIP());
 
  Serial.println("Timer set to 5 seconds (timerDelay variable), it will take 5 seconds before publishing the first reading.");
}

bool check_upload() {
  if(WiFi.status()== WL_CONNECTED){
    HTTPClient http;
    String serverPath = server_url + "uploadcheck";
    http.begin(serverPath.c_str());
    int httpResponseCode = http.GET();
    if (httpResponseCode>0) {
      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
      String payload = http.getString();
      Serial.println(payload);
    }
    else {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
    }
    http.end();
  }
  else {
    return false;
  }
}

void loop(void) {
  // //Send an HTTP POST request every 10 minutes
  // if ((millis() - lastTime) > timerDelay) {
    
  //   lastTime = millis();
  // }

  bool isUpload = check_upload();
  delay(2000);
}