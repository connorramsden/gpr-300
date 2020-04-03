# README for Graphics 2 Midterm Submission

## Project Overview
This project provided students a deeper understanding of the ins and outs of a graphics engine, as well as the creation and subsequent rendering of from-the-ground-up shaders. 

## Team Members
* [Connor Ramsden](https://github.com/connorramsden)
    * Engineering and Pipeline Management (C/C++ Side)
* [Jake Rose](https://github.com/Jacob-Rose)
    * Shader Conception and Creation (GLSL Side)

## Project Description and Outcomes
This project features a fully-realized Animal3D pipeline built from the ground up. This pipeline is integrated into the graphics engine in order to provide the team with full control over their custom shaders. Everything from the texture importing to text rendering is handled succinctly, following the established Animal3D standards and workflow.

In addition to these engineering features, the project showcases a few custom shaders:
* A lava-lamp style effect, with splotches of generated noise and polygonal manipulation for a moving, swirling effect
* Other shaders ....

The outcomes of this project left the team members with a greater understanding of Animal3D from an engineering standpoint, as well as greater confidence in creating shaders without any guidance or instructions.

## Justification of Requirements
The shaders featured within this project satisfy, at a minimum, two of the required graphics effects. The lava-lamp shader features an intermediate real-time effect, which can be justified by the use of perlin noise generation and texturing that does not apply uniformly across objects.

This shader has not been completed for any prior courses, and all rendering is done via shaders and VBOs. No 'immediate mode' graphics are utilized, and there are custom vertex and fragment shaders in the effects implementation. Rendering is performed off-screen via FBOs, and phong-style lighting is featured within the shader alongside the effect. The motion in the scene is performed along a curve, fulfilling the final requirement. 