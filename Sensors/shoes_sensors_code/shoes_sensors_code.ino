#include <Adafruit_ADS1X15.h>
#include <Wire.h>

#define I2C_SDA 17
#define I2C_SCL 21


TwoWire I2CADS = TwoWire(0);
Adafruit_ADS1115 ads;  /* Use this for the 16-bit version */

const int fsr4Pin = 34;

// double voltage2kg(double totalVoltage, double fsrVoltage) {
//   if (fsrVoltage == 0) {
//     return 0.0;
//   }
//   double fsrResistance = totalVoltage - fsrVoltage;
//   fsrResistance *= 10000;
//   fsrResistance /= fsrVoltage;
//   // double fsrResistance = 10000 * fsrVoltage / (totalVoltage - fsrVoltage);
//   // double fsrResistance = (-3300) * 10000 / fsrVoltage;
//   Serial.print("resistance: "); Serial.println(fsrResistance);
  
//   double fsrConductance = 1000000 / fsrResistance;
//   Serial.print("conductance: "); Serial.println(fsrConductance);

//   double fsrForce;
//   if (fsrConductance <= 100) {
//     fsrForce = fsrConductance / 25;
//   } 
//   // else {
//   //   fsrForce = fsrConductance - 1000;
//   //   fsrForce /= 30;
//   // }
  
//   return fsrForce;
// }

void setup(void)
{
  Serial.begin(115200);
  
  pinMode(fsr4Pin, INPUT);

  I2CADS.begin(I2C_SDA, I2C_SCL, 100000);
  if (!ads.begin(0x48, &I2CADS)) {
    Serial.println("Failed to initialize ADS.");
    while (1);
  }
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

  delay(1000);
}