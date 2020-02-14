/*
	Copyright 2011-2020 Daniel S. Buckstein

	Licensed under the Apache License, Version 2.0 (the "License");
	you may not use this file except in compliance with the License.
	You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0

	Unless required by applicable law or agreed to in writing, software
	distributed under the License is distributed on an "AS IS" BASIS,
	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	See the License for the specific language governing permissions and
	limitations under the License.
*/

/*
	animal3D SDK: Minimal 3D Animation Framework
	By Daniel S. Buckstein
	
	drawPhong_multi_shadow_mrt_fs4x.glsl
	Draw Phong shading model for multiple lights with MRT output and 
		shadow mapping.
*/

#version 410

// ****TO-DO: 
//	0) copy existing Phong shader
//	1) receive shadow coordinate
//	2) perform perspective divide
//	3) declare shadow map texture
//	4) perform shadow test

const int MAX_LIGHTS = 4;

in vec4 vModelViewNorm;
in vec4 vViewPos;
in vec2 vTexCoord;
in vec4 vShadowCoord; // Step 1

uniform sampler2D uTex_dm;
uniform sampler2D uTex_sm;
uniform sampler2D uTex_shadow; // Step 3
uniform int uLightCt;
uniform vec4 uLightPos[MAX_LIGHTS];
uniform vec4 uLightCol[MAX_LIGHTS];
uniform float uLightSz[MAX_LIGHTS];

layout(location = 0) out vec4 rtFragColor;

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
