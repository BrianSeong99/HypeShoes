const int fsrPin = 34;

void setup() {
  Serial.begin(9600);
  pinMode(fsrPin, INPUT);
}

void loop() {
  int fsrRead = analogRead(fsrPin);
  // if(analogRead(fsrPin) >= 10){
  Serial.print(fsrRead);
  Serial.print(" = ");
  float voltage0 = fsrRead * (3.3 / 1023.0);
  Serial.print(voltage0);
  Serial.println("kg");
  delay(100);
  //  }
}