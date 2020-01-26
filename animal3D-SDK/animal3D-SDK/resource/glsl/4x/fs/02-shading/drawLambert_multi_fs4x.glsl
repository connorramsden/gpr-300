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

in vec4 modelViewNorm;
in vec4 viewPos;
in vec4 vTexCoord;

out vec4 rtFragColor;

uniform sampler2D uTex_dm;

uniform int uLightCt; //light count
uniform vec4 uLightPos[];
uniform vec4 uLightCol[];
uniform float uLightSz[];
uniform float uLightSzInvSq[];
//idle renderer, 459


//https://www.learnopengles.com/tag/lambertian-reflectance/
//http://www.opengl-tutorial.org/beginners-tutorials/tutorial-8-basic-shading/
//Used for help, but had to implement for animal3D, just helped me understand lambert model
void main()
{
	vec4 vert = texture2D(uTex_dm, vec2(vTexCoord));
	//https://stackoverflow.com/questions/41984724/calculating-angle-between-two-vectors-in-glsl

	//float angleTheta = clamp( dot(), 0,1);
	
	float lambert = 1.0;
	float color = 0.0f;
	for(int i = 0; i < uLightCt; i++)
	{
		//started phong by accident
		//vec4 lightVec = uLightPos[i]-viewPos;
		//vec4 lightVec_n = normalize(lightVec);
		//vec4 diffuse = dot(modelViewNorm, lightVec_n) * uLightCol[i];
		//vec4 reflection = (2 * dot(modelViewNorm, lightVec_n) * modelViewNorm) - lightVec_n;
		//vec4 specular = viewPos - uLightPos[i];

		vec4 lightVec = normalize(uLightPos[i] - viewPos);
		float distance = length(uLightPos[i] - viewPos);
		lambert = dot(modelViewNorm, lightVec);
		//float diffuse = lambert * (1.0 / (1.0 + (0.25 * distance * distance)));
		vec4 colorToAdd = uLightCol[i];
		color += colorToAdd;
	}
	
	rtFragColor = vec4(vec3(color),1.0);
}
