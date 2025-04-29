#version 150

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>
#moj_import <eg_custom_leash:leash_texture.glsl>

#define VANILLA_LEASH_COLOUR_1 vec3(0.498039, 0.4, 0.298039)
#define VANILLA_LEASH_COLOUR_2 vec3(0.34902, 0.278431, 0.207843)

in vec3 Position;
in vec4 Color;
in ivec2 UV2;

uniform sampler2D Sampler2;

out float vertexDistance;
flat out vec4 vertexColor;

out vec4 adjustments;
#if USE_SIMPLE_COLOURS == 0
    out vec2 texCoord;
#endif
flat out int isLeash;

bool rougheq(vec3 color, vec3 target) {
    return all(lessThan(abs(color-target),vec3(0.0001)));
}

void main() {
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);

    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color;
    adjustments = ColorModulator * texelFetch(Sampler2, UV2 / 16, 0);
    isLeash = 0;

    #if USE_SIMPLE_COLOURS == 1
        if(rougheq(Color.rgb, VANILLA_LEASH_COLOUR_1)) {
            vertexColor.rgb = COLOUR_1;
        } else if(rougheq(Color.rgb, VANILLA_LEASH_COLOUR_2)) {
            vertexColor.rgb = COLOUR_2;
        }
    #else
        isLeash = (rougheq(Color.rgb, VANILLA_LEASH_COLOUR_1) || rougheq(Color.rgb, VANILLA_LEASH_COLOUR_2)) ? 1 : 0;
        if(isLeash <= 0) return;

        bool otherHalf = mod(gl_VertexID, 100.0) > 49.0;
        // calculate horizontal texture coordinates
        texCoord = vec2(0.0);
        texCoord.x = mod(gl_VertexID / 2, 25) / 25.0;
        if(otherHalf && MIRROR_ONE_HALF == 0) {
            // offset and inverse the x for the other half of the lead
            texCoord.x = 1 - (texCoord.x + (2.0/50.0));
        }
        // calculate vertical texture coordinates
        texCoord.y = mod(gl_VertexID + (otherHalf ? 1 : 0), 2);
    #endif
}
