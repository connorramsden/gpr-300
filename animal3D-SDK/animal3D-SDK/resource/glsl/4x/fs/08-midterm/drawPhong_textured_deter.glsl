#version 410

layout (location = 0) out vec4 rtFragColor;

in vec4 vViewPos; 
in vec4 vModelViewNorm;
in vec2 vTexCoord;
in vec4 vShadowCoord; // Step 2

uniform sampler2D uTex_dm, uTex_sm;


//http://www.science-and-fiction.org/rendering/noise.html
float rand2D(in vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}
float rand3D(in vec3 co){
    return fract(sin(dot(co.xyz ,vec3(12.9898,78.233,144.7272))) * 43758.5453);
}

float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = rand2D(i);
    float b = rand2D(i + vec2(1.0, 0.0));
    float c = rand2D(i + vec2(0.0, 1.0));
    float d = rand2D(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}


void main()
{
	// DUMMY OUTPUT: all fragments are OPAQUE GREEN
    float n = rand2D(vViewPos.xy);
	//rtFragColor = vec4(texture(uTex_dm, vTexCoord).xyz , 1.0);
    //rtFragColor = vec4(1.0, 1.0, 0.0, 1.0);
    rtFragColor = vec4(1.0 * n, 0.0,0.0,1.0);
}