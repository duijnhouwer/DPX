// PART OF THE DPX TOOLKIT
// Jacob Duijnhouwer 2015-03-24


const int responsePin2 = 2;
const int responsePin4 = 4;
const int outPinJ = 10;
const int outPinK = 11;
const int outPinL = 12;
const int outPinM = 13;
const int buttonPressPin2= 10;
const int buttonPressPin4= 12;
bool responsePin2isOn = false;
bool responsePin4isOn = false;

void setup()
{
  pinMode(responsePin2,INPUT);
  pinMode(responsePin4,INPUT);
  //
  pinMode(outPinJ,OUTPUT);
  pinMode(outPinK,OUTPUT);
  pinMode(outPinL,OUTPUT);
  pinMode(outPinM,OUTPUT);
  digitalWrite(outPinJ,LOW);
  digitalWrite(outPinK,LOW);
  digitalWrite(outPinL,LOW);
  digitalWrite(outPinM,LOW);
  // Setup the Serial link with matlab
  Serial.begin(9600);
  Serial.println('a');
  char frommatlab='0';
  while (frommatlab!='m') {
    // Keep looping until matlab on host pc has send the letter 'm' 
    // over the serial port, as a means of confirming that the 
    // connection has been established.
    frommatlab=Serial.read();
  }
  Serial.println('0');
}

void loop()
{
  // Responses
  // PIN 2
  if (digitalRead(responsePin2)==HIGH && responsePin2isOn==false)
  {
     digitalWrite(buttonPressPin2,HIGH);
     Serial.println('2');
     responsePin2isOn=true;
  }
  else if (digitalRead(responsePin2)==LOW && responsePin2isOn==true)
  {
     digitalWrite(buttonPressPin2,LOW);
     Serial.println('0');
     responsePin2isOn=false;
  }
  // PIN 4
  if (digitalRead(responsePin4)==HIGH && responsePin4isOn==false)
  {
     digitalWrite(buttonPressPin4,HIGH);
     Serial.println('4');
     responsePin4isOn=true;
  }
  else if (digitalRead(responsePin4)==LOW && responsePin4isOn==true)
  {
     digitalWrite(buttonPressPin4,LOW);
     Serial.println('0');
     responsePin4isOn=false;
  }
  Serial.flush(); // Waits for the transmission of outgoing serial data to complete
  delay(5);
}

 void serialEvent()
 {
   // This function is called automatically when new data is  
   // available on the input side of the arduino. So in this case when 
   // transferred a reward signal from matlab.
   char frommatlab=Serial.read();
   // J = 10
   if (frommatlab=='J') {
    digitalWrite(outPinJ,HIGH);
   } 
   else if (frommatlab=='j') { // keep high until set low explicitly
     digitalWrite(outPinJ,LOW);
   }
   // K = 11
   if (frommatlab=='K') {
    digitalWrite(outPinK,HIGH);
   } 
   else if (frommatlab=='k') { // keep high until set low explicitly
     digitalWrite(outPinK,LOW);
   }
   // L = 12 
   if (frommatlab=='L') {
    digitalWrite(outPinL,HIGH);
   } 
   else if (frommatlab=='l') { // keep high until set low explicitly
     digitalWrite(outPinL,LOW);
   }
   // M=13 
   if (frommatlab=='M') {
    digitalWrite(outPinM,HIGH);
   } 
   else if (frommatlab=='m') { // keep high until set low explicitly
     digitalWrite(outPinM,LOW);
   }
 }
 
  

