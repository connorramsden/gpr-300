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
	
	drawPhongVolume_fs4x.glsl
	Draw Phong lighting components to render targets (diffuse & specular).
*/

#version 410

#define MAX_LIGHTS 1024

// ****TO-DO: 
//	0) copy deferred Phong shader
//	1) declare g-buffer textures as uniform samplers
//	2) declare lighting data as uniform block
//	3) calculate lighting components (diffuse and specular) for the current 
//		light only, output results (they will be blended with previous lights)
//			-> use reverse perspective divide for position using scene depth
//			-> use expanded normal once sampled from normal g-buffer
//			-> do not use texture coordinate g-buffer

in vec4 vBiasedClipCoord;
flat in int vInstanceID;

// (2)
// simple point light (modified version of a3d point light)
struct uPointLight
{
	vec4 worldPos;						// position in world space
	vec4 viewPos;						// position in viewer space
	vec4 color;							// RGB color with padding
	float radius;						// radius (distance of effect from center)
	float radiusInvSq;					// radius inverse squared (attenuation factor)
	float pad[2];						// padding
};

uniform ubPointLight {
	uPointLight uLight[MAX_LIGHTS];
};

// (1) a3_Demo_Pipelines_idle-render.c (lines 605-610)
uniform sampler2D uImage01; // g-buffer position (vViewPos)
uniform sampler2D uImage02; // g-buffer normal (vViewNormal)
uniform sampler2D uImage03; // g-buffer texcoord (vTexcoord)

// (3)
uniform mat4 uPB_inv;

layout (location = 6) out vec4 rtDiffuseLight;
layout (location = 7) out vec4 rtSpecularLight;

// Calculate diffuse coefficient based on surface normal & normalized light vector
float diffuseCalculation(vec4 surfaceNormal, vec4 lightVector_n);
// Calculate specular coefficient based on surface normal, normalized light vector, and view position
float specularCalculation(vec4 surfaceNormal, vec4 lightVector_n, vec4 viewPosition);

void main()
{
	// Perform perspective divide on biased clip coordinate
	vec2 biasedLightPos = (vBiasedClipCoord / vBiasedClipCoord.w).xy;

	// (3) Sample geometric info from g-buffers
	vec4 gPosition = texture(uImage01, biasedLightPos);
	vec4 gNormal = texture(uImage02, biasedLightPos);
	
	// Set up single light that is dealt with on this pass
	uPointLight passedLight = uLight[vInstanceID];
 	
	// (3) set up reverse perspective divide
	gPosition *= uPB_inv;
	// (3) perform reverse perspective divide
	gPosition /= gPosition.w;
	// (3) Expand range of normal sample
	gNormal = (gNormal - 0.5) * 2.0;
	
	// Calculate normalized values necessary for output calc
	vec4 viewNormal = normalize(gPosition);
	vec4 surfaceNormal = normalize(gNormal);
	// Calculate light vector
	vec4 lightVector = vec4(vec3(passedLight.worldPos - gPosition), 1.0);

	// Calculate diffuse & specular coefficients
	float diffuseCoeff = diffuseCalculation(surfaceNormal, passedLight.worldPos);
	float specularCoeff = specularCalculation(surfaceNormal, passedLight.worldPos, passedLight.viewPos);

	// Output specular & diffuse lights (should have no color on this pass)
	rtDiffuseLight = vec4(vec3(diffuseCoeff), 1.0);
	rtSpecularLight = vec4(vec3(specularCoeff), 1.0);
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