//Simple Per-Pixel Phong Lighting with gamma correction http://marcinignac.com/blog/pragmatic-pbr-setup-and-gamma/
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

const float zero_float = 0.0;
const float one_float = 1.0;
const float gamma = 2.2f;

uniform int lightCount;
uniform vec3 lightNormal[8];
uniform vec4 lightPosition[8];
uniform vec3 lightDiffuse[8]; // diffuse is the color element of the light  
uniform vec3 lightFalloff[8];

in vec4 vertColor;
in vec3 ecNormal; //eyeCoordinates normalized
in vec3 ecVertex;//eyeCoordinates
in vec3 lightDir[8];
in float isDirectionnal[8];

//material
uniform vec3 kd;//Diffuse reflectivity
uniform vec3 ka;//Ambient reflectivity
uniform vec3 ks;//Specular reflectivity
uniform vec3 emissive; //emissive color
uniform float shininess;//shine factor

out vec4 fragColor;

vec3 toLinear(vec3 v) {
  return pow(v, vec3(gamma));
}

vec4 toLinear(vec4 v) {
  return vec4(toLinear(v.rgb), v.a);
}

vec3 toGamma(vec3 v) {
  return pow(v, vec3(1.0 / gamma));
}

vec4 toGamma(vec4 v) {
  return vec4(toGamma(v.rgb), v.a);
}

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


float falloffFactor(vec3 lightPos, vec3 vertPos, vec3 coeff) {
  vec3 lpv = lightPos - vertPos;
  vec3 dist = vec3(one_float);
  dist.z = dot(lpv, lpv);
  dist.y = sqrt(dist.z);
  return one_float / dot(dist, coeff);
}

void main()
{

	//lights
	vec4 lightColor = vec4(0.0, 0.0, 0.0, 1.0);
	
	for(int i = 0 ; i <lightCount ; i++) 
	{
	  vec3 direction = normalize(lightDir[i]);
	  float falloff = 0.0;
	  if(isDirectionnal[i] == 1.0)
	  {
	  	falloff = one_float;
	  }else{
	  	falloff = falloffFactor(lightPosition[i].xyz, ecVertex, lightFalloff[i]);
	  }
	  
	  lightColor += vec4(ads(direction, lightDiffuse[i].xyz), 1.0) * falloff;
	}
	vec4 final_lightColor =  vec4(emissive, 1.0)  +  (lightColor * vertColor);

	fragColor = toGamma(final_lightColor);
	//fragColor = gl_FrontFacing ? toGamma(final_lightColor) : toGamma(final_lightColor);
}