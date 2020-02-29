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
	
	drawOverlays_tangents_wireframe_gs4x.glsl
	Draw tangent bases of vertices and faces, and/or wireframe shapes, 
		based on flag passed to program.
*/

#version 430

// (2 verts/axis * 3 axes/basis * (3 vertex bases + 1 face basis) + 4 or 8 wireframe verts = 28 or 32 verts)
#define MAX_VERTICES 32

// ****TO-DO: 
//	1) add input layout specifications
//	2) receive varying data from vertex shader
//	3) declare uniforms: 
//		-> projection matrix (inbound position is in view-space)
//		-> optional: wireframe color (can hard-code)
//		-> optional: size of tangent bases (ditto)
//		-> optional: flags to decide whether or not to draw bases/wireframe
//	4) declare output layout specifications
//	5) declare outbound color
//	6) draw tangent bases
//	7) draw wireframe

// (1) layout qualifier for incoming primitive type
layout (triangles) in;

// (2) Receiving varying data
in vbVertexData {
	mat4 vTangentBasis_view;
	vec4 vTexcoord_atlas;
	flat int vVertexID, vInstanceID, vModelID;
} vVertexData[]; // give a name and make unsized array (this one has 3 elems b/c triangle)

// (3) Wireframe color
uniform vec4 uColor;
// (3) Size of Tangent Bases
uniform float uSize;
// (3) Overlay Flag
uniform int uFlag; // 2 == WireFrame, 1 == Tangent Bases
// (3) Projection Matrix
uniform mat4 uP;

// (4) Define primitive type we are outputting
// Takes two parameters: output type, and num vertices to output
layout (line_strip, max_vertices = MAX_VERTICES) out;

// (5) Declare outbound color
out vec4 vColor; // (taken from drawColorAttrib_fs4x.glsl)

// Converts triangles into lines
void drawWireFrame()
{	
	// NOTE: EmitVertex(); == 'this vertex is done, ship it'
	
	gl_Position = gl_in[0].gl_Position; // set position to vertex[0]'s position
	EmitVertex();
	gl_Position = gl_in[1].gl_Position; // set position to vertex[0]'s position
	EmitVertex();
	gl_Position = gl_in[2].gl_Position; // set position to vertex[0]'s position
	EmitVertex();
	gl_Position = gl_in[0].gl_Position; // set position to vertex[0]'s position
	EmitVertex();
	EndPrimitive(); // we have finished drawing sick shapes, don't draw anymore

	// NOTHING DRAWS UNTIL YOU HAVE NUM VERTICES YOU NEED
}

// Converts triangles into tangent bases
void drawTangentBases()
{
	// Perform operations on each vertex (we're dealing with triangles, hence 3)
	for(int i = 0; i < 3; ++i)
	{
		mat4 tangentBasis_view = mat4(
		normalize(vVertexData[i].vTangentBasis_view[0]),
		normalize(vVertexData[i].vTangentBasis_view[1]),
		normalize(vVertexData[i].vTangentBasis_view[2]),
		vVertexData[i].vTangentBasis_view[3]
		);
	}
}

void main()
{
	vColor = uColor; // color of line to draw

	if(uFlag == 2){
		drawWireFrame();
	} else if(uFlag == 1) {
		drawTangentBases();
	}
}
