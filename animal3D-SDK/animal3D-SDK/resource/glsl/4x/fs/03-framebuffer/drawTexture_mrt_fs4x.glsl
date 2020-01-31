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
	
	drawTexture_mrt_fs4x.glsl
	Draw texture sample with MRT output.
*/

#version 410

// ****TO-DO: 
//	1) declare uniform variable for texture; see demo code for hints
//	2) declare inbound varying for texture coordinate
//	3) sample texture using texture coordinate
//	4) assign sample to output render target (location 0)
//	5) declare new render target (location 3) and output texcoord

in vec4 vModelViewNorm;
in vec4 vViewPos;
in vec2 vTexCoord;

uniform sampler2D uTex_dm;

// lab 3
layout(location = 0) out vec4 rtFragColor;
layout(location = 1) out vec4 rtViewPos;
layout(location = 2) out vec4 rtViewNormal;
layout(location = 3) out vec4 rtTexCoord;
layout(location = 4) out vec4 rtDiffuseMap;
layout(location = 5) out vec4 rtSpecularMap;
layout(location = 6) out vec4 rtDiffuseLightTotal;
layout(location = 7) out vec4 rtSpecularLightTotal;

void main()
{
	// lab 2
	vec4 texDiffuse = texture(uTex_dm, vTexCoord);
	vec4 surfaceNorm = normalize(vModelViewNorm);
	
	rtFragColor = texDiffuse; // Sample texture to Final Color Render Target
	rtViewPos = vec4(vViewPos.xyz, 1.0);
	rtViewNormal = vec4(surfaceNorm.xyz, 1.0) ;
	rtTexCoord = vec4(vTexCoord, 0.0, 1.0);
	rtDiffuseMap = vec4(texDiffuse.xyz, 1.0);
	//rtDiffuseLightTotal = vec4(0.0, 0.0, 0.0, 1.0); //blank (black) for this mode
	//rtSpecularMap = vec4(0.0, 0.0, 0.0, 1.0);
	//rtSpecularLightTotal = vec4(0.0, 0.0, 0.0, 1.0); //blank (black) for this mode

}
