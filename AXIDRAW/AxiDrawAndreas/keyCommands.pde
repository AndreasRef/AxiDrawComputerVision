void keyReleased() {
  if (key == CODED) {
    if (keyCode == UP) keyup = false; 
    if (keyCode == DOWN) keydown = false; 
    if (keyCode == LEFT) keyleft = false; 
    if (keyCode == RIGHT) keyright = false; 
    if (keyCode == SHIFT) { 
      shiftKeyDown = false;
    }
  } else
    key = Character.toLowerCase(key);

  if ( key == 'h')  // display help
  {
    hKeyDown = false;
  }
}


void keyPressed() {
  if (key == CODED) {

    // Arrow keys are used for nudging, with or without shift key.
    if (keyCode == UP) 
    {
      keyup = true;
    }
    if (keyCode == DOWN)
    { 
      keydown = true;
    }
    if (keyCode == LEFT) keyleft = true; 
    if (keyCode == RIGHT) keyright = true; 
    if (keyCode == SHIFT) shiftKeyDown = true;
  } else
  {
    key = Character.toLowerCase(key);
    println("Key pressed: " + key); 

    if ( key == 'b')   // Toggle brush up or brush down with 'b' key
    {
      if (BrushDown)
        raiseBrush();
      else
        lowerBrush();
    }

    if ( key == 'z')  // Zero motor coordinates
      zero();

    if ( key == 'c')  // Zero motor coordinates
      clearall();

    if ( key == ' ')  //Space bar: Pause
      pause();

    if ( key == 'q')  // Move home (0,0)
    {
      raiseBrush();
      MoveToXY(0, 0);
    }

    if ( key == 'h')  // display help
    {
      hKeyDown = true;
      println("HELP requested");
    } 
    if ( key == 't')  // Disable motors, to manually move carriage.  
      MotorsOff();

    if ( key == '1')
      MotorSpeed = 500;  
    if ( key == '2')
      MotorSpeed = 1000;        
    if ( key == '3')
      MotorSpeed = 2000;        
    if ( key == '4')
      MotorSpeed = 3000;        
    if ( key == '5')
      MotorSpeed = 4000;        
    if ( key == '6')
      MotorSpeed = 4500;        
    if ( key == '7')
      MotorSpeed = 5000;        
    if ( key == '8')
      MotorSpeed = 5500;        
    if ( key == '9')
      MotorSpeed = 6000;
  }
}
