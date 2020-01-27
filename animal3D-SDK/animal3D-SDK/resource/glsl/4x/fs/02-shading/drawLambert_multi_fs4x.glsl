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

	drawLambert_multi_fs4x.glsl
	Draw Lambert shading model for multiple lights.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare uniform variables for lights; see demo code for hints
//	3) declare inbound varying data
//	4) implement Lambert shading model
//	Note: test all data and inbound values before using them!

// Constants
const int MAX_LIGHTS = 4; // Set equal to # of lights in scene
// must have constant value to iterate over GLSL uniform arrays. 
// https://www.khronos.org/opengl/wiki/Uniform_(GLSL)

// Inputs
in vec4 vModelViewNorm;			// Step 3
in vec4 vViewPos;				// Step 3
in vec4 vTexCoord;				// Step 3

// Uniforms
uniform sampler2D uTex_dm;		// Step 1
uniform int uLightCt;			// light count
uniform vec4 uLightPos[MAX_LIGHTS];		// Step 2
uniform vec4 uLightCol[MAX_LIGHTS];		// Step 2
uniform float uLightSz[MAX_LIGHTS];		// Step 2
uniform float uLightSzInvSq[MAX_LIGHTS];  // Step 2
// idle renderer, 459

// Outputs
out vec4 rtFragColor;

// https://www.learnopengles.com/tag/lambertian-reflectance/
// http://www.opengl-tutorial.org/beginners-tutorials/tutorial-8-basic-shading/
// Used for help, but had to implement for animal3D, just helped me understand lambert model
// https://en.wikipedia.org/wiki/Lambertian_reflectance - helped with understanding the Lambertian diffuse calculation
void main()
{
	vec4 outTex = texture2D(uTex_dm, vec2(vTexCoord)); // sample incoming texture

	// Jake Lambert Attempt
	// vec4 lightVec = normalize(uLightPos[i] - viewPos);
	// float distance = length(uLightPos[i] - viewPos);
	// lambert = dot(modelViewNorm, lightVec);
	// float diffuse = lambert * (1.0 / (1.0 + (0.25 * distance * distance)));
	// vec4 colorToAdd = uLightCol[i];
	// color += colorToAdd;

	vec4 sumCol;

	for(int i = 0; i < uLightCt; ++i) 
	{
		// Need to acquire POINT (is it vTexCoord??)
		vec4 lightVec = uLightPos[i] - vTexCoord; // Calculate the light vector
		vec4 lightVec_n = normalize(lightVec); // Normalize the light vector
		// Need to calculate SURFACE NORMAL
		float diffuse = dot(outTex, lightVec_n); // Calculate the diffuse

		sumCol += diffuse;
	}

	vec4 outCol = clamp(sumCol * outTex, 0, 1);

	rtFragColor = outCol;
}