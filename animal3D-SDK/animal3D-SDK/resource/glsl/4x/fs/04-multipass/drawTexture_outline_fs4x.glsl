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
in vec4 vNormal;

out vec4 rtFragColor;

//textures (THIS IS A POST PROCESS EFFECT, USE THESE FOR CRITICAL INFO)
uniform sampler2D uTex_dm; // Step 1 - found in a3_DemoState_loading
uniform sampler2D uTex_sm; //depth map
uniform sampler2D uTex_nm; //normal map

//my uniforms
uniform float outlineThickness = 0.0005;
uniform vec3 outlineColor = vec3(0.5, 0.75, 1.0);
uniform float _DepthThreshold = 0.2;
uniform float _NormalThreshold = 0.4;

float getEdgeDepth();
float getEdgeNormal();

void main()
{

	vec4 vert = texture2D(uTex_dm, vTexCoord); // Step 3 - sampling texture by casting texcoord to vec2
	//https://gist.github.com/xoppa/33589b7d5805205f8f08
	//https://roystan.net/articles/outline-shader.html
	float edge = max(getEdgeDepth(), getEdgeNormal());
	if(edge > 0.9)
	{
		vert = vec4(outlineColor, 1.0);
	}
	rtFragColor = vert; // Step 4 - assigning sample to output
}

float getEdgeDepth()
{
	float depth2 = texture(uTex_sm, vTexCoord + vec2(outlineThickness, -outlineThickness)).r;
	float depth3 = texture(uTex_sm, vTexCoord + vec2(-outlineThickness, outlineThickness)).r;
	float depth0 = texture(uTex_sm, vTexCoord + vec2(outlineThickness)).r;
	float depth1 = texture(uTex_sm, vTexCoord - vec2(outlineThickness)).r;

	float depthFiniteDifference0 = depth1 - depth0;
	float depthFiniteDifference1 = depth3 - depth2;
	float edgeDepth = sqrt(pow(depthFiniteDifference0, 2) + pow(depthFiniteDifference1, 2)) * 100;
	float depthThreshold = _DepthThreshold * depth0;
	edgeDepth = edgeDepth > depthThreshold ? 1 : 0;
	return edgeDepth;
}

float getEdgeNormal()
{
	vec3 normal2 = texture(uTex_nm, vTexCoord + vec2(outlineThickness, -outlineThickness)).rgb;
	vec3 normal3 = texture(uTex_nm, vTexCoord + vec2(-outlineThickness, outlineThickness)).rgb;
	vec3 normal0 = texture(uTex_nm, vTexCoord + vec2(outlineThickness)).rgb;
	vec3 normal1 = texture(uTex_nm, vTexCoord - vec2(outlineThickness)).rgb;

	vec3 normalFiniteDifference0 = (normal1 - normal0);
	vec3 normalFiniteDifference1 = (normal3 - normal2);

	float edgeNormal = sqrt(dot(normalFiniteDifference0, normalFiniteDifference0) + dot(normalFiniteDifference1, normalFiniteDifference1));
	edgeNormal = edgeNormal > _NormalThreshold ? 1 : 0;

	return edgeNormal;
}