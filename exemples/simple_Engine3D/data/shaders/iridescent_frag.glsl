//Simple iridescent shader based on Diego Inàcio implementation (https://vimeo.com/83798053)
#version 130
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

in vec4 vertColor;
in vec3 ecVertex;
in vec3 ecNormal;

uniform float iridescentRatio = 1.0;

out vec4 fragColor;

float map(float value, float oMin, float oMax, float iMin, float iMax){
	return iMin + ((value - oMin)/(oMax - oMin)) * (iMax - iMin);
}

float diNoise(vec3 pos){
	//noise function to create irregularity
	float mult = 0.05;
	float oset = 25;		//offset
	return	sin(pos.x*mult*2 + 12 + oset) + cos(pos.z*mult + 21 + oset) *
		sin(pos.y*mult*2 + 23 + oset) + cos(pos.y*mult + 32 + oset) *
		sin(pos.z*mult*2 + 34 + oset) + cos(pos.x*mult + 43 + oset);
}

vec3 iridescence(float orientation, vec3 position)//iridescence base on orientation
{
	vec3 iridescent;
	float frequence = 8.0;
	float offset = 4.0;
	float noiseInc = 1;

	iridescent.x = abs(cos(orientation * frequence + diNoise(position) * noiseInc + 1 + offset));
	iridescent.y = abs(cos(orientation * frequence + diNoise(position) * noiseInc + 2 + offset));
	iridescent.z = abs(cos(orientation * frequence + diNoise(position) * noiseInc + 3 + offset));

	return iridescent;
}

void main()
{

	vec3 NecVertex = normalize(-ecVertex);
	if(!gl_FrontFacing)
	{
		NecVertex = normalize(ecVertex);
	}
	float facingRatio = dot(ecNormal, NecVertex);

	vec4 iridescentColor = vec4(iridescence(facingRatio, ecVertex), 1.0) * 
							map(pow(1 - facingRatio, 1.0/0.75), 0.0, 1.0, 0.1, 1);

	vec4 transparentIridescence = iridescentColor * iridescentRatio;
	vec4 nonTransprentIridescence = vec4(mix(vertColor.rgb, iridescentColor.rgb, iridescentRatio), 1.0);

	//fragColor = transparentIridescence;
	fragColor = gl_FrontFacing ? transparentIridescence : transparentIridescence;
}