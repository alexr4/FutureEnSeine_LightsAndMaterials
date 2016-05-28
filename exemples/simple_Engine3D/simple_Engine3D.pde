import peasy.*;
import java.util.*;

PeasyCam cam;

//3D coponent
PImage diffuseTex;
Icosahedron poly;
CubeMap cubemap;
int nbCube = 50;
int radius = 200;
int size = 50;
ArrayList<PVector> rotationList;
ArrayList<PVector> positionList;

int state;
int maxState;

boolean complexPoly;
boolean wireframe;


void setup()
{
  //fullScreen(P3D);
  size(1280, 720, P3D);
  cam = new PeasyCam(this, 0, 0, 0, 500);
  
  cubemap = new CubeMap(1.0);
  initMaterial();
  diffuseTex = loadImage("textures/diffuse.jpg");
  poly = new   Icosahedron(8, 150, diffuseTex);
  
  positionList = new ArrayList<PVector>();
  rotationList = new ArrayList<PVector>();
  for(int i=0; i<nbCube; i++)
  {
    rotationList.add(new PVector(random(TWO_PI), random(PI), random(PI)));
    positionList.add(new PVector(random(-radius, radius), random(-radius, radius), map(i, 0, nbCube, -radius, radius)));
  }
  
}

void draw()
{
  renderScene(g);
}

void keyPressed()
{
  if (key == '+')
  {
    if (state < maxState)
    {
      state++;
    } else
    {
      state= 0;
    }
  }
  if (key == '-')
  {
    if (state > 0)
    {
      state--;
    } else
    {
      state = maxState;
    }
  }

  if (key == 'u' || key == 'U')
  {

    poly = new   Icosahedron(4, 150, diffuseTex);
  }

  if (key == 'c' || key == 'C')
  {
    complexPoly = !complexPoly;
  }
  
  if(key == 'w' || key == 'W')
  {
    wireframe = !wireframe;
  }
}