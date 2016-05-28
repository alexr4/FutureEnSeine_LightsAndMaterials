public void renderScene(PGraphics buffer) 
{

  buffer.resetShader();
  buffer.background(13);
  drawAxis("RVB", 250, buffer);

  //lights
  //buffer.lights();

  buffer.pushMatrix();
  buffer.noLights();
  buffer.rotateX(millis() * - 0.0005);
  buffer.pushStyle();
  buffer.translate(0, 0, 500);//-200, 200, 250);
  buffer.noStroke();
  buffer.fill(255, 180, 0);
  buffer.sphere(25);
  buffer.popStyle();



  buffer.pointLight(255, 180, 0, 0, 0, 500);//-200, 200, 250);
  buffer.lightFalloff(1.0, 0.0, 0.0);

  buffer.popMatrix();

  buffer.directionalLight(0, 180, 255, -1, 1, -1);


  material(buffer);

  buffer.noStroke();
  buffer.pushMatrix();
  //buffer.rotateY(millis() * 0.0001);
  //object
  if (complexPoly)
  {
    if (state == 10)
    {
      buffer.rectMode(CENTER);
      buffer.rect(0, 0, 500, 500);
    } else
    {
      if (!wireframe)
      {
      } else
      {
        buffer.shape(poly.wireframeShape);
      }
      buffer.shape(poly.icosahedron);
    }
  } else if (state == 14)
  {
    buffer.pushStyle();
    buffer.strokeWeight(100);
    buffer.strokeCap(SQUARE);
    buffer.stroke(255);
    for (int i=0; i<nbCube; i++)
    {
      PVector pos = positionList.get(i);

      buffer.point(pos.x, pos.y, pos.z);
    }
    buffer.popStyle();
  } else
  {
    for (int i=0; i<nbCube; i++)
    {
      PVector rot = rotationList.get(i);
      PVector pos = positionList.get(i);

      buffer.pushMatrix();
      buffer.translate(pos.x, pos.y, pos.z);
      buffer.rotateX(rot.x);
      buffer.rotateY(rot.y);
      buffer.rotateZ(rot.z);
      buffer.noStroke();
      buffer.box(size);
      buffer.sphere(size * 0.65);
      buffer.popMatrix();
    }
  }
  buffer.popMatrix();

  if (state==13)
  {
    buffer.resetShader();
    buffer.noLights();
    cubemap.displayDynamicCubeMap(buffer);
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