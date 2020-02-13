float translateX = 0;
float translateY = 0;
float scale = 1;

ArrayList<Point> pointList = new ArrayList<Point>();
class Point extends PVector
{
  Point()
  {
  }
  Point(PVector p)
  {
    setP(p);
  }
  Point(float _x, float _y)
  {
    super(_x, _y);
  }
  void setP(PVector p)
  {
    x = p.x;
    y = p.y;
  }
  boolean draw;
  color c = color(255, 255, 255, 150);
}



void init()
{
  rGoto(width/2, height/2, false);
}

Point rGoto(float _x, float _y, boolean _draw)
{
  Point vec =  new Point((_x+translateX)*scale, (_y+translateY)*scale);
  vec.draw = _draw;
  addPoint(vec);

  return vec;
} 

Point rGoto(PVector v, boolean _draw)
{
  Point vec =  new Point(v);
  vec.draw = _draw;
  addPoint(vec);

  return vec;
}


void setColor(float r, float g, float b)
{

  pointList.get(pointList.size()-1).c = color(r, g, b);
}

Point rGotoR(float _x, float _y, boolean _draw)
{
 Point vec = new Point((_x+getPos().x)*scale, (_y+getPos().y)*scale);
   addPoint(vec);
  vec.draw = _draw;
  return vec;
}

Point rGotoRDir(float dir, float length, boolean _draw)
{
  Point vec = new Point();
  vec.setP(PVector.fromAngle(radians(dir)).mult(length*scale).add(getPos()));
  vec.draw = _draw;
  addPoint(vec);

  return vec;
}

Point rGotoDir(float _x, float _y, float dir, float length, boolean _draw)
{
  Point vec =(Point) PVector.fromAngle(radians(dir)).mult(length*scale).add(new PVector(_x, _y));
  vec.draw = _draw;
  addPoint(vec);
  return vec;
}

Point rLine(float x, float y, float x2, float y2)
{
  if (!(getPos().x == x && getPos().y == y))
  {
    rGoto(x, y, false);
  }
  return  rGoto(x2, y2, true);
}

Point rLineR(float x2, float y2)
{
  return  rGoto(x2, y2, true);
}

Point rLineDir(float _x, float _y, float _dir, float _length)
{
  if (!(getPos().x == _x && getPos().y == _y))
  {
    rGoto(_x, _y, false);
  }


  return  rGotoRDir(_dir, _length, true);
}


Point rLineRDir( float _dir, float _length)
{

  return  rGotoRDir(_dir, _length, true);
}


Point rCircleRDir(float _dir, float _length)
{
  Point p = new Point();
  for (int i = 0; i < 360/_dir; i = i+1)
  {
    p = rLineRDir(_dir*i, _length);
  }

  return p;
}
Point calcXY(float _x, float _y, float _dir, float _length)
{
  Point vec =new Point();
  vec.setP(PVector.fromAngle(radians(_dir)).mult(_length).add(new PVector(_x, _y)));
  return vec;
}

float getAngle()
{
  if (pointList.size() > 1)
  {
    return degrees(PVector.angleBetween(pointList.get(pointList.size()-1), getPos()));
  }
  return 0;
}

Point getPos()
{
  return pointList.get(pointList.size()-1);
}



void drawRobot()
{
  if (saveOneFrame == true) {
    beginRecord(PDF, "Line" + random(1000000) + ".pdf");
  }
  if (!saveOneFrame || (saveOneFrame && saveOneFrameColors))
  {
    background(0);
  } else if (saveOneFrame && !saveOneFrameColors)
  {
    background(255);
  }
  noFill();

  for (int i = 1; i < pointList.size() && pointList.size() > 1; i = i +1)
  {
    Point p = pointList.get(i);
    Point pOld = pointList.get(i-1);
    if (p.draw)
    {
      if (!saveOneFrame || (saveOneFrame && saveOneFrameColors))
      {
        stroke(p.c);
      } else if (saveOneFrame && !saveOneFrameColors)
      {
        stroke(0);
      }
      line(p.x, p.y, pOld.x, pOld.y);
      if (!saveOneFrame)
      {
        ellipse(p.x, p.y, 3, 3);
      }
    }
  }
  if (!saveOneFrame)
  {
    noStroke();
    fill(255, 255, 100);
    ellipse(getPos().x, getPos().y, 20, 20);
    fill(255);
    text(mouseX + "," + mouseY, 20, 20);
  }
  if (saveOneFrame == true) {
    endRecord();
    saveOneFrame = false;
  }
}

boolean lastDraw= false;
void addPoint(Point p)
{
  // println(p.draw);
  // if (p.x >=0 && p.y >=0)
  {
    pointList.add(p);
    if (lastDraw != p.draw)
    {
      if (p.draw)
      {
        ToDoList = (PVector[]) append(ToDoList, new PVector(-31, 0)); //Command 31 (lower pen)
      } else
      {
        ToDoList = (PVector[]) append(ToDoList, new PVector(-30, 0)); //Command 30 (raise pen)
      }
      lastDraw = p.draw;
      println("hep2");
    }
    ToDoList = (PVector[]) append(ToDoList, p);
  }
}