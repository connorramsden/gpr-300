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

	drawPhong_multi_fs4x.glsl
	Draw Phong shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variables for textures; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Phong shading model
//	Note: test all data and inbound values before using them!

// Constants
const int MAX_LIGHTS = 4; // Set equal to # of lights in scene
// must have constant value to iterate over GLSL uniform arrays.
// https://www.khronos.org/opengl/wiki/Uniform_(GLSL)

// Inputs
in vec4 vModelViewNorm;	// Step 3
in vec4 vViewPos;		// Step 3
in vec4 vTexCoord;		// Step 3

uniform sampler2D uTex_dm;	// Step 1
uniform sampler2D uTex_sm;	// Step 1
uniform int uLightCt;						// Step 2
uniform vec4 uLightPos[MAX_LIGHTS];			// Step 2
uniform vec4 uLightCol[MAX_LIGHTS];			// Step 2
uniform float uLightSz[MAX_LIGHTS];			// Step 2
uniform float uLightSzInvSq[MAX_LIGHTS];	// Step 2

out vec4 rtFragColor;

// Returns normalized light vector
vec4 getNormalizedLight(vec4 lightPos, vec4 objPos);
// Returns the dot product of the passed normal and light vector
float getDiffuseCoeff(vec4 normal, vec4 lightVector);

void main()
{
	vec4 texDiffuse = texture2D(uTex_dm, vec2(vTexCoord));
	vec4 texSpecular = texture2D(uTex_sm, vec2(vTexCoord));

	// Jake Phong Attempt started phong by accident
	/*
		vec4 lightVec = uLightPos[i]-viewPos;
		vec4 lightVec_n = normalize(lightVec);
		vec4 diffuse = dot(modelViewNorm, lightVec_n) * uLightCol[i];
		vec4 reflection = (2 * dot(modelViewNorm, lightVec_n) * modelViewNorm) - lightVec_n;
		vec4 specular = viewPos - uLightPos[i];
	*/

	// Combined Jake & Connor Phong Attempt

	vec4 phong;

	for (int i = 0; i < uLightCt; ++i)
	{
		// Acquire normalized light vector and surface normal
		vec4 lightNorm = getNormalizedLight(uLightPos[i], vViewPos);
		vec4 surfaceNorm = normalize(vModelViewNorm);

		// Reflection found on DBuckstein SlideDeck2 pg. 13
		vec4 reflection = 2.0 * getDiffuseCoeff(surfaceNorm, lightNorm) * surfaceNorm - lightNorm;

		// Compute diffuse reflection (DBuckstein SlideDeck2 pg. 10&11)
		vec4 diffuse = getDiffuseCoeff(surfaceNorm, lightNorm) * texDiffuse;

		// Specular calculation found on DBuckstein SlideDeck2 pg. 14
		float specularCoeff = max(0.0, dot(normalize(vViewPos), reflection));
		vec4 specular = specularCoeff * specularCoeff * texSpecular;

		phong += (diffuse + specular) * uLightCol[i];
	}

	rtFragColor = phong;
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
