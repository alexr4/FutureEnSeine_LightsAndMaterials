//Sketch properties
String appName = "Futur en Seine : Engine Demo";
String version = "Alpha";
String subVersion = "0.0.1";
String frameName;
FPSTracking fpsTracker;

//App Parameters
void appParameter()
{
  frameName = appName+"_"+version+"_"+subVersion;
  surface.setTitle(frameName);
  float w = 100;
  float h = 25;
  fpsTracker = new FPSTracking(floor(w), 60, w, h);
}

void showDebug(float x, float y)
{
  drawAxis(100, "RVB");
  showFpsOnFrameTitle();
  fpsTracker.run(frameRate);
  image(fpsTracker.getImageTracker(), x, y);
}

void showFpsOnFrameTitle()
{
  surface.setTitle(frameName+"    FPS : "+int(frameRate));
}

void drawAxis(float l, String colorMode)
{
  color xAxis = color(255, 0, 0);
  color yAxis = color(0, 255, 0);
  color zAxis = color(0, 0, 255);

  if (colorMode == "rvb" || colorMode == "RVB")
  {
    xAxis = color(255, 0, 0);
    yAxis = color(0, 255, 0);
    zAxis = color(0, 0, 255);
  } else if (colorMode == "hsb" || colorMode == "HSB")
  {
    xAxis = color(0, 100, 100);
    yAxis = color(115, 100, 100);
    zAxis = color(215, 100, 100);
  }

  pushStyle();
  strokeWeight(1);
  //x-axis
  stroke(xAxis); 
  line(0, 0, 0, l, 0, 0);
  //y-axis
  stroke(yAxis); 
  line(0, 0, 0, 0, l, 0);
  //z-axis
  stroke(zAxis); 
  line(0, 0, 0, 0, 0, l);
  popStyle();
}

void drawAxis(float l, PVector o, PGraphics buff)
{
  color xAxis = color(255, 0, 0);
  color yAxis = color(0, 255, 0);
  color zAxis = color(0, 0, 255);
  xAxis = color(255, 0, 0);
  yAxis = color(0, 255, 0);
  zAxis = color(0, 0, 255);
  buff.pushStyle();
  buff.strokeWeight(1);
  buff.pushMatrix();
  buff.translate(o.x, o.y, o.z);
  //x-axis
  buff.stroke(xAxis); 
  buff.line(0, 0, 0, l, 0, 0);
  //y-axis
  buff.stroke(yAxis); 
  buff.line(0, 0, 0, 0, l, 0);
  //z-axis
  buff.stroke(zAxis); 
  buff.line(0, 0, 0, 0, 0, l);
  buff.popMatrix();
  buff.popStyle();
}