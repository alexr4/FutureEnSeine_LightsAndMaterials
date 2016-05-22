ArrayList<PShader> shaderList;

PShader depth;
PShader stencil;
PShader diffuse;
PShader normals;
PShader position;
PShader rim; //fresnel
PShader phongLighting; //À corriger
PShader phongLightingGamma; //À corriger
PShader bump; //À corriger
PShader displacement; 
PShader iridescent;
PShader environment;

PImage uvChecker;

void initMaterial()
{
  shaderList = new ArrayList<PShader>();

  //depthmap shader
  depth = loadShader("shaders/depth_frag.glsl", "shaders/depth_vert.glsl");
  depth.set("near", 0.0);
  depth.set("far", 1000.0);

  //stencilmap shader
  stencil = loadShader("shaders/stencil_frag.glsl", "shaders/stencil_vert.glsl");

  //diffuse shader (with tilling)
  uvChecker = loadImage("textures/uvChecker.png"); 
  diffuse = loadShader("shaders/diffuse_frag.glsl", "shaders/diffuse_vert.glsl");
  diffuse.set("texture", uvChecker);
  diffuse.set("tiling", 0.5, 0.5);

  //normalsmap shader
  normals = loadShader("shaders/normals_frag.glsl", "shaders/normals_vert.glsl");

  //position
  position = loadShader("shaders/position_frag.glsl", "shaders/position_vert.glsl");

  //rim sahder (fresbel)
  rim = loadShader("shaders/rim_frag.glsl", "shaders/rim_vert.glsl");
  rim.set("rimPower", 0.25);

  //PhongLigthing
  phongLighting = loadShader("shaders/phongLight_frag.glsl", "shaders/phongLight_vert.glsl");
  phongLighting.set("kd", 1.0, 1.0, 1.0);
  phongLighting.set("ka", 1.0, 1.0, 1.0);
  phongLighting.set("ks", 1.0, 1.0, 1.0);
  phongLighting.set("emissive", 0.1, 0.1, 0.1);
  phongLighting.set("shininess", 100.0);

  //PhongLigthing Gamma
  phongLightingGamma = loadShader("shaders/phongLight_GammaCorrection_frag.glsl", "shaders/phongLight_GammaCorrection_vert.glsl");
  phongLightingGamma.set("kd", 1.0, 1.0, 1.0);
  phongLightingGamma.set("ka", 1.0, 1.0, 1.0);
  phongLightingGamma.set("ks", 1.0, 1.0, 1.0);
  phongLightingGamma.set("emissive", 0.1, 0.1, 0.1);
  phongLightingGamma.set("shininess", 100.0);

  /* bump = loadShader("shaders/bump_frag.glsl", "shaders/bump_vert.glsl");
   bump.set("kd", 1.0, 1.0, 1.0);
   bump.set("ka", 1.0, 1.0, 1.0);
   bump.set("ks", 1.0, 1.0, 1.0);
   bump.set("emissive", 0.1, 0.1, 0.1);
   bump.set("shininess", 100.0);
   bump.set("bumpmap", loadImage("textures/normalmap.jpg"));
   bump.set("minNormalEmissive", 0.5);*/

  //displacement mapping;
  displacement = loadShader("shaders/displacement_frag.glsl", "shaders/displacement_vert.glsl");
  displacement.set("displacementMap", loadImage("textures/displacementmap.jpg"));
  displacement.set("displaceStrength", 50.75);

  //iridescence
  iridescent = loadShader("shaders/iridescent_frag.glsl", "shaders/iridescent_vert.glsl");
  iridescent.set("iridescentRatio", 0.75);

  //Environement
  environment = loadShader("shaders/environment_ChromaDisp_frag.glsl", "shaders/environment_ChromaDisp_vert.glsl");
  environment.set("cubemap", cubemap.location);

  shaderList.add(null);
  shaderList.add(depth);
  shaderList.add(stencil);
  shaderList.add(diffuse);
  shaderList.add(normals);
  shaderList.add(position);
  shaderList.add(rim);
  shaderList.add(phongLighting);
  shaderList.add(phongLightingGamma);
  //shaderList.add(bump);
  shaderList.add(displacement);
  shaderList.add(iridescent);
  shaderList.add(environment);


  maxState = shaderList.size()-1;
}

void material(PGraphics buffer)
{
  if (state ==0)
  {
    buffer.background(13);
    buffer.resetShader();
    //light Properties
    buffer.lightSpecular(127, 127, 127);
    buffer.directionalLight(25, 25, 25, 0, 0, -1);
    buffer.ambientLight(13, 13, 13);
    //material Properties
    buffer.shininess(150.0);
    buffer.specular(255, 255, 255);
    buffer.ambient(255, 0, 0);
    buffer.emissive(0, 25, 25);
  } else {
    if (state == 1)
    {
      buffer.background(255);
    } else if (state == 2)
    {
      buffer.background(0);
    } else if (state == 3)
    {
      poly.icosahedron.setTexture(uvChecker);
      //diffuse.set("tiling", norm(mouseX, 0, width), norm(mouseY, 0, height));
    }
    if (state == 6)
    {
      //rim.set("rimPower", norm(mouseX, 0, width));
    }
    if (state == 9)
    {
      // displacement.set("displaceStrength", (float) mouseX);
    }
    if(state == 11)
    {
      sendCameraMatrixTo(environment);
    }

    buffer.shader(shaderList.get(state));
  }
}