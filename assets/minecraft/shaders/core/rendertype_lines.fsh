#version 150

#moj_import <fog.glsl>

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;

out vec4 fragColor;

void main() {
    if(vertexColor.r < 1.0 && vertexColor.g < 1.0 && vertexColor.b < 1.0 && vertexColor.a > 0.35 && vertexColor.a < 0.41) {
        fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        vec4 color = vertexColor * ColorModulator;
        fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
    }
}
