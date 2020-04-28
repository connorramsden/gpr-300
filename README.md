# README for Graphics 2 Final Submission

## Project Overview

This project provided students with a better understanding of the optimizations that go into creating a graphics framework. The goal of the project was to provide additional optimizations to the existing shader creation and implementation pipeline within Animal3D.

A side goal of the project is to help define similarities between Animal and other engines, spotting isomorphic systems between Animal and Unity

## Team Members

* [Connor Ramsden](https://github.com/connorramsden)
  * Various Engine loading optimizations
  * a3_DemoState_loading - loopification of various hard-coded structures related to model & texture loading
  * a3_Demo_idle-render - Optimized object, texture, and model loading utilizing Jake's new data structures
* [Jake Rose](https://github.com/Jacob-Rose)
  * Implementation of new data structures for shader-loading optimization
  * a4_SceneModel - contains model and texture  - similar to mesh renderer in unity
  * a4_texture - contains all textures - similar to material in unity
  * a4_shaderProgram - contains each program as a whole to keep the information contained and easier to edit

## Project Description and Outcomes

This project focused on optimizing the existing Animal3D engine in order to simplify the loading of objects. Objects now contain references to their own meshes, textures, and objects. This lowers the overall amount of code it takes to place models within the scene and texture them. Additional optimizations were done via loops to reduce the amount of hard-coding done in the pipeline.

Each object is stored in a new struct and can be referenced in these new loops rather than being indiviually accessed and loaded into the pipeline.

The outcomes of this project left the team members with a much simpler-to-use Animal3D from an "consumer" standpoint. It also left the team with a greater understanding of the existing optimizations that have been made in the creation of Animal3D.

## Justification of Requirements

This project meets the requirement of doing an engineering-based project for our final assignment. We focused primarily on making Animal3D easier to use, as explained above. New comments, optimized loops, and more easily-located loading structures all make the pipeline easier for 'consumers' to work within Animal3D. We believe that everything is in a place that makes sense relative to its place within the loading pipeline, and like-objects (textures, objects, models, etc.) are all located beside one another rather than in various places throughout the engine.
