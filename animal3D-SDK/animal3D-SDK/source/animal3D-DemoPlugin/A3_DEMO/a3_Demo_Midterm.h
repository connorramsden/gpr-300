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

	a3_Demo_Midterm.h
	Demo mode interface: midterm shading.

	********************************************
	*** THIS IS ONE DEMO MODE'S HEADER FILE  ***
	********************************************
*/

#ifndef __ANIMAL3D_DEMO_MIDTERM_H
#define __ANIMAL3D_DEMO_MIDTERM_H


//-----------------------------------------------------------------------------

#include "animal3D/animal3D.h"


//-----------------------------------------------------------------------------

#ifdef __cplusplus
extern "C"
{
#else	// !__cplusplus
	typedef struct a3_Demo_Midterm						a3_Demo_Midterm;
	typedef enum a3_Demo_Midterm_RenderProgramName		a3_Demo_Midterm_RenderProgramName;
	typedef enum a3_Demo_Midterm_DisplayProgramName		a3_Demo_Midterm_DisplayProgramName;
	typedef enum a3_Demo_Midterm_ActiveCameraName		a3_Demo_Midterm_ActiveCameraName;
	typedef enum a3_Demo_Midterm_PipelineName			a3_Demo_Midterm_PipelineName;
	typedef enum a3_Demo_Midterm_TargetName				a3_Demo_Midterm_TargetName;
#endif	// __cplusplus


//-----------------------------------------------------------------------------

	// program to use for rendering
	enum a3_Demo_Midterm_RenderProgramName
	{
		midterm_renderSolid,		// solid color
		midterm_renderTexture,		// texture sample
		midterm_renderLambert,		// Lambert shading
		midterm_renderPhong,		// Phong shading
		midterm_renderNonphoto,		// nonphotorealistic shading

		midterm_render_max
	};

	// program to use for display
	enum a3_Demo_Midterm_DisplayProgramName
	{
		midterm_displayTexture,
		midterm_displayTextureManipColor,
		midterm_displayTextureManipTexcoord,

		midterm_display_max
	};

	// active camera names
	enum a3_Demo_Midterm_ActiveCameraName
	{
		midterm_cameraSceneViewer,	// scene viewing camera

		midterm_camera_max
	};


	// midterm pipeline names
	enum a3_Demo_Midterm_PipelineName
	{
		midterm_back,				// on-screen rendering with back buffer
		midterm_fbo,				// off-screen rendering with MRT FBO

		midterm_pipeline_max
	};

	// render target names
	enum a3_Demo_Midterm_TargetName
	{
		midterm_back_composite = 0,	// final composite color
		midterm_target_back_max,

		midterm_fbo_composite = 0,	// final composite color
		midterm_fbo_position,		// position attribute
		midterm_fbo_normal,			// normal attribute
		midterm_fbo_texcoord,		// texcoord attribute
		midterm_fbo_diffuseTex,		// diffuse texture sample
		midterm_fbo_specularTex,	// specular texture sample
		midterm_fbo_diffuseLight,	// diffuse light total
		midterm_fbo_specularLight,	// specular light total
		midterm_fbo_fragdepth,		// fragment depth
		midterm_target_fbo_max,
	};


//-----------------------------------------------------------------------------

	// demo mode for basic shading
	struct a3_Demo_Midterm
	{
		a3_Demo_Midterm_RenderProgramName render;
		a3_Demo_Midterm_DisplayProgramName display;
		a3_Demo_Midterm_ActiveCameraName activeCamera;

		a3_Demo_Midterm_PipelineName pipeline;
		a3_Demo_Midterm_TargetName targetIndex[midterm_pipeline_max], targetCount[midterm_pipeline_max];
	};


//-----------------------------------------------------------------------------


#ifdef __cplusplus
}
#endif	// __cplusplus


#endif	// !__ANIMAL3D_DEMO_MIDTERM_H