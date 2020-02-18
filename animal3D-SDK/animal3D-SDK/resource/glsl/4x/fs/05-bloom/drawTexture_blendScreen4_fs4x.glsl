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
	
	drawTexture_blendScreen4_fs4x.glsl
	Draw blended sample from multiple textures using screen function.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare inbound varying for texture coordinate
//	3) sample texture using texture coordinate
//	4) assign sample to output color

in vec2 vTexCoord; // Step 2

uniform sampler2D uTex_dm;
uniform sampler2D uImage00;	// Step 1
uniform sampler2D uImage01;	// Step 1
out vec4 rtFragColor;

// DBuckstein Slide Deck 5 (Bloom), pg. 32
vec4 screen(vec4 a, vec4 b) 
{
	return 1.0 - (1.0 - a) * (1.0 - b);
}

void main()
{
	vec4 firstSample = texture(uImage00, vTexCoord);
	vec4 secondSample = texture(uTex_dm, vTexCoord);

	vec4 composite = screen(firstSample, secondSample);

	rtFragColor = composite;
}
