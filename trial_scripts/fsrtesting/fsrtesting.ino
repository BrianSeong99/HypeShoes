const int fsrPin = 34;

void setup() {
  Serial.begin(9600);
  pinMode(fsrPin, INPUT);
}

void loop() {
  int fsrRead = analogRead(fsrPin);
  // if(analogRead(fsrPin) >= 10){
  Serial.println(fsrRead);
  delay(100);
  //  }
}