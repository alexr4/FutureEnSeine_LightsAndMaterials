//marble texture based on http://www.tinysg.de/techGuides/tg1_proceduralMarble.html
#version 430
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;
uniform sampler2D depthMap;
uniform float fogInc = 1.5;
uniform vec3 eyeDirection;
uniform vec3 lightDirection;


in vec4 vertTexCoord;

out vec4 fragColor;

  // Unpack the 16bit depth float from the first two 8bit channels of the rgba vector
float unpackDepth(vec4 color) { 
	return color.r + color.g / 255;
}

vec3 applyFog(vec3 rgb, float depth)
{
	float fogAmount = 1.0 - exp(-depth * fogInc);
	vec3 fogColor = vec3(0.05098039);
	return mix(rgb, fogColor, fogAmount);
}

vec3 applyFog(vec3 rgb, float depth, vec3 rayDir, vec3 sunDir)
{
	float fogAmount = 1.0 - exp(-depth * fogInc);
	float sunAmount = max(dot(rayDir, sunDir), 0.0);
	vec3 fogColor = mix(vec3(0.05098039), vec3(0.06), pow(sunAmount, 8.0));
	return mix(rgb, fogColor, fogAmount);
}

void main()
{
	vec4 rgb = texture2D(texture, vertTexCoord.xy);
	//depth informations
	float depth = unpackDepth(texture2D(depthMap, vertTexCoord.xy));
	fragColor = vec4(applyFog(rgb.rgb, depth, eyeDirection, lightDirection).rgb, 1.0);
}