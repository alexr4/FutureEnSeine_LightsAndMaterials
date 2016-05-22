uniform samplerCube cubemap;
uniform float alphaRatio = 0.25;

in vec3 reflectDir;
in vec3 refractDirRed;
in vec3 refractDirGreen;
in vec3 refractDirBlue;
in float refractRatio;
in vec4 vertColor;
in vec4 vertTexCoord;

out vec4 fragColor;

void main() {

    //Correction of Y axis
    vec3 refle = vec3(reflectDir.x, -reflectDir.y, reflectDir.z);
    vec3 refractRed = vec3(refractDirRed.x, -refractDirRed.y, refractDirRed.z);
    vec3 refractGreen = vec3(refractDirGreen.x, -refractDirGreen.y, refractDirGreen.z);
    vec3 refractBlue = vec3(refractDirBlue.x, -refractDirBlue.y, refractDirBlue.z);

    vec4 refractColor;
    refractColor.r = textureCube(cubemap, refractRed).r;
    refractColor.g = textureCube(cubemap, refractGreen).g;
    refractColor.b = textureCube(cubemap, refractBlue).b;
    refractColor.a = 1.0;
    refractColor = mix(refractColor, vertColor, refractRatio * alphaRatio);

    vec4 reflectColor = textureCube(cubemap, refle);
    reflectColor = mix(reflectColor, vertColor, 0.0);

    fragColor = vec4(mix(refractColor.rgb, reflectColor.rgb, refractRatio), 1.0);
    //fragColor = reflectColor;
  }
