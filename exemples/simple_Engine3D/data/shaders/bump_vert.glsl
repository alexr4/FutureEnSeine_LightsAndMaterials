//Simple Normal Map based on https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6
uniform mat4 modelview;
uniform mat4 transform;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;

const float zero_float = 0.0;
const float one_float = 1.0;

//lights attribute
uniform int lightCount;
uniform vec4 lightPosition[8];
uniform vec3 lightNormal[8];  
uniform vec3 lightFalloff[8];

//atributes from mesh
in vec4 vertex;
in vec4 color;
in vec2 texCoord;
in vec3 normal;
in vec4 tangent;

out vec4 vertTexCoord;
out vec4 vertColor;
out vec3 ecNormal; //eyeCoordinates normalized
out vec3 ecVertex;//eyeCoordinates
out vec3 lightDir[8];
out float isDirectionnal[8];

void main()
{
	//define vertex Color & Vertex Texture Coordinates
	vertColor = color;
	vertTexCoord =  texMatrix * vec4(texCoord, 1.0, 1.0);

	//Define lights
	ecVertex = vec3(modelview * vertex);
	ecNormal = normalize(normalMatrix * normal);

	for(int i=0; i<lightCount; i++)
	{
		bool isDir = lightPosition[i].w < one_float;

		if (isDir) {
			isDirectionnal[i] = 1.0;
			lightDir[i] = -one_float * lightNormal[i];
		} else { 
			isDirectionnal[i] = 0.0;
			lightDir[i] = normalize(lightPosition[i].xyz - ecVertex.xyz);
		}
	}

	gl_Position = transform * vertex;
}