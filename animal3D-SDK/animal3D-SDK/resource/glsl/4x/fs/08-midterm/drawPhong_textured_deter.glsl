#version 410

layout (location = 0) out vec4 rtFragColor;


const int MAX_LIGHTS = 4;

in vec4 vViewPos; 
in vec4 vModelViewNorm;
in vec2 vTexCoord;
in vec4 vShadowCoord; // Step 2

uniform int uLightCt;
uniform vec4 uLightPos[MAX_LIGHTS];
uniform vec4 uLightCol[MAX_LIGHTS];
uniform float uLightSz[MAX_LIGHTS];

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform sampler2D uTex_shadow; // Step 3

uniform double uTime;

uniform float perlinSize = 1.0;

/*
//http://www.science-and-fiction.org/rendering/noise.html
float rand2D(in vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float rand3D(in vec3 co){
    return fract(sin(dot(co.xyz ,vec3(12.9898,78.233,144.7272))) * 43758.5453);
}

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = rand2D(i + vec2(-perlinSize * 0.5, -perlinSize * 0.5));
    float b = rand2D(i + vec2(perlinSize * 0.5, -perlinSize * 0.5));
    float c = rand2D(i + vec2(-perlinSize * 0.5, perlinSize * 0.5));
    float d = rand2D(i + vec2(perlinSize * 0.5, perlinSize * 0.5));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}


void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE GREEN
    float n = noise(vTexCoord.xy * 20.0 + sin(float(uTime)) );
	vec3 color = texture(uTex_dm, vTexCoord).xyz;
    float time = (cos(float(uTime)) + 1.0);
    float burnAmount = n * time;
    color = vec3(clamp(clamp(color.r * 3.0, 0, 1) * burnAmount, color.r, 1.0), color.g * (1.0 - burnAmount) * (1.0-time), color.b * (1.0 - burnAmount) * (1.0-time));

    rtFragColor = vec4(color, 1.0);
    //rtFragColor = vec4(1.0, 1.0, 0.0, 1.0);
    //rtFragColor = vec4(1.0 * n, 0.0,0.0,1.0);
}
*/


// Returns normalized light vector
vec4 getNormalizedLight(vec4 lightPos, vec4 objPos);
// Returns the dot product of the passed normal and light vector
float getDiffuseCoeff(vec4 normal, vec4 lightVector);

void main()
{
	vec4 texDiffuse = texture2D(uTex_dm, vTexCoord);
	vec4 texSpecular = texture2D(uTex_sm, vTexCoord);

	vec4 phong;

	vec4 surfaceNorm = normalize(vModelViewNorm);	

	vec4 projScreen = vShadowCoord / vShadowCoord.w; // Step 2
	float shadowSample = texture2D(uTex_shadow, projScreen.xy).r; // Step 4
	bool fragIsShadowed = projScreen.z > (shadowSample + 0.0025); // Step 4

	for (int i = 0; i < uLightCt; ++i) {
		vec4 lightNorm = getNormalizedLight(uLightPos[i], vViewPos);

		// Calculate diffuse coefficient
		float diffuse = getDiffuseCoeff(surfaceNorm, lightNorm);
		
		// Scale diffuse & proceed w/ shading
		if(fragIsShadowed)
		{
			diffuse *= 0.2;
		}

		// Create the lambertian reflection from the diffuse coefficient and the diffuse texture
		vec4 lambert = diffuse * texDiffuse;

		// Calculate reflected light value
		vec4 reflection = 2.0 * diffuse * surfaceNorm - lightNorm;

		// Calculate initial specular coefficient
		float specularCoeff = max(0.0, dot(-normalize(vViewPos), reflection));
		
		// Exponentially increase specular coefficient
		specularCoeff *= specularCoeff; // ks^2
		specularCoeff *= specularCoeff; // ks^4
		specularCoeff *= specularCoeff; // ks^8
		specularCoeff *= specularCoeff; // ks^16
		specularCoeff *= specularCoeff; // ks^32
		specularCoeff *= specularCoeff; // ks^64

		vec4 specular = specularCoeff * texSpecular;

		phong += (lambert + specular) * uLightCol[i];
	}
	rtFragColor = vec4(phong.xyz, 1.0);
}

// Returns normalized light vector (L_hat)
vec4 getNormalizedLight(vec4 lightPos, vec4 objPos)
{
	vec4 lightVec = lightPos - objPos;
	return normalize(lightVec);
}

// Returns the dot product of the passed normal and light vector
// Make sure to pass normalized values in
float getDiffuseCoeff(vec4 normal, vec4 lightVector)
{
	return max(0.0, dot(normal, lightVector));
}