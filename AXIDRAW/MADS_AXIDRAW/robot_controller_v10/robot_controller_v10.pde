/* Methods
 #Goto a position:
 rGoto(float _x, float _y, boolean _draw) 
 
 #Move relative to current position
 rGotoR(float _x, float _y, boolean _draw)
 
 #Move relative to current position, but with a direction and lenght
 rGotoRDir(float dir, float length, boolean _draw)
 
 #Draw a line
 rLine(float x, float y, float x2, float y2)
 
 #Draw a line with a direction and a lenght at an x and y position
 rLineDir(float _x, float _y, float _dir, float _length)
 
 #Draw a line with a direction from the current position
 rLineRDir( float _dir, float _length)
 
 #Draw a line from a current position
 
 #Get current position as a point
 getPos()
 
 # Calculate X Y from a position, direction and a length
 PVector calcXY(float _x, float _y, float _dir, float _length)
 Example:
 PVector v = calcXY(0, 0, 180, 100);
 println(v.x+ "," + v.y);
 
 
 # set the color of the stroke (set the color after you have added the stroke)
 setColor(255,0,0);
 */


import processing.pdf.*;

boolean saveOneFrame = false;
boolean saveOneFrameColors = false;

void setup()
{
  setup_axi() ;
  size(900, 700);
  background(255);
  strokeWeight(1.5f);
  stroke(0);
  noFill();
  init();
  scale = 0.90;
  translateY = 30;
  rGoto(115,290,false);
  rLine(115, 290, 270, 90);
  rLine(270, 90, 500, 80);
  rLine(500, 80, 700, 280);
  rLine(700, 280, 550, 610);
  rLine(550, 610, 240, 620);
  rLine(240, 620, 115, 290);

  rLine(115, 290, 500, 80); //p1 til p3
  rLine(500, 80, 550, 610); //p3 til p5
  rLine(550, 610,270, 90 ); //p5 til p2
  rLine(270, 90, 700, 280); //p2 til p4
  rLine(270, 90, 240, 620); //p2 til p6
  rLine(700, 280, 240, 620); //p4 til p6
  rLine(240, 620,500, 80 ); //p6 til p3
  rLine(700, 280,115, 290); //p4 til p1
  rLine(115, 290, 550, 610); //p1 til p5*/
  
  rGoto(400, 340, false);
}



void draw()
{

  example1();


  draw_axi();
  // drawRobot();
}

float vinkel = 0;
float rotation2 = 0;
float length2= 0;
float counts = 32;
float many = 100;
float step = 0;
float lengde2 = 0;
float i = 0;
float angle2 = 0;
float angleAdd = 0;
float angle = 0;
float theta = 0;
void example1()
{
  //rGoto(400, 340, false);
  rotation2 =  rotation2 +80 ;
  length2 = length2 + 1f;
  step = step + 0.1;
  

  if (frameCount < 50) 
  {

    rLineRDir(0 + rotation2, step + length2);
    for (float i = 0; i <= 360; i = i+many) 
    {
      //setColor(219,22,137);
      rLineRDir(i + rotation2, step + length2);
    }
  }
  if (frameCount == 50)
  {
    rGoto(465, 300, false);
  }
  if (frameCount > 50 && frameCount < 1300)
  {

    //setColor(42,2,116);
    vinkel = vinkel +11.2;//+random(0,3);
    rLineRDir(vinkel+ sin(radians(frameCount*5))*60.0f, 10);
  }
  if (frameCount == 1300)
  {
    rGoto(315, 505, false);
  }
  if (frameCount > 1300 && frameCount < 1400)
  {

    rotation2 = rotation2 + 4;
    lengde2 = lengde2 + 0.2f;
    //setColor(200,163,224);
    rLineRDir(0+rotation2, 20+lengde2);
    rLineRDir(40+rotation2, 20+lengde2);
    rLineRDir(80+rotation2, 20+lengde2);
    rLineRDir(120+rotation2, 20+lengde2);
    rLineRDir(160+rotation2, 20+lengde2);
    rLineRDir(200+rotation2, 20+lengde2);
    rLineRDir(240+rotation2, 20+lengde2);
    rLineRDir(280+rotation2, 20+lengde2);
    rLineRDir(320+rotation2, 20+lengde2);
  }
  if (frameCount == 1400)
  {
    rGoto(498, 490, false);
  }
  if (frameCount > 1400 && frameCount < 1500)
  {
    /*rotation2 = rotation2 + 119;
     length2 = length2 + 0.5;
     rLineRDir(0 + rotation2, 40 + length2);*/    //þrihyrningur snyst um sjalfan sig

    rotation2 = rotation2 + 10;
    lengde2 = lengde2 + 0.3f;
    //setColor(225,64,220);
    rLineRDir(0+rotation2, 20+lengde2);
    rLineRDir(90+rotation2, 20+lengde2);
    rLineRDir(180+rotation2, 20+lengde2);
    rLineRDir(270+rotation2, 20+lengde2);
  }
  if (frameCount == 1500)
  {
    rGoto(320, 365, false);
  }
  if (frameCount > 1500 && frameCount < 1550)
  {
    //setColor(207,117,214);
    i = i + 150;
    rLineRDir(i, 50);
  }
  if (frameCount == 1550)
  {
    rGoto(260, 360, false);
  }
  if (frameCount > 1550 && frameCount < 1650)
  {
    angle2 = angle2 +110;
    rLineRDir(angle2, 80);
  }
  if (frameCount == 1650)
  {
    rGoto(320, 265, false);
    vinkel = 0;
    lengde2 = 0;
  }

  if (frameCount > 1650 && frameCount < 1750)
  {
    vinkel = vinkel+150;
    lengde2 = lengde2 + 1.0f;
    rLineRDir(vinkel, lengde2); //(grad,længde)
    for (int i = 0; i < 100; i = i + 10) 
    {
      rLineRDir(50*-i, 1); 
      rLineRDir(100*i, 1);
    }
  }

  if (frameCount == 1750)
  {
    rGoto(305, 305, false);
    angle = 0;
    step = 0;
  }

  if (frameCount > 1750 && frameCount < 1800)
  {
    //setColor(245,111,229);
    angle = angle +55;
    step = step + 0.5;
    rLineRDir(angle, step);
  }

  if (frameCount == 1800)
  {
    rGoto(280, 140, false);
    angleAdd = 0;
    angle = 0;
    step = 0;
  }

  if (frameCount > 1800 && frameCount < 1890)
  {
    //setColor(111,16,180);
    angleAdd = angleAdd +2;
    angle = angle +angleAdd;
    step = step + 2;
    rLineRDir(angle, step);
  }

  if (frameCount == 1890)
  {
    rGoto(185, 290, false);

    rotation2 = 0;
    lengde2 = 0;
  }
  if (frameCount > 1890 && frameCount < 1980)
  {
    rotation2 = rotation2 + 90;
    lengde2 = lengde2 + 0.5f;
    //setColor(101,56,229);
    rLineRDir(90 + rotation2, 10+lengde2);
    rLineRDir(180 + rotation2, 10+lengde2);
    rLineRDir(270 + rotation2, 10+lengde2);
  }

  if (frameCount == 1980)
  {
    rGoto(388, 147, false);
    rotation2 = 0;
    length2 = 0;
  }
  if (frameCount > 1980 && frameCount < 2030)
  {
    rotation2 = rotation2 + 119;
    length2 = length2 + 0.5;
    rLineRDir(0 + rotation2, 40 + length2);
    //þrihyrningur snyst um sjalfan sig
    /* rotation2 = rotation2 + 60;
     lengde2 = lengde2 + 0.5f;
     rLineRDir(0 + rotation2, 30 + lengde2);
     rLineRDir(90 + rotation2, 30 + lengde2);
     rLineRDir(180 + rotation2, 30 + lengde2);
     rLineRDir(270 + rotation2, 30 + lengde2);*/
  }

  if (frameCount == 2030)
  {
    rGoto(455, 150, false);
    rotation2 = 0;
    length2 = 0;
  }

  if (frameCount > 2030 && frameCount < 2040)
  {
    rotation2 = rotation2 + 50;
    lengde2 = lengde2 + 0.3f;
    rLineRDir(0 + rotation2, 10 + lengde2);
    rLineRDir(90 + rotation2, 10 + lengde2);
    rLineRDir(180 + rotation2, 10 + lengde2);
    rLineRDir(270 + rotation2, 10 + lengde2);
  }
  
  if (frameCount == 2040)
  {
    rGoto(800,0,false);
  }
}

void example2()
{
  rotation2 = rotation2 + 119;
  length2 = length2 + 0.3;
  rLineRDir(0 + rotation2, 40 + length2);
}



void keyPressed()
{
  keyPressed_axi();
  /*if (key == ' ')
   {
   pointList.clear();
   init();
   frameCount= 0;
   }*/
  if (key == 's')
  {

    saveFrame(random(1000000) + ".jpg");
  }
}