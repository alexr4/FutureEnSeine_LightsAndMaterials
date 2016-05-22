//Simple Normal Map based on https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform int lightCount;
uniform vec3 lightNormal[8];
uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8]; // diffuse is the color element of the light

in vec4 vertColor;
in vec3 ecNormal; //eyeCoordinates normalized
in vec3 ecVertex;//eyeCoordinates
in vec3 lightDir[8];
in vec4 vertTexCoord;

//material
uniform vec3 kd;//Diffuse reflectivity
uniform vec3 ka;//Ambient reflectivity
uniform vec3 ks;//Specular reflectivity
uniform vec3 emissive; //emissive color
uniform float shininess;//shine factor
uniform sampler2D bumpmap;
uniform float minNormalEmissive;

out vec4 fragColor;

vec3 ads(vec3 dir, vec3 color)
{
	vec3 n = normalize(ecNormal);
	vec3 s = normalize(dir);
	vec3 v = normalize(-ecVertex.xyz);
	vec3 r = reflect(-s, n);
	vec3 h = normalize(v + s);
	float intensity = max(0.0, dot(s, n));

	/*if(gl_FrontFacing)
	{		
	 n = normalize(-ecNormal);
	 s = normalize(dir);
	 v = normalize(ecVertex.xyz);
	 r = reflect(s, n);
	 h = normalize(v + s);
	 intensity = max(0.0, dot(n, s));
	}*/
//
	//return color * intensity * (ka + kd * max(dot(s, n), 0.0) + ks * pow(max(dot(r, v), 0.0), shininess));
	return color * intensity * (ka + kd * max(dot(s, n), 0.0) + ks * pow(max(dot(h, n), 0.0), shininess));
}

void main()
{
	//normal map
	vec4 normalTexture = texture2D(bumpmap, vertTexCoord.st);
	vec3 normalMap = vec3(normalTexture.rgb) * 2.0 - 1.0;
	vec3 normNM = normalize(normalMap);

	//lights
	vec4 lightColor = vec4(0.0, 0.0, 0.0, 1.0);
	float intensityNormalMap = 0.0;
	
	for(int i = 0 ; i <lightCount ; i++) 
	{
	  vec3 direction = normalize(lightDir[i]);
	  lightColor += vec4(ads(direction, lightDiffuse[i].xyz), 1.0);
	  intensityNormalMap += max(dot(normNM, lightDir[i]), minNormalEmissive);
	}
	intensityNormalMap = intensityNormalMap/lightCount;
	vec4 final_lightNormalColor =  (vec4(emissive, 1.0)  +  lightColor * vertColor) * intensityNormalMap;

	vec4 Albedo = vec4(final_lightNormalColor.rgb, 1.0);

	fragColor = Albedo;
	//fragColor = gl_FrontFacing ? Albedo : Albedo;
}