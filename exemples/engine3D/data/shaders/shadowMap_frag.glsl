//shadow map
#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif


out vec4 fragColor;

// In the default shader we won't be able to access the shadowMap's depth anymore,
// just the color, so this function will pack the 16bit depth float into the first
// two 8bit channels of the rgba vector.
vec4 packDepth(float depth) {
    float depthFrac = fract(depth * 255.0);
    return vec4(depth - depthFrac / 255, depthFrac, 1.0, 1.0);
}

void main(void) {
    //float depth = gl_FragCoord.z / gl_FragCoord.w; 
    fragColor = packDepth(gl_FragCoord.z);
}