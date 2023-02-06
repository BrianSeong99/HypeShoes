#include <Adafruit_ADS1X15.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <Wire.h>

#define I2C_SDA 17
#define I2C_SCL 21
#define IMU_SDA 26
#define IMU_SCL 18

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
  Serial.println("here");

  Wire.begin(I2C_SDA, I2C_SCL, 1000000);
  // Wire1.begin(IMU_SDA, IMU_SCL, 1000000);
  // I2CADS.begin(I2C_SDA, I2C_SCL, 1000000);
  if (!ads.begin(0x48, &Wire)) {
    Serial.println("Failed to initialize ADS.");
    while (1);
  }

  Serial.println("here2");

  // I2CIMU.begin(IMU_SDA, IMU_SCL, 1000000);
  Serial.println("here3");
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

  // Wire.begin(IMU_SDA, IMU_SCL, 100000); // sda, scl, clock speed
  // Wire.beginTransmission(MPU_ADDR);
  // Wire.write(0x6B);  // PWR_MGMT_1 register
  // Wire.write(0);     // set to zero (wakes up the MPU−6050)
  // Wire.endTransmission(true);
}

void loop(void)
{
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

  Serial.print("0: "); Serial.print(adc0); Serial.print("  "); Serial.print(adc0 * (current_voltage / 32767.0)); Serial.println("V");
  Serial.print("1: "); Serial.print(adc1); Serial.print("  "); Serial.print(adc1 * (current_voltage / 32767.0)); Serial.println("V");
  Serial.print("2: "); Serial.print(adc2); Serial.print("  "); Serial.print(adc2 * (current_voltage / 32767.0)); Serial.println("V");
  Serial.print("3: "); Serial.print(adc3); Serial.print("  "); Serial.print(adc3 * (current_voltage / 32767.0)); Serial.println("V");
  Serial.print("4: "); Serial.print(fsr4Read); Serial.print("  "); Serial.print(fsr4voltage); Serial.println("V");
  Serial.println();
  
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

  delay(1000);
}