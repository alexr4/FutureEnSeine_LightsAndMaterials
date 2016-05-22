//------------------------------------------
//
// Cube map for environment Mapping
//
//------------------------------------------

import java.nio.IntBuffer; //for CubeMap
public void sendCameraMatrixTo(PShader sh)
  {
    cubemap.computeCamMatrix(sh);
  }
  
class CubeMap
{

  //CubeMap Buffer Variables
  public int location;
  private float smoothScale;
  public IntBuffer envMapTextureID; //Target Buffer
  public PMatrix3D cameraMatrix; //Hack for CameraMatrix

  //List of Textures
  private String path = "cubeMapTex/low_02_CityDay/";
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

static class ImageComputation
{
  // ==================================================
  // Super Fast Blur v1.1
  // by Mario Klingemann 
  // <http://incubator.quasimondo.com>
  // ==================================================
  static void fastblur(PImage img, int radius)
  {
    if (radius<1) {
      return;
    }
    int w=img.width;
    int h=img.height;
    int wm=w-1;
    int hm=h-1;
    int wh=w*h;
    int div=radius+radius+1;
    int r[]=new int[wh];
    int g[]=new int[wh];
    int b[]=new int[wh];
    int rsum, gsum, bsum, x, y, i, p, p1, p2, yp, yi, yw;
    int vmin[] = new int[max(w, h)];
    int vmax[] = new int[max(w, h)];
    int[] pix=img.pixels;
    int dv[]=new int[256*div];
    for (i=0; i<256*div; i++) {
      dv[i]=(i/div);
    }

    yw=yi=0;

    for (y=0; y<h; y++) {
      rsum=gsum=bsum=0;
      for (i=-radius; i<=radius; i++) {
        p=pix[yi+min(wm, max(i, 0))];
        rsum+=(p & 0xff0000)>>16;
        gsum+=(p & 0x00ff00)>>8;
        bsum+= p & 0x0000ff;
      }
      for (x=0; x<w; x++) {

        r[yi]=dv[rsum];
        g[yi]=dv[gsum];
        b[yi]=dv[bsum];

        if (y==0) {
          vmin[x]=min(x+radius+1, wm);
          vmax[x]=max(x-radius, 0);
        }
        p1=pix[yw+vmin[x]];
        p2=pix[yw+vmax[x]];

        rsum+=((p1 & 0xff0000)-(p2 & 0xff0000))>>16;
        gsum+=((p1 & 0x00ff00)-(p2 & 0x00ff00))>>8;
        bsum+= (p1 & 0x0000ff)-(p2 & 0x0000ff);
        yi++;
      }
      yw+=w;
    }

    for (x=0; x<w; x++) {
      rsum=gsum=bsum=0;
      yp=-radius*w;
      for (i=-radius; i<=radius; i++) {
        yi=max(0, yp)+x;
        rsum+=r[yi];
        gsum+=g[yi];
        bsum+=b[yi];
        yp+=w;
      }
      yi=x;
      for (y=0; y<h; y++) {
        pix[yi]=0xff000000 | (dv[rsum]<<16) | (dv[gsum]<<8) | dv[bsum];
        if (x==0) {
          vmin[y]=min(y+radius+1, hm)*w;
          vmax[y]=max(y-radius, 0)*w;
        }
        p1=x+vmin[y];
        p2=x+vmax[y];

        rsum+=r[p1]-r[p2];
        gsum+=g[p1]-g[p2];
        bsum+=b[p1]-b[p2];

        yi+=w;
      }
    }
  }
}