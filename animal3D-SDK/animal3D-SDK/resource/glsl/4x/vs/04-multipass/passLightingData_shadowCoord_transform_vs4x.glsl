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
	
	passLightingData_shadowCoord_transform_vs4x.glsl
	Vertex shader that prepares and passes lighting data. Outputs transformed 
		position attribute and all others required for lighting. Also computes 
		and passes shadow coordinate.
*/

#version 410

// ****TO-DO: 
//	0) copy previous lighting data vertex shader //DONE
//	1) declare MVPB matrix for light
//	2) declare varying for shadow coordinate
//	3) calculate and pass shadow coordinate

layout(location = 0) in vec4 aPosition;
layout(location = 2) in vec4 normal; //Step 6
layout(location = 8) in vec4 aTexCoord; // Step 10

uniform mat4 uMV; //Step 1
uniform mat4 uP; //Step 4
uniform mat4 uMV_nrm; //Step 7
uniform mat4 uAtlas; // Step 10
uniform mat4 uMVPB;

out vec4 vViewPos; //Step 2
out vec4 vModelViewNorm; //Step 8
out vec2 vTexCoord; // Step 10
out vec4 vShadowCoord;

void main()
{
	vViewPos = uMV * aPosition; 
	vModelViewNorm = uMV_nrm * normal;
	vTexCoord = vec2(uAtlas * aTexCoord);
	vShadowCoord = uMVPB * aPosition;
	gl_Position = uP * vViewPos; 
}