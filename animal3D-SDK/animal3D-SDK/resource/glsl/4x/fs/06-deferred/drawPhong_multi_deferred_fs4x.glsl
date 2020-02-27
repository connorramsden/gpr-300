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
in vbLightingData {
	vec4 vViewPosition;
	vec4 vViewNormal;
	vec4 vTexcoord;
	vec4 vBiasedClipCoord;
};

// (1) a3_Demo_Pipelines_idle-render.c (lines 605-610)
uniform sampler2D uImage00; // g-buffer depth texture (depth map)
uniform sampler2D uImage01; // g-buffer position (vViewPos)
uniform sampler2D uImage02; // g-buffer normal (vViewNormal)
uniform sampler2D uImage03; // g-buffer texcoord (vTexcoord)
uniform sampler2D uImage04; // g-buffer uTex_dm
uniform sampler2D uImage05; // g-buffer uTex_sm

// (3)
uniform mat4 uPB_inv;

uniform int uLightCt;
uniform vec4 uLightPos[MAX_LIGHTS];
uniform vec4 uLightCol[MAX_LIGHTS];
uniform float uLightSz[MAX_LIGHTS];

layout (location = 0) out vec4 rtFragColor;
layout (location = 4) out vec4 rtDiffuseMapSample;
layout (location = 5) out vec4 rtSpecularMapSample;
layout (location = 6) out vec4 rtDiffuseLightTotal;
layout (location = 7) out vec4 rtSpecularLightTotal;

// Calculate diffuse coefficient based on surface normal & normalized light vector
float diffuseCalculation(vec4 surfaceNormal, vec4 lightVector_n);
// Calculate specular coefficient based on surface normal, normalized light vector, and view position
float specularCalculation(vec4 surfaceNormal, vec4 lightVector_n, vec4 viewPosition);

void main()
{
	// (3) Sample geometric info from g-buffers
	vec4 gPosition = texture(uImage01, vTexcoord.xy);
	vec4 gNormal = texture(uImage02, vTexcoord.xy);
	vec2 gTexcoord = texture(uImage03, vTexcoord.xy).xy; // Gets used as-is
 	
	// (3) set up reverse perspective divide
	gPosition *= uPB_inv;
	// (3) perform reverse perspective divide
	gPosition /= gPosition.w;
	// (3) Expand range of normal sample
	gNormal = (gNormal - 0.5) * 2.0;
	
	// Acquire diffuse & specular samples using g-buffer Texcoord
	vec4 diffuseSample = texture(uImage04, gTexcoord);
	vec4 specularSample = texture(uImage05, gTexcoord);
	
	// Set up phong for output
	vec4 phong = vec4(0.0);
	float diffuseLightTotal = 0.0;
	float specularLightTotal = 0.0;

	// Calculate surface normal (optimized, not in every loop)
	vec4 surfaceNormal = normalize(gNormal);

	for(int i = 0; i < uLightCt; ++i)
	{
		vec4 lightVector = vec4(vec3(uLightPos[i] - gPosition), 1.0);
		vec4 lightVector_n = normalize(lightVector);
		
		// Calculate diffuse coefficient
		float diffuseCoeff = diffuseCalculation(surfaceNormal, lightVector_n);
		// Update diffuse light total for eventual output
		diffuseLightTotal += diffuseCoeff;
		// Acquire final diffuse output
		vec4 diffuse = diffuseCoeff * diffuseSample;

		// Calculate specular coefficient (already exponentially multiplied)
		float specularCoeff = specularCalculation(surfaceNormal, lightVector_n, gPosition);
		// Update specular light total for eventual output
		specularLightTotal += specularCoeff;
		// Acquire final specular output
		vec4 specular = specularCoeff * specularSample;

		// Update phong by new diffuse & specular calculations
		phong += (diffuse + specular) * uLightCol[i];
	}	

	// Output to render targets
	rtFragColor = vec4(phong.xyz, 1.0);
	rtDiffuseMapSample = vec4(diffuseSample.xyz, 1.0);
	rtSpecularMapSample = vec4(specularSample.xyz, 1.0);
	rtDiffuseLightTotal = vec4(vec3(diffuseLightTotal), 1.0);
	rtSpecularLightTotal = vec4(vec3(specularLightTotal), 1.0);
}

// Calculate diffuse coefficient based on surface normal & normalized light vector
float diffuseCalculation(vec4 surfaceNormal, vec4 lightVector_n)
{
	float diffuseCoeff = max(0.0, dot(surfaceNormal, lightVector_n));;

	return diffuseCoeff;
}

// Calculate specular coefficient based on surface normal, normalized light vector, and view position
float specularCalculation(vec4 surfaceNormal, vec4 lightVector_n, vec4 viewPosition)
{
	vec4 reflection = vec4(reflect(lightVector_n, surfaceNormal).xyz, 1.0);

	float specularCoeff = max(0.0, dot(normalize(viewPosition), reflection));
	
	// Exponentially increase specular coefficient
	specularCoeff *= specularCoeff; // ks^2
	specularCoeff *= specularCoeff; // ks^4
	specularCoeff *= specularCoeff; // ks^8
	specularCoeff *= specularCoeff; // ks^16
	specularCoeff *= specularCoeff; // ks^32
	specularCoeff *= specularCoeff; // ks^64

	return specularCoeff;
}