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

	drawNonphoto_multi_mrt_fs4x.glsl
	Draw nonphotorealistic shading model for multiple lights with MRT output.
*/



// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement nonphotorealistic shading model
//	Note: test all data and inbound values before using them!
//	5) set location of final color render target (location 0)
//	6) declare render targets for each attribute and shading component

#version 410
const int MAX_LIGHTS = 4;
in vec4 vModelViewNorm;
in vec4 vViewPos;
in vec2 vTexCoord;
const int CEL_SECTIONS = 4;

uniform sampler2D uTex_dm;
uniform int uLightCt;
uniform vec4 uLightPos[MAX_LIGHTS];
uniform vec4 uLightCol[MAX_LIGHTS];
uniform float uLightSz[MAX_LIGHTS];

layout(location = 0) out vec4 rtFragColor;
layout(location = 1) out vec4 rtViewPos;
layout(location = 2) out vec4 rtViewNormal;
layout(location = 3) out vec4 rtTexCoord;
layout(location = 4) out vec4 rtDiffuseMap;
layout(location = 6) out vec4 rtDiffuseLightTotal;

vec4 getNormalizedLight(vec4 lightPos, vec4 objPos);
float getDiffuseCoeff(vec4 surfaceNorm, vec4 lightNorm);

void main()
{
	vec4 texDiffuse = texture(uTex_dm, vTexCoord);

	vec4 outCol;
	vec4 lightingTotal;

	vec4 surfaceNorm = normalize(vModelViewNorm);

	for (int i = 0; i < uLightCt; ++i) {
		vec4 lightNorm = getNormalizedLight(uLightPos[i], vViewPos);

		float diffuse = getDiffuseCoeff(surfaceNorm, lightNorm);

		lightingTotal += diffuse;

		vec4 lambert = diffuse * texDiffuse;
		outCol += lambert * uLightCol[i];
	}
	//black and white
	outCol = vec4(vec3((outCol.x + outCol.y + outCol.z) / 3), 1.0);
	outCol = floor(outCol * CEL_SECTIONS);
	outCol /= CEL_SECTIONS;
	// Assign all Render Targets
	rtFragColor = vec4(outCol.xyz, 1.0);
	rtViewPos = vec4(vViewPos.xyz, 1.0);
	rtViewNormal = vec4(surfaceNorm.xyz, 1.0);
	rtTexCoord = vec4(vTexCoord, 0.0, 1.0);
	rtDiffuseMap = vec4(texDiffuse.xyz, 1.0);
	rtDiffuseLightTotal = vec4(lightingTotal.xyz, 1.0);
}

// Returns normalized light vector (L_hat)
vec4 getNormalizedLight(vec4 lightPos, vec4 objPos)
{
	vec4 lightVec = lightPos - objPos;
	return normalize(lightVec);
}

// Returns the clamped dot product of the passed normal and light vector
// Make sure to pass normalized values in
float getDiffuseCoeff(vec4 surfaceNorm, vec4 lightNorm)
{
	return max(0.0, dot(surfaceNorm, lightNorm));
}
