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
	
	passTexcoord_transform_vs4x.glsl
	Vertex shader that passes texture coordinate. Outputs transformed position 
		attribute and atlas transformed texture coordinate attribute.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for MVP matrix; see demo code for hint
//	2) correctly transform input position by MVP matrix
//	3) declare texture coordinate attribute; see graphics library for location
//	4) declare atlas transform; see demo code for hint
//	5) declare texture coordinate outbound varying
//	6) correctly transform input texture coordinate by atlas matrix

layout (location = 0) in vec4 aPosition;
layout(location = 8) in vec4 aTexCoord; // Step 3 - take in texture coordinate in slot 8

uniform mat4 uMVP; // Step 1 - found in a3_DemoState_loading
uniform mat4 uAtlas; // Step 4 - found in a3_DemoState_loading

out vec4 vTexCoord; // Step 5 - outbound texture to be read into fragment shader

void main()
{
	gl_Position = uMVP * aPosition; // Step 2 - properly transform input position
	vTexCoord = uAtlas * aTexCoord; // Step 6 - transform texture coordinates by atlas matrix
}