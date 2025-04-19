#version 460

#define CURVINESS 0.25

#define PI 3.1415926

in vec4 vertexColor;

flat in vec2 flatCorner;
in vec2 Pos1;
in vec2 Pos2;
in vec4 Coords;
in vec2 position;
in vec2 ScrSize;

uniform vec4 ColorModulator;
uniform vec2 ScreenSize;

out vec4 fragColor;

//Colors
vec4 colors[] = vec4[](
    vec4(0),
    vec4(161, 72, 162, 255) / 255,
    vec4(62, 71, 202, 255) / 255
);

void main() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }

    fragColor = color * ColorModulator;

    if (flatCorner != vec2(-1))
    {
        //Actual Pos
        vec2 APos1 = Pos1;
        vec2 APos2 = Pos2;
        APos1 = round(APos1 / (flatCorner.x == 0 ? 1 - Coords.z : 1 - Coords.w)); //Right-up corner
        APos2 = round(APos2 / (flatCorner.x == 0 ? Coords.w : Coords.z)); //Left-down corner

        ivec2 res = ivec2(abs(APos1 - APos2)) - 1; //Resolution of frame
        ivec2 stp = ivec2(min(APos1, APos2)); //Left-Up corner
        vec2 pos = vec2((position)) - stp; //Position in frame

        if (res.x <= 3 || res.y <= 3)
        {
            fragColor = vec4(0);
            return;
        }

        vec4 col = colors[1];

        vec2 corner = min(pos, res - pos + 1);

        float guiSize = ScreenSize.x / ScrSize.x;
        vec2 shifted = corner - (sin(corner.yx * CURVINESS + 1) + 1) / (guiSize * 2);

        if (shifted.x < 4 && shifted.y < 4)
        {
            float r = length(4 - shifted);
            if (r >= 3)
                discard;
            if (abs(r - 2.5) <= 0.5)
                col = colors[2];
        }

        else if (shifted.x - 1 < 0 || shifted.y - 1 < 0)
            discard;

        else if (abs(shifted.x - 1.5) <= 0.5 || abs(shifted.y - 1.5) <= 0.5)
            col = colors[2];

        fragColor = col;
    }
}
