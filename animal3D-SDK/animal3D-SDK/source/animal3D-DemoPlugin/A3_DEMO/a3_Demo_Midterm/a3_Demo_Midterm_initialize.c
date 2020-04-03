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

	a3_Demo_Midterm_initialize.c
	Demo mode implementations: midterm initialization.

	********************************************
	*** INITIALIZATION FOR MIDTERM DEMO MODE ***
	********************************************
*/

//-----------------------------------------------------------------------------

#include "../a3_Demo_Midterm.h"

typedef struct a3_DemoState a3_DemoState;
// #include "../a3_DemoState.h"


//-----------------------------------------------------------------------------

void a3midterm_init(a3_DemoState const* demoState, a3_Demo_Midterm* demoMode)
{
	demoMode->render = midterm_renderSolid;
	demoMode->display = midterm_displayTexture;
	demoMode->activeCamera = midterm_cameraSceneViewer;

	demoMode->pipeline = midterm_back;

	demoMode->targetIndex[midterm_back] = midterm_back_composite;
	demoMode->targetIndex[midterm_fbo] = midterm_fbo_composite;

	demoMode->targetCount[midterm_back] = midterm_target_back_max;
	demoMode->targetCount[midterm_fbo] = midterm_target_fbo_max;
}


//-----------------------------------------------------------------------------
