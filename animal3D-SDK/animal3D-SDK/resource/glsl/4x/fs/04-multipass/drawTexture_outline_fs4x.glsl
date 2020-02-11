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
	
	drawTexture_outline_fs4x.glsl
	Draw texture sample with outlines.
*/

#version 410

in vec2 vTexCoord; // Step 2 - inbound texture coordinate
in vec4 vViewPos;
in vec4 vModelViewNorm;
layout(location = 2) in vec4 normal;

out vec4 rtFragColor;

uniform sampler2D uTex_dm; // Step 1 - found in a3_DemoState_loading
uniform float outlineThickness = 0.005;
uniform vec3 outlineColor = vec3(0.5, 0.75, 1.0);

void main()
{

	vec4 vert = texture2D(uTex_dm, vTexCoord); // Step 3 - sampling texture by casting texcoord to vec2
	//https://gist.github.com/xoppa/33589b7d5805205f8f08
	/*
	if (vert.a < 0.5f && dot(vViewPos.xyz, vModelViewNorm.xyz) < outlineThickness)
	{
		float a = 0;
		a += texture2D(uTex_dm, vTexCoord + vec2(0, outlineThickness)).a;
		a += texture2D(uTex_dm, vTexCoord + vec2(0, -outlineThickness)).a;
		a += texture2D(uTex_dm, vTexCoord + vec2(outlineThickness, 0)).a;
		a += texture2D(uTex_dm, vTexCoord + vec2(-outlineThickness, 0)).a;
		if (a/4.0 > 0.01f)
		{
			vert = vec4(outlineColor, 1.0);
		}
	}
	*/
	float facingPercentage = clamp(dot(vModelViewNorm, normal), 0, 1);
	
	vert = vert * facingPercentage;
	//vert = vert * facingPercentage + vec4(outlineColor, 1.0) * (1-facingPercentage);
	//vert = vec4(exp(dot(vec3(0,0,1), normal.xyz)) * outlineColor, 1.0);
	rtFragColor = vert; // Step 4 - assigning sample to output
}
