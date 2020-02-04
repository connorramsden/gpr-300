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

	drawNonphoto_multi_fs4x.glsl
	Draw nonphotorealistic shading model for multiple lights.
*/

#version 410

const int MAX_LIGHTS = 4;

in vec4 vModelViewNorm;
in vec4 vViewPos;
in vec2 vTexCoord;
const int CEL_SECTIONS = 6;

uniform sampler2D uTex_dm;
uniform int uLightCt;
uniform vec4 uLightPos[MAX_LIGHTS];
uniform vec4 uLightCol[MAX_LIGHTS];
uniform float uLightSz[MAX_LIGHTS];

out vec4 rtFragColor;

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
	outCol = ceil(outCol * CEL_SECTIONS);
	outCol /= CEL_SECTIONS;
	// Assign all Render Targets
	rtFragColor = vec4(outCol.xyz, 1.0);
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

