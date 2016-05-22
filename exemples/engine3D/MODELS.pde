import java.awt.Color; //for HSB to RGB Conversion
import java.nio.IntBuffer; //for CubeMap

// ------------------------------------
// ------------------------------------
//               MODELS
// ------------------------------------
// ------------------------------------

// ------------------------------------
// Simple Class 3D Engine
// ------------------------------------

class Engine3D
{
  //Coordinate System
  public PVector originCoordinate = new PVector(0, 0, 0);

  //Render Buffer
  public int bufferWidth = 1920;
  public int bufferHeight = 1080;
  public PGraphics diffuseBuffer;
  public PGraphics depthBuffer;
  public PGraphics shadowBuffer;
  public PGraphics stencilBuffer;

  //SHADER
  public PShader mainMaterial;
  public PShader bit16Unpacker;
  public PShader depthMap;
  public PShader shadowMap;
  public PShader stencilMap;
  public PShader postProcessCompositing;

  //3D Component
  public Camera camera;
  public Axis3D axis;
  public DirectionLight fillLight, keyLight;
  public CubeMap cubemap;

  //Gizmo
  public boolean gizmo;
  public boolean debug = true;

  Engine3D()
  {
    this.initEngine();
  }

  Engine3D(int width_, int height_)
  {
    this.initEngine(width_, height_);
  }

  //----------------
  // INIT METHODS
  //----------------
  private void initEngine()
  {
    printState("Engine");
    this.initCameraAndFrustum(new PVector(0, 0, 500), 35, 1920, 1080, 100.0, 4500.0, true);
    this.initAxis();
    this.initLights();
    this.initCubeMap();
    this.initShader();
    this.initBuffer(bufferWidth, bufferHeight);
    printState("Engine has been initialized");
  }

  private void initEngine(int width_, int height_)
  {
    printState("Engine");
    this.initCameraAndFrustum(new PVector(0, 0, 500), 35, width_, height_, 100.0, 4500.0, true);
    this.initAxis();
    this.initLights();
    this.initCubeMap();
    this.initShader();
    this.initBuffer(width_, height_);
    printState("Engine has been initialized");
  }

  private void initBuffer(int width_, int height_)
  {
    printState("\tInit Buffers");
    bufferWidth = width_;
    bufferHeight = height_;
    printState("\t\tInit Diffuse");
    diffuseBuffer = createGraphics(bufferWidth, bufferHeight, P3D);
    printState("\t\tInit Depth");
    depthBuffer = createGraphics(bufferWidth, bufferHeight, P3D);
    printState("\t\tInit Shadow");
    shadowBuffer = createGraphics(bufferWidth * 2, bufferHeight * 2, P3D); 
    printState("\t\tInit Stencil"); 
    stencilBuffer = createGraphics(bufferWidth, bufferHeight, P3D);

    shadowBuffer.beginDraw();
    shadowBuffer.noStroke();
    shadowBuffer.shader(shadowMap);
    //shadowBuffer.ortho(-512, 512, -512, 512, camera.frustum.getNear(), camera.frustum.getFar()); // Setup orthogonal view matrix  for the directional light
    //shadowBuffer.perspective(camera.fovy, camera.aspectRatio, camera.zNear, camera.zFar);
    shadowBuffer.endDraw();
  }

  private void initShader()
  {
    printState("\tLoad Shaders");
    mainMaterial = loadShader("shaders/phongLight_GammaCorrection_frag.glsl", "shaders/phongLight_GammaCorrection_vert.glsl");
    bit16Unpacker = loadShader("shaders/unpack16BitsMap_frag.glsl");
    depthMap = loadShader("shaders/depth_frag.glsl", "shaders/depth_vert.glsl");
    shadowMap = loadShader("shaders/shadowMap_frag.glsl", "shaders/shadowMap_vert.glsl");
    stencilMap = loadShader("shaders/stencil_frag.glsl", "shaders/stencil_vert.glsl");
    postProcessCompositing = loadShader("shaders/PP_Compositing.glsl");
  }

  public void initCameraAndFrustum(PVector location_, float fov_, float width_, float height_, float near_, float far_, boolean perspective_)
  {
    printState("\tInit Frustum");
    camera = new Camera(location_, fov_, (float) width_, (float) height_, near_, far_, perspective_);
  }

  public void initAxis()
  {
    printState("\tInit Axis");
    axis = new Axis3D(originCoordinate, 50);
  }

  public void initLights()
  {
    printState("\tInit Lights");
    //define distance

    //Define axis to lights (the two lights are on the same axis)
    //PVector axisKey = MathsVector.computeRodrigueRotation(new PVector(0, 1, 0), new PVector(0, 0, 1), radians(60)); 
    //PVector axisFill = MathsVector.computeRodrigueRotation(new PVector(0, 1, 0), new PVector(0, 0, 1), radians(-30));

    //Define rabdom axis to lights
    PVector axisFill = MathsVector.computeRodrigueRotation(new PVector(random(1), 1.0, 0.0), new PVector(0, 0, 1), radians(40));
    PVector axisKey = MathsVector.computeRodrigueRotation(new PVector(random(1), 1.0, 0.0), new PVector(0, 0, 1), radians(-45)); 

    axisFill.mult(-1);
    axisKey.mult(-1);


    //define lights color
    PVector fillColor = new PVector(255, 254, 250);// - Yellow Sun;
    PVector keyColor = new PVector(209, 237, 255);// - Blue Sun;


    //define lights falloff (Only with PointLights)
    //PVector fillFallOff = new PVector(1.0, 0.001, 0.0); 
    //PVector keyFallOff = new PVector(2.0, 0.001, 0.0);

    fillLight = new DirectionLight(0, axisFill, fillColor, 1500);
    keyLight = new DirectionLight(1, axisKey, keyColor, 1500);
  }

  public void initLights(float angleF, float angleK, PVector axisF, PVector axisK)
  {
    printState("\tInit Lights");
    //Define axis to lights (the two lights are on the same axis)
    // PVector axisKey = MathsVector.computeRodrigueRotation(new PVector(0, 1, 0), new PVector(0, 0, 1), radians(60)); 
    //PVector axisFill = MathsVector.computeRodrigueRotation(new PVector(0, 1, 0), new PVector(0, 0, 1), radians(-30));

    //Define rabdom axis to lights
    PVector axisFill = MathsVector.computeRodrigueRotation(axisF, new PVector(0, 0, 1), angleF);
    PVector axisKey = MathsVector.computeRodrigueRotation(axisK, new PVector(0, 0, 1), angleK); 

    axisFill.mult(-1);
    axisKey.mult(-1);


    //define lights color
    PVector fillColor = new PVector(254, 247, 219);//254, 247, 219 - Yellow Sun;
    PVector keyColor = new PVector(217, 217, 255);//217, 217, 255);//217, 217, 255 - Blue Sun;

    //define lights falloff (Only with PointLights)
    //PVector fillFallOff = new PVector(1.0, 0.001, 0.0);
    //PVector keyFallOff = new PVector(1.0, 0.001, 0.0);

    fillLight = new DirectionLight(0, axisFill, fillColor);
    keyLight = new DirectionLight(1, axisKey, keyColor);
  }

  private void initCubeMap()
  {
    printState("\tInit CubeMap");
    cubemap = new CubeMap(0.25);
  }


  //----------------
  // RUN & RENDER METHODS
  //----------------
  public void run()
  {
    // this.render();
  }

  public void renderPasses()
  {
  }

  public void sendCameraMatrixTo(PShader sh)
  {
    cubemap.computeCamMatrix(sh);
  }

  public void render(Camera cam, PGraphics buffer)
  {
  }

  public void material(PGraphics buffer)
  {
    if (buffer == diffuseBuffer)
    {
      buffer.shader(mainMaterial);
    } else if (buffer == shadowBuffer)
    {
      buffer.shader(shadowMap);
    } else if (buffer == depthBuffer)
    {
      buffer.shader(depthMap);
    } else if (buffer == stencilBuffer)
    {
      buffer.shader(stencilMap);
      buffer.background(0);
    }
  }

  private void material(PGraphics buffer, PShader material)
  {
    if (buffer == diffuseBuffer)
    {
      buffer.shader(material);
    } else if (buffer == shadowBuffer)
    {
      buffer.shader(shadowMap);
    } else if (buffer == depthBuffer)
    {
      buffer.shader(depthMap);
    } else if (buffer == stencilBuffer)
    {
      buffer.shader(stencilMap);
      buffer.background(0);
    }
  }

  public void updateMaterialForShadowMap(PShader mat) {

    // Bias matrix to move homogeneous shadowCoords into the UV texture space
    PMatrix3D shadowTransform = new PMatrix3D(
      0.5, 0.0, 0.0, 0.5, 
      0.0, 0.5, 0.0, 0.5, 
      0.0, 0.0, 0.5, 0.5, 
      0.0, 0.0, 0.0, 1.0
      );

    // Apply project modelview matrix from the shadow pass (light direction)
    shadowTransform.apply(((PGraphicsOpenGL)shadowBuffer).projmodelview);

    // Apply the inverted modelview matrix from the default pass to get the original vertex
    // positions inside the shader. This is needed because Processing is pre-multiplying
    // the vertices by the modelview matrix (for better performance).
    PMatrix3D modelviewInv = ((PGraphicsOpenGL)diffuseBuffer).modelviewInv;
    shadowTransform.apply(modelviewInv);

    // Convert column-minor PMatrix to column-major GLMatrix and send it to the shader.
    // PShader.set(String, PMatrix3D) doesn't convert the matrix for some reason.
    mat.set("shadowTransform", new PMatrix3D(
      shadowTransform.m00, shadowTransform.m10, shadowTransform.m20, shadowTransform.m30, 
      shadowTransform.m01, shadowTransform.m11, shadowTransform.m21, shadowTransform.m31, 
      shadowTransform.m02, shadowTransform.m12, shadowTransform.m22, shadowTransform.m32, 
      shadowTransform.m03, shadowTransform.m13, shadowTransform.m23, shadowTransform.m33
      ));

    // Calculate light direction normal, which is the transpose of the inverse of the
    // modelview matrix and send it to the default shader.
    PVector lightDir = fillLight.location;

    float lightNormalX = lightDir.x * modelviewInv.m00 + lightDir.y * modelviewInv.m10 + lightDir.z * modelviewInv.m20;
    float lightNormalY = lightDir.x * modelviewInv.m01 + lightDir.y * modelviewInv.m11 + lightDir.z * modelviewInv.m21;
    float lightNormalZ = lightDir.x * modelviewInv.m02 + lightDir.y * modelviewInv.m12 + lightDir.z * modelviewInv.m22;
    float normalLength = sqrt(lightNormalX * lightNormalX + lightNormalY * lightNormalY + lightNormalZ * lightNormalZ);
    mat.set("lightDirection", lightNormalX / -normalLength, lightNormalY / -normalLength, lightNormalZ / -normalLength);

    // Send the shadowmap to the default shader
    mat.set("shadowMap", shadowBuffer);
  }

  void bindTextureToShader(PShader sh, String varying, PImage tex)
  {
    sh.set(varying, tex);
  }

  void background(PGraphics buffer, color c)
  {
    if (buffer != diffuseBuffer)
    {
      buffer.background(255);
    } else {
      buffer.background(c);
    }
  }

  //----------------
  //Post Process
  //----------------
  void bindCameraLightInformation()
  {
    PVector viewDir = PVector.sub(camera.target, camera.location).normalize();
    PVector lightDir = fillLight.location.copy().normalize();
    postProcessCompositing.set("eyeDirection", viewDir);
    postProcessCompositing.set("lightDirection", lightDir);
  }
  void renderPostProcess()
  {
    shader(postProcessCompositing);
    image(diffuseBuffer, 0, 0);
  }

  void renderPostProcess(PGraphics buffer, float x, float y)
  {
    buffer.shader(postProcessCompositing);
    buffer.image(diffuseBuffer, x, y);
    buffer.resetShader();
  }

  //-----------------
  // 3D COMPONENT
  //-----------------


  //-----------------
  // DEBUG
  //-----------------
  public void showDebug(float x, float y, float scale, PVector orientation)
  {
    //Passes
    float w = engine.depthBuffer.width * scale;
    float h = engine.depthBuffer.height * scale;
    float headerWidth = w * 4;
    float headerHeight = 20;
    if (orientation.x == 1)
    {
      x = x - headerWidth;
    }
    if (orientation.y == 1)
    {
      y = y - (h + headerHeight);
    }

    pushStyle();
    pushMatrix();
    fill(20);
    noStroke();
    rect(x, y, headerWidth, headerHeight);
    fill(255, 255, 0);
    textAlign(LEFT, TOP);
    textSize(10);
    text("Diffuse Buffer", x + 5, y+3);
    text("Stencil Buffer", x + w + 5, y+3);
    text("Depth Buffer", x + w * 2 + 5, y+3);
    text("Shadow Map Buffer", x + w * 3 + 5, y+3);

    image(engine.diffuseBuffer, x, y + headerHeight, w, h);
    image(engine.stencilBuffer, x + w, y + headerHeight, w, h);
    shader(engine.bit16Unpacker);
    image(engine.depthBuffer, x + w * 2, y + headerHeight, w, h);
    image(engine.shadowBuffer, x + w * 3, y + headerHeight, w, h);
    resetShader();
    stroke(255, 255, 0);
    noFill();
    rect(x, y, w, h + headerHeight);
    rect(x + w, y, w, h + headerHeight);
    rect(x + w * 2, y, w, h + headerHeight);
    rect(x + w * 3, y, w, h + headerHeight);
    popMatrix();
    pushStyle();
  }

  public void showDebugMap(float x_, float y_, float w_, float h_)
  {
    pushMatrix();
    pushStyle();
    translate(x_, y_);
    stroke(255, 255, 0);
    fill(0);
    rectMode(CORNER);
    rect(0, 0, w_, h_);
    stroke(0, 0, 255);
    line(w_/2, 0, w_/2, h_);
    stroke(255, 0, 0);
    line(0, h_/2, w_, h_/2);    
    pushMatrix();
    pushStyle();
    showCameraOnMap(w_, h_, 25);
    showSceneElements(w_, h_, 25);
    popStyle();
    popMatrix();
    popStyle();
    popMatrix();
  }

  private void showCameraOnMap(float w_, float h_, float s_)
  {
    float ex = norm(camera.location.x, -camera.zFar, camera.zFar) * w_;
    float ey = norm(camera.location.z, -camera.zFar, camera.zFar) * h_;
    float tx = norm(camera.target.x, -camera.zFar, camera.zFar) * w_;
    float ty = norm(camera.target.z, -camera.zFar, camera.zFar) * h_;
    PVector et = PVector.sub(new PVector(ex, ey), new PVector(tx, ty));
    PVector net = et.normalize();
    PVector netPos = net.copy();
    netPos.mult(s_);
    netPos.rotate(PI + QUARTER_PI - radians(20));
    netPos.add(new PVector(ex, ey));
    PVector netNeg = net.copy();
    netNeg.mult(s_);
    netNeg.rotate(PI -QUARTER_PI + radians(20));
    netNeg.add(new PVector(ex, ey));
    net.mult(s_ * -1);
    net.add(new PVector(ex, ey));

    noFill();
    stroke(255, 255, 0);
    triangle(ex, ey, netPos.x, netPos.y, netNeg.x, netNeg.y);
    line(ex, ey, net.x, net.y);
  }

  public void showSceneElements(float w_, float h_, float s_)
  {
  }

  public void printState(String txt)
  {
    if (debug)
    {
      println(txt);
    }
  }
}


//-----------------------------
// 3D Component
//-----------------------------
class Frustum
{  
  //frustum data
  private PVector farTopLeft ;
  private PVector farTopRight ;
  private PVector farBottomLeft ;
  private PVector farBottomRight ;
  private PVector nearTopLeft ;
  private PVector nearTopRight ;
  private PVector nearBottomLeft ;
  private PVector nearBottomRight ;

  private float fov;
  private float viewRatio;
  private float nearDistance;
  private float farDistance;
  public PVector eyePosition;
  private PVector eyeForward;

  Frustum()
  {
    this.initFrustum(35, (float) 1920 / (float) 1080, new PVector(0, 0, 0), new PVector(0, 0, 1), 10, 4500);
  }

  Frustum(float aperture_, float viewRatio_, PVector eyePosition_, PVector eyeForward_, float nearDistance_, float farDistance_)
  {
    this.initFrustum(aperture_, viewRatio_, eyePosition_, eyeForward_, nearDistance_, farDistance_);
  }

  private void initFrustum(float aperture_, float viewRatio_, PVector eyePosition_, PVector eyeForward_, float nearDistance_, float farDistance_)
  {
    fov = radians(aperture_);
    viewRatio = viewRatio_;
    nearDistance = nearDistance_;
    farDistance = farDistance_;
    eyePosition = eyePosition_.copy();
    eyeForward = eyeForward_.copy();

    computeFrustum(eyePosition, eyeForward, new PVector(0, -1, 0), new PVector(1, 0, 0));
  }

  public void computeFrustum(PVector eyePosition_, PVector eyeForward_, PVector eyeUp_, PVector eyeRight_)
  {
    eyePosition = eyePosition_.copy();
    eyeForward = eyeForward_.copy();

    PVector nearCenter = eyePosition.copy().sub(eyeForward.copy().mult(nearDistance));
    PVector farCenter = eyePosition.copy().sub(eyeForward.copy().mult(farDistance));

    float nearHeight = 2 * tan(fov / 2) * nearDistance;
    float farHeight = 2 *  tan(fov / 2) * farDistance;
    float nearWidth = nearHeight * viewRatio;
    float farWidth = farHeight * viewRatio;

    farTopLeft = farCenter.copy().add(eyeUp_.copy().mult(farHeight * 0.5).sub(eyeRight_.copy().mult(farWidth*0.5)));
    farTopRight = farCenter.copy().add(eyeUp_.copy().mult(farHeight * 0.5).add(eyeRight_.copy().mult(farWidth*0.5)));
    farBottomLeft = farCenter.copy().sub(eyeUp_.copy().mult(farHeight * 0.5).sub(eyeRight_.copy().mult(farWidth*0.5)));
    farBottomRight = farCenter.copy().sub(eyeUp_.copy().mult(farHeight * 0.5).add(eyeRight_.copy().mult(farWidth*0.5)));

    nearTopLeft = nearCenter.copy().add(eyeUp_.copy().mult(nearHeight * 0.5).sub(eyeRight_.copy().mult(nearWidth*0.5)));
    nearTopRight = nearCenter.copy().add(eyeUp_.copy().mult(nearHeight * 0.5).add(eyeRight_.copy().mult(nearWidth*0.5)));
    nearBottomLeft = nearCenter.copy().sub(eyeUp_.copy().mult(nearHeight * 0.5).sub(eyeRight_.copy().mult(nearWidth*0.5)));
    nearBottomRight = nearCenter.copy().sub(eyeUp_.copy().mult(nearHeight * 0.5).add(eyeRight_.copy().mult(nearWidth*0.5)));
  }

  public void displayFrustum()
  {
    pushStyle();
    noFill();
    stroke(255, 255, 0);
    line(eyePosition.x, eyePosition.y, eyePosition.z, farTopLeft.x, farTopLeft.y, farTopLeft.z);
    line(eyePosition.x, eyePosition.y, eyePosition.z, farTopRight.x, farTopRight.y, farTopRight.z);
    line(eyePosition.x, eyePosition.y, eyePosition.z, farBottomLeft.x, farBottomLeft.y, farBottomLeft.z);
    line(eyePosition.x, eyePosition.y, eyePosition.z, farBottomRight.x, farBottomRight.y, farBottomRight.z);

    beginShape(QUAD);
    vertex(farTopLeft.x, farTopLeft.y, farTopLeft.z);
    vertex(farTopRight.x, farTopRight.y, farTopRight.z);
    vertex(nearTopRight.x, nearTopRight.y, nearTopRight.z);
    vertex(nearTopLeft.x, nearTopLeft.y, nearTopLeft.z);

    vertex(farTopRight.x, farTopRight.y, farTopRight.z);
    vertex(farBottomLeft.x, farBottomLeft.y, farBottomLeft.z);
    vertex(nearBottomLeft.x, nearBottomLeft.y, nearBottomLeft.z);
    vertex(nearTopRight.x, nearTopRight.y, nearTopRight.z);

    vertex(farBottomLeft.x, farBottomLeft.y, farBottomLeft.z);
    vertex(farBottomRight.x, farBottomRight.y, farBottomRight.z);
    vertex(nearBottomRight.x, nearBottomRight.y, nearBottomRight.z);
    vertex(nearBottomLeft.x, nearBottomLeft.y, nearBottomLeft.z);

    vertex(farBottomRight.x, farBottomRight.y, farBottomRight.z);
    vertex(farTopLeft.x, farTopLeft.y, farTopLeft.z);
    vertex(nearTopLeft.x, nearTopLeft.y, nearTopLeft.z);
    vertex(nearBottomRight.x, nearBottomRight.y, nearBottomRight.z);
    endShape();

    popStyle();
  }

  public void displayFrustum(PGraphics buffer)
  {
    buffer.pushStyle();
    buffer.noFill();
    buffer.stroke(255, 255, 0);
    buffer.line(eyePosition.x, eyePosition.y, eyePosition.z, farTopLeft.x, farTopLeft.y, farTopLeft.z);
    buffer.line(eyePosition.x, eyePosition.y, eyePosition.z, farTopRight.x, farTopRight.y, farTopRight.z);
    buffer.line(eyePosition.x, eyePosition.y, eyePosition.z, farBottomLeft.x, farBottomLeft.y, farBottomLeft.z);
    buffer.line(eyePosition.x, eyePosition.y, eyePosition.z, farBottomRight.x, farBottomRight.y, farBottomRight.z);

    buffer.beginShape(QUAD);
    buffer.vertex(farTopLeft.x, farTopLeft.y, farTopLeft.z);
    buffer.vertex(farTopRight.x, farTopRight.y, farTopRight.z);
    buffer.vertex(nearTopRight.x, nearTopRight.y, nearTopRight.z);
    buffer.vertex(nearTopLeft.x, nearTopLeft.y, nearTopLeft.z);

    buffer.vertex(farTopRight.x, farTopRight.y, farTopRight.z);
    buffer.vertex(farBottomLeft.x, farBottomLeft.y, farBottomLeft.z);
    buffer.vertex(nearBottomLeft.x, nearBottomLeft.y, nearBottomLeft.z);
    buffer.vertex(nearTopRight.x, nearTopRight.y, nearTopRight.z);

    buffer.vertex(farBottomLeft.x, farBottomLeft.y, farBottomLeft.z);
    buffer.vertex(farBottomRight.x, farBottomRight.y, farBottomRight.z);
    buffer.vertex(nearBottomRight.x, nearBottomRight.y, nearBottomRight.z);
    buffer.vertex(nearBottomLeft.x, nearBottomLeft.y, nearBottomLeft.z);

    buffer.vertex(farBottomRight.x, farBottomRight.y, farBottomRight.z);
    buffer.vertex(farTopLeft.x, farTopLeft.y, farTopLeft.z);
    buffer.vertex(nearTopLeft.x, nearTopLeft.y, nearTopLeft.z);
    buffer.vertex(nearBottomRight.x, nearBottomRight.y, nearBottomRight.z);
    buffer.endShape();

    buffer.popStyle();
  }

  public float getNear()
  {
    return nearDistance;
  }

  public float getFar()
  {
    return farDistance;
  }

  public PVector[] getFrustum()
  {
    PVector[] frustum = {farTopLeft, farTopRight, farBottomLeft, farBottomRight, nearTopLeft, nearTopRight, nearBottomLeft, nearBottomRight};
    return frustum;
  }
}

//-----------------------------------
// Gizmo
//-----------------------------------
class Axis3D
{
  private PVector origin;
  private PVector axis;
  private float axisLength;
  private float phi = 0;

  Axis3D()
  {
    this.initAxis3D(new PVector(0, 0, 0), new PVector(1, 1, 1), 10);
  }

  Axis3D(float axisLength_)
  {
    this.initAxis3D(new PVector(0, 0, 0), new PVector(1, 1, 1), axisLength_);
  }

  Axis3D(PVector origin_)
  {
    this.initAxis3D(origin_, new PVector(1, 1, 1), 10);
  }

  Axis3D(PVector origin_, float axisLength_)
  {
    this.initAxis3D(origin_, new PVector(1, 1, 1), axisLength_);
  }

  Axis3D(PVector origin_, PVector axis_)
  {
    this.initAxis3D(origin_, axis_, 10);
  }

  Axis3D(PVector origin_, PVector axis_, float axisLength_)
  {
    this.initAxis3D(origin_, axis_, axisLength_);
  }


  private void initAxis3D(PVector origin_, PVector axis_, float axisLength_)
  {
    origin = origin_.copy();
    axis = axis_.copy();
    axisLength = axisLength_;
  }

  public void drawAxis(String colorMode)
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
    pushMatrix();
    translate(origin.x, origin.y, origin.z);
    rotate(phi, axis.x, axis.y, axis.z);
    strokeWeight(1);
    //x-axis
    stroke(xAxis); 
    line(0, 0, 0, axisLength, 0, 0);
    //y-axis
    stroke(yAxis); 
    line(0, 0, 0, 0, axisLength, 0);
    //z-axis
    stroke(zAxis); 
    line(0, 0, 0, 0, 0, axisLength);
    popMatrix();
    popStyle();
  }

  public void drawAxis(String colorMode, PGraphics buffer)
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
    buffer.translate(origin.x, origin.y, origin.z);
    buffer.rotate(phi, axis.x, axis.y, axis.z);
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

  public void updateAxis(PVector eye, PVector target)
  {
    PVector v0tov1 = PVector.sub(target, eye);

    //compute angle between two vectors
    PVector v0 = new PVector(0, 1, 0);
    PVector v1 = v0tov1.copy().normalize();

    float v0Dotv1 = PVector.dot(v0, v1);
    float phi_ = acos(v0Dotv1);
    PVector axis_ = v0.cross(v1);

    origin = eye.copy();
    axis = axis_;
    phi = phi_;
  }
}

//-----------------------------
// lights Component
//-----------------------------
class Light
{
  public int type; //0 : fill light, 1 : key light, 2 : rim light, 3 : other 
  public PVector location;
  public PVector rgb;

  public float x, y, z, r, g, b;

  Light(PVector loc_)
  {
    this.initLight(0, loc_, new PVector(255, 255, 255));
  }

  Light(PVector loc_, PVector rgb_)
  {
    this.initLight(0, loc_, rgb_);
  }

  Light(int type_, PVector loc_, PVector rgb_)
  {
    this.initLight(type_, loc_, rgb_);
  }

  private void initLight(int type_, PVector loc_, PVector rgb_)
  {
    type = type_;
    location = loc_.copy();
    rgb = rgb_.copy();

    x = location.x;
    y = location.y;
    z = location.z;

    r = rgb.x;
    g = rgb.y;
    b = rgb.z;
  }

  //METHODS
  public void displayLight()
  {
  }

  public void displayLight(PGraphics buffer)
  {
  }

  public void showDebugLight()
  {
    pushStyle();
    pushMatrix();
    translate(location.x, location.y, location.z);
    strokeWeight(10);
    stroke(rgb.x, rgb.y, rgb.z);
    point(0, 0, 0);
    popMatrix();
    popStyle();
  }

  public void showDebugLight(PGraphics buffer)
  {
    buffer.pushStyle();
    buffer.pushMatrix();
    buffer.translate(location.x, location.y, location.z);
    buffer.strokeWeight(10);
    buffer.stroke(rgb.x, rgb.y, rgb.z);
    buffer.point(0, 0, 0);
    buffer.popMatrix();
    buffer.popStyle();
  }

  public void rotateLightAround(PVector target, PVector axis, float angle, float distance)
  {
    PVector nl = PVector.add(target, location);
    PVector newPosition = MathsVector.computeRodrigueRotation(axis, nl, angle);
    newPosition.mult(distance);
    newPosition.add(target);
    this.setPosition(newPosition);
  }

  //set
  public void setPosition(PVector pos_)
  {
    location = pos_.copy();
  }

  public void setColor(PVector rgb_)
  {
    rgb = rgb_.copy();
  }

  //get
  public PVector getLightPosition()
  {
    return location.copy();
  }

  public PVector getLightColor()
  {
    return rgb.copy();
  }

  public int getLightType()
  {
    return type;
  }
}

class PointLight extends Light
{
  public PVector falloff;

  PointLight(PVector loc_)
  {
    super(loc_);
    super.initLight(0, loc_, new PVector(255, 255, 255));
    this.initFallOff(new PVector(1, 0, 0));
  }

  PointLight(PVector loc_, PVector rgb_)
  {
    super(loc_, rgb_);
    super.initLight(0, loc_, rgb_);
    this.initFallOff(new PVector(1, 0, 0));
  }


  PointLight(PVector loc_, PVector rgb_, PVector falloff_)
  {
    super(loc_, rgb_);
    super.initLight(0, loc_, rgb_);
    this.initFallOff(falloff_);
  }

  PointLight(int type_, PVector loc_, PVector rgb_)
  {
    super(type_, loc_, rgb_);
    super.initLight(type_, loc_, rgb_);
    this.initFallOff(new PVector(1, 0, 0));
  }

  PointLight(int type_, PVector loc_, PVector rgb_, PVector falloff_)
  {
    super(type_, loc_, rgb_);
    super.initLight(type_, loc_, rgb_);
    this.initFallOff(falloff_);
  }

  private void initFallOff(PVector falloff_)
  {
    falloff = falloff_.copy();
  }

  @Override public void displayLight()
  {
    if (falloff != null)
    {
      lightFalloff(falloff.x, falloff.y, falloff.z);
    }
    pointLight(rgb.x, rgb.y, rgb.z, location.x, location.y, location.z);
  }

  @Override public void displayLight(PGraphics buffer)
  {
    if (falloff != null)
    {
      buffer.lightFalloff(falloff.x, falloff.y, falloff.z);
    }
    buffer.pointLight(rgb.x, rgb.y, rgb.z, location.x, location.y, location.z);
  }

  public void setFallOff(PVector v)
  {
    falloff = v.copy();
  }

  public PVector getFallOff()
  {
    return falloff;
  }
}

class DirectionLight extends Light
{
  private PVector debugLine;
  private float debugLineLength;
  private PVector skyPosition;
  private float skyDistance;

  DirectionLight(PVector loc_)
  {
    super(loc_);
    super.initLight(0, loc_, new PVector(255, 255, 255));
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, float skyDistance_)
  {
    super(loc_);
    super.initLight(0, loc_, new PVector(255, 255, 255));
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, PVector rgb_)
  {
    super(loc_, rgb_);
    super.initLight(0, loc_, rgb_);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }

  DirectionLight(PVector loc_, PVector rgb_, float skyDistance_)
  {
    super(loc_, rgb_);
    super.initLight(0, loc_, rgb_);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  DirectionLight(int type_, PVector loc_, PVector rgb_)
  {
    super(type_, loc_, rgb_);
    super.initLight(type_, loc_, rgb_);
    this.initSkyPosition(1000);
    this.initDebugLine();
  }


  DirectionLight(int type_, PVector loc_, PVector rgb_, float skyDistance_)
  {
    super(type_, loc_, rgb_);
    super.initLight(type_, loc_, rgb_);
    this.initSkyPosition(skyDistance_);
    this.initDebugLine();
  }

  private void initSkyPosition(float skyDistance_)
  {

    skyPosition = location.copy();
    skyDistance = skyDistance_;
    skyPosition.mult(skyDistance * -1);
  }

  private void initDebugLine()
  {
    debugLine = location.copy();
    debugLineLength = 100;
    debugLine.mult(debugLineLength);
  }

  @Override public void displayLight()
  {
    directionalLight(rgb.x, rgb.y, rgb.z, location.x, location.y, location.z);
  }

  @Override public void displayLight(PGraphics buffer)
  {
    buffer.directionalLight(rgb.x, rgb.y, rgb.z, location.x, location.y, location.z);
  }

  @Override public void showDebugLight()
  {
    pushStyle();
    strokeWeight(10);
    stroke(rgb.x, rgb.y, rgb.z);
    point(0, 0, 0);
    strokeWeight(1);
    line(0, 0, 0, debugLine.x, debugLine.y, debugLine.z);
    popStyle();
  }

  @Override public void showDebugLight(PGraphics buffer)
  {
    buffer.pushStyle();
    buffer.strokeWeight(10);
    buffer.stroke(rgb.x, rgb.y, rgb.z);
    buffer.point(0, 0, 0);
    buffer.strokeWeight(1);
    buffer.line(0, 0, 0, debugLine.x, debugLine.y, debugLine.z);
    buffer.stroke(rgb.x, rgb.y, rgb.z);
    buffer.line(0, 0, 0, skyPosition.x, skyPosition.y, skyPosition.z);
    buffer.popStyle();
  }

  public void rotateLightAround(PVector axis, float angle)
  {
    PVector nl = PVector.add(new PVector(), location);
    PVector newPosition = MathsVector.computeRodrigueRotation(axis, nl, angle);
    super.setPosition(newPosition);
    this.initSkyPosition(skyDistance);
    this.initDebugLine();
  }

  public void setSkyPosition(PVector sk)
  {
    skyPosition = sk.copy();
  }

  public void setNewAxis(PVector l)
  {    
    super.initLight(type, l, rgb);
    this.initSkyPosition(skyDistance);
    this.initDebugLine();
  }

  public PVector getSkyPosition()
  {
    return skyPosition;
  }
}

//------------------------------------------
//
// Cube map for environment Mapping
//
//------------------------------------------


class CubeMap
{

  //CubeMap Buffer Variables
  public int location;
  private float smoothScale;
  public IntBuffer envMapTextureID; //Target Buffer
  public PMatrix3D cameraMatrix; //Hack for CameraMatrix

  //List of Textures
  private String path = "cubeMapTex/02_CityDay/";
  private String[] textureNames = { 
    "posx.jpg", "negx.jpg", "posy.jpg", "negy.jpg", "posz.jpg", "negz.jpg"
  };
  private PImage[] textures;
  private PImage[] originaltextures;

  //cubeMap obj
  private  PShape cubeMapObj; 
  private PGraphics envMapDynamic; //CubeMap Debug

  private PImage inputReference[];

  CubeMap()
  {
    initCubMap(1.0);
  }

  CubeMap(float smoothScale_)
  {
    initCubMap(smoothScale_);
  }

  private void initCubMap(float smoothScale_)
  {
    //shader
    smoothScale = smoothScale_;
    cameraMatrix = new PMatrix3D();
    initTextureList();
    generateCubeMap();

    cubeMapObj = texturedCube(2500);
  }

  private void initTextureList()
  {
    textures = new PImage[textureNames.length];
    originaltextures = new PImage[textureNames.length]; 
    inputReference = new PImage[textureNames.length];
    for (int i=0; i<textures.length; i++) {
      textures[i] = loadImage(path+textureNames[i]);
      originaltextures[i] = loadImage(path+textureNames[i]);
      textures[i].resize(int(textures[i].width * smoothScale), int(textures[i].height * smoothScale));
      ImageComputation.fastblur(textures[i], (int)((1 - smoothScale) * 10));
      inputReference[i] = textures[i].get();
    }
    envMapDynamic = createGraphics(textures[0].width * 4, textures[0].height * 3, P3D);
    computeDynamicEnvironmentMap();
  }

  /*-------------CUBEMAP--------------------*/
  private void generateCubeMap() {
    PGL pgl = beginPGL();
    // create the OpenGL-based cubeMap
    location = 1;
    envMapTextureID = IntBuffer.allocate(location);
    pgl.genTextures(location, envMapTextureID);
    pgl.activeTexture(PGL.TEXTURE1);
    pgl.enable(PGL.TEXTURE_CUBE_MAP);  
    pgl.bindTexture(PGL.TEXTURE_CUBE_MAP, envMapTextureID.get(0));
    pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_WRAP_S, PGL.CLAMP_TO_EDGE);
    pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_WRAP_T, PGL.CLAMP_TO_EDGE);
    pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_WRAP_R, PGL.CLAMP_TO_EDGE);
    pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_MIN_FILTER, PGL.LINEAR);
    pgl.texParameteri(PGL.TEXTURE_CUBE_MAP, PGL.TEXTURE_MAG_FILTER, PGL.LINEAR);

    // put the textures in the cubeMap
    for (int i=0; i<textures.length; i++) {
      int w = textures[i].width;
      int h = textures[i].height;
      textures[i].loadPixels();
      int[] pix = textures[i].pixels;
      int[] rgbaPixels = new int[pix.length];
      for (int j = 0; j< pix.length; j++) {
        int pixel = pix[j];
        rgbaPixels[j] = 0xFF000000 | ((pixel & 0xFF) << 16) | ((pixel & 0xFF0000) >> 16) | (pixel & 0x0000FF00);
      }
      pgl.texImage2D(PGL.TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, PGL.RGBA, w, h, 0, PGL.RGBA, PGL.UNSIGNED_BYTE, java.nio.IntBuffer.wrap(rgbaPixels));
    }
    endPGL();
    flush();
  }

  public void updateCubeMap(int index) {
    //reload images
    PImage texCube = inputReference[index].get();

    PGL pgl = beginPGL();
    pgl.bindTexture(PGL.TEXTURE_CUBE_MAP, envMapTextureID.get(0));
    // put the textures in the cubeMap
    int w = texCube.width;
    int h = texCube.height;
    texCube.loadPixels();
    int[] pix = texCube.pixels;
    int[] rgbaPixels = new int[pix.length];
    for (int j = 0; j< pix.length; j++) {
      int pixel = pix[j];
      rgbaPixels[j] = 0xFF000000 | ((pixel & 0xFF) << 16) | ((pixel & 0xFF0000) >> 16) | (pixel & 0x0000FF00);
    }
    pgl.texImage2D(PGL.TEXTURE_CUBE_MAP_POSITIVE_X + index, 0, PGL.RGBA, w, h, 0, PGL.RGBA, PGL.UNSIGNED_BYTE, java.nio.IntBuffer.wrap(rgbaPixels));
    //void glTexImage2D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border,  GLenum format, GLenum type, const GLvoid * data);
    endPGL();
    flush();
  }

  private PShape texturedCube(float scale) {
    PShape cube = createShape(GROUP);
    PShape posz = createShape();
    PShape negz = createShape();
    PShape posx = createShape();
    PShape negx = createShape();
    PShape posy = createShape();
    PShape negy = createShape();

    // +Z "front" face
    posz.beginShape(QUADS);
    posz.noStroke();
    posz.textureMode(NORMAL);
    posz.texture(originaltextures[4]);
    posz.vertex(-1*scale, -1*scale, 1*scale, 0, 0);
    posz.vertex( 1*scale, -1*scale, 1*scale, 1, 0);
    posz.vertex( 1*scale, 1*scale, 1*scale, 1, 1);
    posz.vertex(-1*scale, 1*scale, 1*scale, 0, 1);
    posz.endShape();

    // -Z "front" face
    negz.beginShape(QUADS);
    negz.textureMode(NORMAL);
    negz.noStroke();
    negz.texture(originaltextures[5]);
    negz.vertex( 1*scale, -1*scale, -1*scale, 0, 0);
    negz.vertex(-1*scale, -1*scale, -1*scale, 1, 0);
    negz.vertex(-1*scale, 1*scale, -1*scale, 1, 1);
    negz.vertex( 1*scale, 1*scale, -1*scale, 0, 1);
    negz.endShape();


    // +Y "bottom" face 
    posy.beginShape(QUADS);
    posy.textureMode(NORMAL);
    posy.noStroke();
    posy.texture(originaltextures[3]);
    posy.vertex(-1*scale, 1*scale, 1*scale, 0, 0);
    posy.vertex( 1*scale, 1*scale, 1*scale, 1, 0);
    posy.vertex( 1*scale, 1*scale, -1*scale, 1, 1);
    posy.vertex(-1*scale, 1*scale, -1*scale, 0, 1);
    posy.endShape();


    // -Y "top" face
    negy.beginShape(QUADS);
    negy.textureMode(NORMAL);
    negy.noStroke();
    negy.texture(originaltextures[2]);
    negy.vertex(-1*scale, -1*scale, -1*scale, 0, 0);
    negy.vertex( 1*scale, -1*scale, -1*scale, 1, 0);
    negy.vertex( 1*scale, -1*scale, 1*scale, 1, 1);
    negy.vertex(-1*scale, -1*scale, 1*scale, 0, 1);
    negy.endShape();

    // +X "right" face
    posx.beginShape(QUADS);
    posx.textureMode(NORMAL);
    posx.noStroke();
    posx.texture(originaltextures[0]);
    posx.vertex( 1*scale, -1*scale, 1*scale, 0, 0);
    posx.vertex( 1*scale, -1*scale, -1*scale, 1, 0);
    posx.vertex( 1*scale, 1*scale, -1*scale, 1, 1);
    posx.vertex( 1*scale, 1*scale, 1*scale, 0, 1);
    posx.endShape();


    // -X "right" face
    negx.beginShape(QUADS);
    negx.textureMode(NORMAL);
    negx.noStroke();
    negx.texture(originaltextures[1]);
    negx.vertex(-1*scale, -1*scale, -1*scale, 0, 0);
    negx.vertex(-1*scale, -1*scale, 1*scale, 1, 0);
    negx.vertex(-1*scale, 1*scale, 1*scale, 1, 1);
    negx.vertex(-1*scale, 1*scale, -1*scale, 0, 1);
    negx.endShape();


    cube.addChild(posz);
    cube.addChild(negz);
    cube.addChild(posy);
    cube.addChild(negy);
    cube.addChild(posx);
    cube.addChild(negx);

    return cube;
  }

  /*-------------Computation-----------------*/
  public void computeCamMatrix(PShader sh)
  {
    //Hack for processing GSLS Shader
    processing.opengl.PGraphics3D g3 = (processing.opengl.PGraphics3D)g;
    cameraMatrix = g3.camera;
    //cameraMatrix = g3.cameraInv;
    sh.set("camMatrix", cameraMatrix);
  }

  public void computeDynamicEnvironmentMap()
  {
    float w = inputReference[0].width;
    float h = inputReference[0].height;
    envMapDynamic.beginDraw();
    envMapDynamic.background(127);
    envMapDynamic.imageMode(CORNER);
    //"posx.jpg", "negx.jpg", "posy.jpg", "negy.jpg", "posz.jpg", "negz.jpg"
    envMapDynamic.image(inputReference[2], w *2, 0, w * 2.0, h * 2.0);
    /*envMapDynamic.image(inputReference[1], 0, textures[0].width, textures[0].width, textures[0].height);
     envMapDynamic.image(inputReference[4], textures[0].width, textures[0].height, textures[0].width, textures[0].height);*/

    //envMapDynamic.image(inputReference[0], textures[0].width * 2, textures[0].height, envMapDynamic.width/3, envMapDynamic.height/3);
    //envMapDynamic.image(inputReference[5], textures[0].width * 3, textures[0].height, envMapDynamic.width/3, envMapDynamic.height/3);

    /*envMapDynamic.image(inputReference[2], textures[0].width, 0, textures[0].width, textures[0].height);
     envMapDynamic.image(inputReference[3], textures[0].width, textures[0].height*2, textures[0].width, textures[0].height);*/
    envMapDynamic.endDraw();
  }

  /*--------------DISPLAY------------------*/
  public void displayDynamicCubeMap()
  {
    pushStyle();
    noStroke();
    shape(cubeMapObj);
    popStyle();
  }

  public void displayDynamicCubeMap(PGraphics buffer)
  {
    buffer.pushStyle();
    buffer.noStroke();
    buffer.shape(cubeMapObj);
    buffer.popStyle();
  }

  /*---------------BINDING-----------------*/
  public void bindInputReferenceAt(int index, PImage tmp_)
  {
    inputReference[index] = tmp_;
  }

  /*------------- GET -----------------*/
  public PMatrix3D getCameraMatrix()
  {

    //Hack for processing GSLS Shader
    //processing.opengl.PGraphics3D g3 = (processing.opengl.PGraphics3D)g;
    processing.opengl.PGraphics3D g3 = (processing.opengl.PGraphics3D)g;
    cameraMatrix = g3.camera;
    // cameraMatrix = g3.cameraInv;

    return cameraMatrix;
  }

  public PMatrix3D getCameraMatrix(PGraphics buffer)
  {
    buffer.getMatrix(cameraMatrix);
    return cameraMatrix;
  }
}


//------------------------------------------
//
// Camera
//
//------------------------------------------
class Camera
{
  public PVector location; //eye position
  public PVector target; // target position
  public PVector axis; //axis
  public PVector targetOrigin;

  private float focalLenght;
  private float fovy;
  private float fovh;
  private float imageWidth;
  private float imageHeight;
  private float aspectRatio;
  private float zNear;
  private float zFar;


  private float deltaX; //distance between the x (aim and eye);
  private float deltaY; //distance between the y (aim and eye);
  private float deltaZ; //distance between the z (aim and eye);
  private float magDelta;//length of the view direction
  private float azimuth, elevation, rolls; //angle for roll, pitch yaw

  final private float TOL = 0.00001;

  private boolean perspective;

  Frustum frustum;

  Camera()
  {
    initCamera(new PVector(0, 0, 0), new PVector(0, 0, -1), new PVector(0, 1, 0), 35.0, 1920.0, 819.0, 500.0, 4500.0, false);
  }

  Camera(PVector location_)
  {
    initCamera(location_, new PVector(0, 0, -1), new PVector(0, 1, 0), 35.0, 1920.0, 819.0, 500.0, 4500.0, false);
  }

  Camera(PVector location_, PVector target_)
  {
    initCamera(location_, target_, new PVector(0, 1, 0), 35.0, 1920.0, 819.0, 500.0, 4500.0, false);
  }

  Camera(PVector location_, PVector target_, PVector axis_)
  {
    initCamera(location_, target_, axis_, 35.0, 1920.0, 819.0, 10.0, 4500.0, false);
  }

  Camera(PVector location_, float aperture_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_)
  {
    initCamera(location_, new PVector(0, 0, -1), new PVector(0, 1, 0), aperture_, imageWidth_, imageHeight_, nearDistance_, farDistance_, false);
  }

  Camera(PVector location_, PVector target_, float aperture_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_)
  {
    initCamera(location_, target_, new PVector(0, 1, 0), aperture_, imageWidth_, imageHeight_, nearDistance_, farDistance_, false);
  }

  Camera(PVector location_, PVector target_, PVector axis_, float aperture_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_)
  {
    initCamera(location_, target_, axis_, aperture_, imageWidth_, imageHeight_, nearDistance_, farDistance_, false);
  }

  Camera(boolean perspective_)
  {
    initCamera(new PVector(0, 0, 0), new PVector(0, 0, -1), new PVector(0, 1, 0), 35.0, 1920.0, 819.0, 500.0, 4500.0, perspective_);
  }

  Camera(PVector location_, boolean perspective_)
  {
    initCamera(location_, new PVector(0, 0, -1), new PVector(0, 1, 0), 35.0, 1920.0, 819.0, 500.0, 4500.0, perspective_);
  }

  Camera(PVector location_, PVector target_, boolean perspective_)
  {
    initCamera(location_, target_, new PVector(0, 1, 0), 35.0, 1920.0, 819.0, 500.0, 4500.0, perspective_);
  }

  Camera(PVector location_, PVector target_, PVector axis_, boolean perspective_)
  {
    initCamera(location_, target_, axis_, 35.0, 1920.0, 819.0, 10.0, 4500.0, perspective_);
  }

  Camera(PVector location_, float aperture_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_, boolean perspective_)
  {
    initCamera(location_, new PVector(0, 0, -1), new PVector(0, 1, 0), aperture_, imageWidth_, imageHeight_, nearDistance_, farDistance_, perspective_);
  }

  Camera(PVector location_, PVector target_, float aperture_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_, boolean perspective_)
  {
    initCamera(location_, target_, new PVector(0, 1, 0), aperture_, imageWidth_, imageHeight_, nearDistance_, farDistance_, perspective_);
  }

  Camera(PVector location_, PVector target_, PVector axis_, float aperture_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_, boolean perspective_)
  {
    initCamera(location_, target_, axis_, aperture_, imageWidth_, imageHeight_, nearDistance_, farDistance_, perspective_);
  }

  private void initCamera(PVector location_, PVector target_, PVector axis_, float aperture_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_, boolean perspective_)
  {
    perspective = perspective_;
    location = location_;
    target = target_;
    targetOrigin = target.copy();
    axis = axis_;

    initPerspective(aperture_, imageWidth_, imageHeight_, nearDistance_, farDistance_);
    updateDeltas();
    if (elevation > HALF_PI - TOL)
    {
      axis.y =  0;
      axis.z = -1;
    }     

    if (elevation < TOL - HALF_PI)
    {
      axis.y =  0;
      axis.z =  1;
    }
    updateUp();
  }

  private void initPerspective(float focalLenght_, float imageWidth_, float imageHeight_, float nearDistance_, float farDistance_)
  {
    focalLenght = focalLenght_;
    imageWidth = imageWidth_;
    imageHeight = imageHeight_;
    setFovy(focalLenght);//PI/3.0;
    setFovh(focalLenght);//PI/3.0;
    setAspectRatio((float) imageWidth_, (float) imageHeight_);
    setNearFarClip(nearDistance_, farDistance_);

    frustum = new  Frustum(focalLenght, aspectRatio, location, PVector.sub(target, location).normalize().mult(-1), nearDistance_, farDistance_);
  }

  //--------------
  // COMPUTATION
  //--------------
  public void updateDeltas()
  {
    // Describe the new vector between the camera and the target
    deltaX = location.z - target.x;
    deltaY = location.y - target.y;
    deltaZ = location.z - target.z;

    // Describe the new azimuth and elevation for the camera
    magDelta = sqrt(deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ);

    azimuth    = atan2(deltaX, deltaZ);
    elevation  = atan2(deltaY, sqrt(deltaZ * deltaZ + deltaX * deltaX));

    // update the up vector
    updateUp();
  }

  private void updateUp()
  {
    // Describe the new vector between the camera and the target
    deltaX = location.z - target.x;
    deltaY = location.y - target.y;
    deltaZ = location.z - target.z;

    // Calculate the new "up" vector for the camera
    axis.x = -deltaX * deltaY;
    axis.y =  deltaZ * deltaZ + deltaX * deltaX;
    axis.z = -deltaZ * deltaY;

    // Normalize the "up" vector
    float magnitude = axis.mag();

    axis.x /= magnitude;
    axis.y /= magnitude;
    axis.z /= magnitude;

    // Calculate the roll if there is one
    if (rolls != 0)
    {
      // Calculate the camera's X axis in world space
      float directionX = deltaY * axis.z - deltaZ * axis.y;
      float directionY = deltaX * axis.z - deltaZ * axis.x;
      float directionZ = deltaX * axis.y - deltaY * axis.x;

      // Normalize this vector so that it can be scaled
      magnitude = new PVector(directionX, directionY, directionZ).mag();

      directionX /= magnitude;
      directionY /= magnitude;
      directionZ /= magnitude;

      // Perform the roll
      axis.x = axis.x * cos(rolls) + directionX * sin(rolls);
      axis.y = axis.y * cos(rolls) + directionY * sin(rolls);
      axis.z = axis.z * cos(rolls) + directionZ * sin(rolls);
    }
  }

  private void updateTarget()
  {
    // Rotate to the new orientation while maintaining the shot distance.
    float theTargetX = location.x - ( magDelta * sin(HALF_PI + elevation) * sin(azimuth));
    float theTargetY = location.y - (-magDelta * cos(HALF_PI + elevation));
    float theTargetZ = location.z - ( magDelta * sin(HALF_PI + elevation) * cos(azimuth));

    target = new PVector(theTargetX, theTargetY, theTargetZ);
    // update the up vector
    updateUp();
  }

  private void updateCamera()
  {
    // Orbit to the new orientation while maintaining the shot distance.
    float theCameraX = target.x + ( magDelta * sin(HALF_PI + elevation) * sin(azimuth));
    float theCameraY = target.y + (-magDelta * cos(HALF_PI + elevation));
    float theCameraZ = target.z + ( magDelta * sin(HALF_PI + elevation) * cos(azimuth));

    location = new PVector(theCameraX, theCameraY, theCameraZ);

    // update the up vector
    updateUp();
  }

  //---------------
  // ANIMATION
  //---------------
  /** Aim the camera at the specified target */
  public void aim(float aTargetX, float aTargetY, float aTargetZ)
  {
    // Move the target
    target = new PVector(aTargetX, aTargetY, aTargetZ);

    updateDeltas();
  }

  /** Jump the camera to the specified position */
  public void jump(float positionX, float positionY, float positionZ)
  {
    // Move the camera
    location = new PVector(positionX, positionY, positionZ);

    updateDeltas();
  }

  public void jumpAndAim(float positionX, float positionY, float positionZ, float aTargetX, float aTargetY, float aTargetZ)
  {
    location = new PVector(positionX, positionY, positionZ);
    target = new PVector(aTargetX, aTargetY, aTargetZ);
    updateDeltas();
  }

  /** Move the camera and target simultaneously along the camera's X axis */
  public void truck(float anAmount)
  {
    // Calculate the camera's X axis in world space
    float directionX = deltaY * axis.z - deltaZ * axis.y;
    float directionY = deltaX * axis.z - deltaZ * axis.x;
    float directionZ = deltaX * axis.y - deltaY * axis.x;

    // Normalize this vector so that it can be scaled
    float magnitude = new PVector(directionX, directionY, directionZ).mag();

    directionX /= magnitude;
    directionY /= magnitude;
    directionZ /= magnitude;

    // Perform the truck, if any
    location.x -= anAmount * directionX;
    //location.y -= anAmount * directionY;
    //location.z -= anAmount * directionZ;
    target.x -= anAmount * directionX;
    //target.y -= anAmount * directionY;
    //target.z -= anAmount * directionZ;
  }

  /** Move the camera and target simultaneously along the camera's Y axis */
  public void boom(float anAmount)
  {
    // Perform the boom, if any
    location.x += anAmount * axis.x;
    location.y += anAmount * axis.y;
    location.z += anAmount * axis.z;
    target.x += anAmount * axis.x;
    target.y += anAmount * axis.y;
    target.z += anAmount * axis.z;
  }

  /** Move the camera and target along the view vector */
  public void dolly(float anAmount)
  {
    // Normalize the view vector
    float directionX = deltaX / magDelta;
    float directionY = deltaY / magDelta;
    float directionZ = deltaZ / magDelta;

    // Perform the dolly, if any
    //location.x += anAmount * directionX;
    //location.y += anAmount * directionY;
    location.z += anAmount * directionZ;
    //target.x += anAmount * directionX;
    //target.y += anAmount * directionY;
    target.z += anAmount * directionZ;
  }

  /** Rotate the camera about its X axis */
  public void tilt(float anElevationOffset)
  {
    // Calculate the new elevation for the camera
    elevation = constrain(elevation - anElevationOffset, TOL-HALF_PI, HALF_PI-TOL);

    // Update the target
    updateTarget();
  }

  /** Rotate the camera about its Y axis */
  public void pan(float anAzimuthOffset)
  {
    // Calculate the new azimuth for the camera
    azimuth = (azimuth - anAzimuthOffset + TWO_PI) % TWO_PI;

    // Update the target
    updateTarget();
  }

  /** Rotate the camera about its Z axis */
  public void roll(float aRollOffset)
  {
    // Change the roll amount
    rolls = (rolls + aRollOffset + TWO_PI) % TWO_PI;

    // Update the up vector
    updateUp();
  }

  /** Arc the camera over (under) a center of interest along a set azimuth*/
  public void arc(float anElevationOffset)
  {
    // Calculate the new elevation for the camera
    elevation = constrain(elevation + anElevationOffset, TOL-HALF_PI, HALF_PI-TOL);

    // Update the camera
    updateCamera();
  }

  /** Circle the camera around a center of interest at a set elevation*/
  public void circle(float anAzimuthOffset)
  {
    // Calculate the new azimuth for the camera
    azimuth = (azimuth + anAzimuthOffset + TWO_PI) % TWO_PI;

    // Update the camera
    updateCamera();
  }

  /** Look about the camera's position */
  public void look(float anAzimuthOffset, float anElevationOffset)
  {
    // Calculate the new azimuth and elevation for the camera
    elevation = constrain(elevation - anElevationOffset, TOL-HALF_PI, HALF_PI-TOL);

    azimuth = (azimuth - anAzimuthOffset + TWO_PI) % TWO_PI;

    // Update the target
    updateTarget();
  }

  /** Tumble the camera about its target */
  public void tumble(float anAzimuthOffset, float anElevationOffset)
  {
    // Calculate the new azimuth and elevation for the camera
    elevation = constrain(elevation + anElevationOffset, TOL-HALF_PI, HALF_PI-TOL);

    azimuth   = (azimuth + anAzimuthOffset + TWO_PI) % TWO_PI;

    // Update the camera
    updateCamera();
  }

  /** Moves the camera and target simultaneously in the camera's X-Y plane */
  public void track(float anXOffset, float aYOffset)
  {
    // Perform the truck, if any
    truck(anXOffset);

    // Perform the boom, if any
    boom(aYOffset);
  }

  /** Change the field of view between "fish-eye" and "close-up" */
  public void zoom(float focal)
  {
    setFovy(focal);
  }

  public void rotateArroundElevation(float elevationOffset_)
  {
    elevation = elevation + elevationOffset_;
    float distance = PVector.dist(target, location);
    float x = target.x + cos(elevation) * distance;
    float y = target.y + sin(elevation) * distance;
    float z = location.z;

    location = new PVector(x, y, z);
  }

  public void rotateArroundElevation(float elevationOffset_, float distance_)
  {
    elevation = elevation + elevationOffset_;
    float distance = distance_;
    float x = target.x + cos(elevation) * distance;
    float y = target.y + sin(elevation) * distance;
    float z = location.z;

    location = new PVector(x, y, z);
  }

  public void rotateArroundAzimuth(float azimuthOffset_)
  {
    azimuth = azimuthOffset_;
    float distance = PVector.dist(target, location);
    float x = target.x + cos(azimuthOffset_) * distance;
    float z = target.z + sin(azimuthOffset_) * distance;
    float y = location.y;

    location = new PVector(x, y, z);
  }

  public void rotateArroundAzimuth(float azimuthOffset_, float distance_)
  {
    azimuth += azimuthOffset_;
    float distance = distance_;
    float x = target.x + cos(azimuthOffset_) * distance;
    float z = target.z + sin(azimuthOffset_) * distance;
    float y = location.y;

    location = new PVector(x, y, z);
  }

  public void rotateArround(float azimuthOffset_, float elevationOffset_)
  {
    azimuth = azimuth + azimuthOffset_;
    elevation = elevation + elevationOffset_;
    float distance = PVector.dist(target, location);
    float x = target.x + sin(elevation) * cos(azimuth) * distance;
    float z = target.y + sin(elevation) * sin(azimuth) * distance;
    float y = target.z + cos(elevation) * distance;

    location = new PVector(x, y, z);
  }

  public void rotateArround(float azimuthOffset_, float elevationOffset_, float distance_)
  {
    azimuth = azimuth + azimuthOffset_;
    elevation = elevation + elevationOffset_;
    float distance = distance_;
    float x = target.x + sin(elevation) * cos(azimuth) * distance;
    float z = target.y + sin(elevation) * sin(azimuth) * distance;
    float y = target.z + cos(elevation) * distance;

    location = new PVector(x, y, z);
  }


  //--------------
  // DISPLAY
  //--------------
  public void displayCamera(PGraphics buffer)
  {
    if (perspective)
    {
      buffer.perspective(fovy, aspectRatio, zNear, zFar);
    }
    buffer.camera(location.x, location.y, location.z, target.x, target.y, target.z, axis.x, axis.y, axis.z);
  }

  public void displayCamera()
  {
    if (perspective)
    {
      perspective(fovy, aspectRatio, zNear, zFar);
    }
    camera(location.x, location.y, location.z, target.x, target.y, target.z, axis.x, axis.y, axis.z);
  }

  public void displayDebugCamera(float x_, float y_, float z_, float length_)
  {
    pushMatrix();
    pushMatrix();
    translate(x_, y_, z_);
    rotateX(elevation * -1);
    rotateY(azimuth * -1);
    rotateZ(rolls * -1);
    stroke(255, 0, 0); 
    line(0, 0, 0, length_, 0, 0);
    //y-axis
    stroke(0, 255, 0); 
    line(0, 0, 0, 0, length_, 0);
    //z-axis
    stroke(0, 0, 255); 
    line(0, 0, 0, 0, 0, length_);
    popMatrix();
    popMatrix();
  }

  //--------------
  // SET METHODS
  //--------------
  public void setRoll(float r_)
  {
    rolls = r_;
    updateUp();
  }

  public void setFovy(float focalLength_)
  {
    fovy = 2 * atan((0.5 * 36) / focalLength_);
    //fovy = radians(angle_);//2 * atan((0.5 * imageHeight) / focalLenght_) ;
  }

  public void setFovh(float focalLength_)
  {
    fovh = 2 * atan((0.5 * 24) / focalLength_);
  }

  public void setAspectRatio(float width_, float height_)
  {
    aspectRatio = (float)width_ / (float)height_;
  }

  public void setNearFarClip(float near_, float far_)
  {
    zNear = near_;
    zFar = far_;
  }


  //--------------
  // GET METHOD
  //--------------
  //methodes get
  public float getAzimuth() //pan angle
  {
    return azimuth;
  }

  public float getRoll() //rollAngle
  {
    return rolls;
  }

  public float getElevation() //yaw angle
  {
    return elevation;
  }

  public PVector getTarget()
  {
    return target;
  }

  public PVector getLocation()
  {
    return location;
  }
}