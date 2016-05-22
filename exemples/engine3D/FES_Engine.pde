class FESEngine extends Engine3D
{
  //3D components

  //3D Materials

  //lights

  FESEngine()
  {
    super();
  }

  FESEngine(int width_, int height_)
  {
    super(width_, height_);
  }


  private void initMaterial()
  {
    /*   sculptureMaterial = loadShader("shaders/sculptureMat_frag.glsl", "shaders/sculptureMat_vert.glsl");
     groundMaterial = loadShader("shaders/groundMat_frag.glsl", "shaders/groundMat_vert.glsl");
     
     //Sculpture
     //diffuse
     //sculptureMaterial.set("diffuse", texM);
     sculptureMaterial.set("tiling", 1.0, 1.1); 
     
     //noise
     sculptureMaterial.set("amplitude", random(10, 40));
     sculptureMaterial.set("octave", (int) random(3, 5));
     sculptureMaterial.set("noiseInc", random(1000));
     
     //depth
     //diffuseShader.set("near", frustum.nearDistance);
     //diffuseShader.set("far", frustum.farDistance);
     
     //SSD
     //diffuseShader.set("diffuse", texM);
     //diffuseShader.set("width", norm(16, 0, 16));
     //diffuseShader.set("height", norm(9, 0, 16));
     
     //Displacement
     //diffuseShader.set("displacementMap", loadImage("marble.jpg"));  
     //diffuseShader.set("displaceStrength", 1000.0);
     
     //Rim
     sculptureMaterial.set("rimPower", 0.7f);
     sculptureMaterial.set("rimIntensity", 0.15f);
     
     //phongLight
     sculptureMaterial.set("kd", 0.25, 0.25, 0.25);
     sculptureMaterial.set("ka", 0.25, 0.25, 0.25);//1.0, 1.0, 1.0);
     sculptureMaterial.set("ks", 0.25, 0.25, 0.25);
     sculptureMaterial.set("emissive", 0.5, 0.5, 0.5);//too emissive : (0.55, 0.55, 0.55);
     sculptureMaterial.set("shininess", 500.0);
     
     //Bump normal map
     //sculptureMat.set("bumpmap", loadImage("normalmap.jpg"));
     //sculptureMat.set("minNormalEmissive", 0.5);
     
     //Environment
     sculptureMaterial.set("cubemap", cubemap.location);
     sculptureMaterial.set("fresnel", 0.5f);
     sculptureMaterial.set("reflectionRatio", 0.98f);
     
     //marble
     sculptureMaterial.set("marbleNoiseInc", random(1000));
     sculptureMaterial.set("marbleOctave", (int) random(7, 10));
     sculptureMaterial.set("marbleAmplitude", random(20, 60));*/
  }


  @Override public void renderPasses()
  {
    gizmo = false;
    Camera ligthCamera = new Camera(fillLight.getSkyPosition(), new PVector(), new PVector(0, 1, 0));

    //camera.truck(-1);
    //camera.boom(-1);
    //camera.dolly(1);
    //camera.pan(radians(0.5));
    //camera.roll(radians(0.5));
    //camera.circle(radians(0.5));
    //camera.look(radians(0.5), radians(0.25));
    //camera.tumble(radians(0.5), radians(0.25));
    //camera.track(1, 1);
    //camera.rotateArroundElevation(radians(0.5), 500);
    //camera.rotateArroundAzimuth(radians(0.5), 500);
    //camera.rotateArround(radians(0.5), radians(0.5), 500);

    //Render
    render(camera, depthBuffer); //render depth
    render(camera, stencilBuffer); //render stencil
    render(ligthCamera, shadowBuffer);//render shadowMap
    super.sendCameraMatrixTo(mainMaterial); 
    super.updateMaterialForShadowMap(mainMaterial); 
    render(camera, diffuseBuffer);//render diffuse
    super.bindTextureToShader(postProcessCompositing, "depthMap", depthBuffer);
    super.bindCameraLightInformation();
  }

  @Override public void render(Camera cam, PGraphics buffer)
  {
    buffer.beginDraw();
    background(buffer, color(255));

    //Camera
    cam.displayCamera(buffer);

    //environment & lighting
    if (buffer == diffuseBuffer)
    {
      //buffer.noLights();
      //cubemap.displayDynamicCubeMap(buffer);
      buffer.lights();
      fillLight.displayLight(buffer);
      keyLight.displayLight(buffer);
    }


    buffer.resetShader();

    if (buffer == diffuseBuffer)
    {
      if (gizmo)
      {
        //axis & frustum
        axis.drawAxis("RVB", buffer);
        fillLight.showDebugLight(buffer);
        keyLight.showDebugLight(buffer);
      }
    }

    buffer.endDraw();
  }

  //---------------------
  // DEBUG METHODS
  //---------------------
  @Override public void showSceneElements(float w_, float h_, float s_)
  {
  }
}