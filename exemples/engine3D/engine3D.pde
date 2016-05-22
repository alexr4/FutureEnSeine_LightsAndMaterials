FESEngine engine;

void setup()
{
  size(1280, 720, P3D);
  smooth(8);
  appParameter();
  
  engine = new FESEngine(width, height);
}

void draw()
{
  background(127);
  
  engine.renderPasses();
  
  showDebug(0, 0);
  engine.showDebugMap(width - 150, 0, 150, 150);
  engine.showDebug(0, height, 0.1, new PVector(0, 1));
}