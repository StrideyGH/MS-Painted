#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;

uniform vec4 ColorModulator;
uniform float FogStart;
uniform float FogEnd;
uniform vec4 FogColor;

in float vertexDistance;
in vec4 vertexColor;
in vec2 texCoord0;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    if (color.a < 0.1) {
        discard;
    }
	
	if (vertexDistance > 800.0 && color.r > 0.2479 && color.r < 0.2481) color = vec4(0.498, 0.498, 0.498, 1.0);
	if (vertexDistance > 800.0 && color.g > 0.6587 && color.g < 0.6589 && color.g != color.b) color = vec4(0.133, 0.694, 0.298, 1.0);
	if (vertexDistance > 800.0 && color.b > 0.9881 && color.b < 0.9883 && color.b != color.r) color = vec4(0.243, 0.278, 0.792, 1.0);
	if (vertexDistance > 800.0 && color.g > 0.9881 && color.g < 0.9883 && color.g != color.b) color = vec4(1.0, 0.949, 0.0, 1.0);
	if (vertexDistance > 800.0 && color.r > 0.9881 && color.r < 0.9883 && color.r != color.g) color = vec4(0.929, 0.110, 0.141, 1.0);
	if (vertexDistance > 800.0 && color.b > 0.6587 && color.b < 0.6589) color = vec4(1.0, 0.682, 0.788, 1.0);
	
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}