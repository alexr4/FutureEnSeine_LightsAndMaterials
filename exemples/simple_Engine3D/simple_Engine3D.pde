import peasy.*;

PeasyCam cam;

//3D coponent
PImage diffuseTex;
Icosahedron poly;
CubeMap cubemap;

int state;
int maxState;

boolean complexPoly;
boolean wireframe;


void setup()
{
  size(1280, 720, P3D);
  cam = new PeasyCam(this, 0, 0, 0, 500);
  
  cubemap = new CubeMap(0.5);
  initMaterial();
  diffuseTex = loadImage("textures/diffuse.jpg");
  poly = new   Icosahedron(2, 150, diffuseTex);
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