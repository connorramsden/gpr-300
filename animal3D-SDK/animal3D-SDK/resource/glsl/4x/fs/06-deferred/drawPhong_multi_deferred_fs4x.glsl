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
	
	drawPhong_multi_deferred_fs4x.glsl
	Draw Phong shading model by sampling from input textures instead of 
		data received from vertex shader.
*/

#version 410

#define MAX_LIGHTS 4

// ****TO-DO: 
//	0) copy original forward Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare light data as uniform block
//	3) replace geometric information normally received from fragment shader 
//		with samples from respective g-buffer textures; use to compute lighting
//			-> position calculated using reverse perspective divide; requires 
//				inverse projection-bias matrix and the depth map
//			-> normal calculated by expanding range of normal sample
//			-> surface texture coordinate is used as-is once sampled

// (2)
in vbLightingData{
	vec4 vViewPosition;
	vec4 vViewNormal;
	vec4 vTexcoord;
	vec4 vBiasedClipCoord;
};

uniform int uLightCt;
uniform vec4 uLightPos[MAX_LIGHTS];
uniform vec4 uLightCol[MAX_LIGHTS];
uniform float uLightSz[MAX_LIGHTS];

// (1) a3_DemoState_loading.c (lines ~754+)
uniform sampler2D uImage00; // uTex_dm
uniform sampler2D uImage01; // uTex_sm
uniform sampler2D uImage02; // uTex_nm
uniform sampler2D uImage03; // uTex_hm
uniform sampler2D uImage04; // uTex_dm_ramp
uniform sampler2D uImage05; // uTex_sm_ramp
uniform sampler2D uImage06; // uTex_shadow
uniform sampler2D uImage07; // uTex_proj

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

// Returns normalized light vector
vec4 getNormalizedLight(vec4 lightPos, vec4 objPos);
// Returns the dot product of the passed normal and light vector
float getDiffuseCoeff(vec4 normal, vec4 lightVector);

void main()
{
	// Calculating gBuffers	
	vec4 gTexcoord = texture(uImage03, vec2(vTexcoord));
	vec4 gNormal = texture(uImage02, vec2(gTexcoord));

	// Sample Albedos
	vec4 gDiffuse = texture(uImage00, vec2(gTexcoord));
	vec4 gSpecular = texture(uImage01, vec2(gTexcoord));
	
	vec4 phong;
	vec4 diffuse;
	vec4 specular;

	vec4 surfaceNorm = normalize(gNormal);

	for (int i = 0; i < uLightCt; ++i) {
		vec4 lightNorm = getNormalizedLight(uLightPos[i], vViewPosition);

		// Calculate diffuse coefficient
		float diffuseCoeff = getDiffuseCoeff(surfaceNorm, lightNorm);

		// Create the lambertian reflection from the diffuse coefficient and the diffuse texture
		diffuse = diffuseCoeff * gDiffuse;

		// Calculate reflected light value
		vec4 reflection = 2.0 * diffuseCoeff * surfaceNorm - lightNorm;

		// Calculate initial specular coefficient
		float specularCoeff = max(0.0, dot(-normalize(vViewPosition), reflection));
		
		// Exponentially increase specular coefficient
		specularCoeff *= specularCoeff; // ks^2
		specularCoeff *= specularCoeff; // ks^4
		specularCoeff *= specularCoeff; // ks^8
		specularCoeff *= specularCoeff; // ks^16
		specularCoeff *= specularCoeff; // ks^32
		specularCoeff *= specularCoeff; // ks^64

		specular = specularCoeff * gSpecular;

		phong += (diffuse + specular) * uLightCol[i];
	}

	// DUMMY OUTPUT: all fragments are OPAQUE CYAN (and others)
	rtFragColor = gNormal;
	rtDiffuseMapSample = diffuse;
	rtSpecularMapSample = vec4(0.0, 1.0, 0.0, 1.0);
	rtDiffuseLightTotal = vec4(1.0, 0.0, 1.0, 1.0);
	rtSpecularLightTotal = vec4(1.0, 1.0, 0.0, 1.0);
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
