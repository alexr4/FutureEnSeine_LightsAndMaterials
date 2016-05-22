//Simple diffuse shader 
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

in vec4 vertex;
in vec3 normal;
in vec4 color;
in vec2 texCoord;

out vec4 vertColor;
out vec4 vertTexCoord;

uniform sampler2D displacementMap;
uniform float displaceStrength;

void main()
{
	vertColor = color;
	vertTexCoord =  texMatrix * vec4(texCoord, 1.0, 1.0);

	vec4 displacedVertex;
	vec4 dv;
	float df;

	dv = texture2D(displacementMap, vertTexCoord.xy );	
	df = 0.30*dv.x + 0.59*dv.y + 0.11*dv.z;	
	displacedVertex = vec4(normal * df * displaceStrength, 0.0) + vertex;

	gl_Position = transform * displacedVertex;
}