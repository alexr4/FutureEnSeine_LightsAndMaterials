//Rim shader based on : http://www.roxlu.com/2014/037/opengl-rim-shader
//Rim shading is a backlight shading. We use the the vertex point from the shapevertex to the cameraView.
//then define an angle value to define a power of the rim value
uniform mat4 transform;
uniform mat4 modelview;

in vec4 vertex;
in vec3 normal;
in vec4 color;

out vec4 vertColor;
out vec3 rimVDN;

void main()
{
	vertColor = vec4(1.0, 0, 0, 1.0);

	vec3 n = normalize(mat3(modelview) * normal); // convert normal to view space
	vec3 p = vec3(modelview * vertex);// position in view space
	vec3 v = normalize(-p);// vector towards eye
	float rc = 1.0 - max(dot(v, n), 0.0);
	rimVDN = vec3(rc, rc, rc);// the rim-shading contribution

	gl_Position = transform * vertex;
}