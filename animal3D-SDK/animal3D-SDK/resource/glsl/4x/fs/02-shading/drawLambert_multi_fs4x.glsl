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
in vec4 vModelViewNorm;					  // Step 3
in vec4 vViewPos;						  // Step 3
in vec4 vTexCoord;						  // Step 3

// Uniforms
uniform sampler2D uTex_dm;		          // Step 1
uniform int uLightCt;			          // light count
uniform vec4 uLightPos[MAX_LIGHTS];		  // Step 2
uniform vec4 uLightCol[MAX_LIGHTS];		  // Step 2
uniform float uLightSz[MAX_LIGHTS];		  // Step 2
uniform float uLightSzInvSq[MAX_LIGHTS];  // Step 2
// idle renderer, 459

// Outputs
out vec4 rtFragColor;

// Forward Decl. Functions
vec4 getNormalizedLight(vec4 lightPos, vec4 objPos);
float getDiffuseCoeff(vec4 surfaceNorm, vec4 lightNorm);

// https://www.learnopengles.com/tag/lambertian-reflectance/
// http://www.opengl-tutorial.org/beginners-tutorials/tutorial-8-basic-shading/
// Used for help, but had to implement for animal3D, just helped me understand lambert model
// https://en.wikipedia.org/wiki/Lambertian_reflectance - helped with understanding the Lambertian diffuse calculation
void main()
{
	// Jake Lambert Attempt
	// vec4 lightVec = normalize(uLightPos[i] - viewPos);
	// float distance = length(uLightPos[i] - viewPos);
	// lambert = dot(modelViewNorm, lightVec);
	// float diffuse = lambert * (1.0 / (1.0 + (0.25 * distance * distance)));
	// vec4 colorToAdd = uLightCol[i];
	// color += colorToAdd;

	// Combined Connor & Jake Attempt
	// sample incoming texture
	vec4 texDiffuse = texture(uTex_dm, vec2(vTexCoord));
	
	// Initialize output color
	vec4 sumCol;

	for (int i = 0; i < uLightCt; ++i)
	{
		// Light source - Surface Point (DBuckstein slides on Lighting & Shading 10 & 11)
		vec4 lightNorm = getNormalizedLight(uLightPos[i], vViewPos);
		// Need to normalize view model norm to get surface normal
		vec4 surfaceNorm = normalize(vModelViewNorm);

		// Calculate diffuse (dot product), clamp diffuse and apply texturing
		float diffuse = getDiffuseCoeff(surfaceNorm, lightNorm);
		vec4 lambert = diffuse * texDiffuse;

		// Add lambertian reflection and reflected surface color
		sumCol += lambert * uLightCol[i];
	}

	// Output calculated sum of colors
	rtFragColor = sumCol;
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