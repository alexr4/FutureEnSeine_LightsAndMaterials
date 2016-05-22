public void renderScene(PGraphics buffer) 
{
  
  buffer.background(13);
  drawAxis("RVB", 100, buffer);

  //lights
  //buffer.lights();
  /*buffer.directionalLight(0, 180, 255, -1, 1, -1);
  buffer.pointLight(255, 180, 0, -200, 200, 250);
  buffer.lightFalloff(1.0, 0.0, 0.0);
  */
  buffer.directionalLight(0, 255, 0, 1, 1, -1);
  buffer.directionalLight(255, 0, 0, -1, 1, -1);

  material(buffer);
  
  buffer.noStroke();
  //object
  if (complexPoly)
  {
    if (!wireframe)
    {
    } else
    {
      buffer.shape(poly.wireframeShape);
    }
    buffer.shape(poly.icosahedron);
  } else
  {
    buffer.pushMatrix();
    buffer.rotateY(HALF_PI/2);
    buffer.noStroke();
    buffer.box(225);
    buffer.sphere(150);
    buffer.popMatrix();
  }
}

public void drawAxis(String colorMode, float axisLength, PGraphics buffer)
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

  buffer.pushStyle();
  buffer.pushMatrix();
  buffer.translate(0, 0, 0);
  buffer.strokeWeight(1);
  //x-axis
  buffer.stroke(xAxis); 
  buffer.line(0, 0, 0, axisLength, 0, 0);
  //y-axis
  buffer.stroke(yAxis); 
  buffer.line(0, 0, 0, 0, axisLength, 0);
  //z-axis
  buffer.stroke(zAxis); 
  buffer.line(0, 0, 0, 0, 0, axisLength);
  buffer.popMatrix();
  buffer.popStyle();
}