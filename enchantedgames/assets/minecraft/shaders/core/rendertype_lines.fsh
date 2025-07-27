#version 150

#moj_import <enchanted-games-custom-outlines/utils.glsl>
#moj_import <enchanted-games-custom-outlines/config.glsl>

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:dynamictransforms.glsl>

in float sphericalVertexDistance;
in float cylindricalVertexDistance;
in vec4 vertexColor;

/* -- added for custom outlines -- */
flat in int CustomOutlinesLineType;
in float CustomOutlinesGradient;

in vec3 vertexPos;
in vec4 pos1;
in vec4 pos2;
flat in vec4 pos3;
/* -- -- */

out vec4 fragColor;

#define MIX_GRADIENT(colourArray, smoothMix, gradientAnim) mix(i == 0 ? colourArray[colourArray.length()-1] : gradient, colourArray[i], smoothMix ? smoothstep(_step, _step2, gradientAnim) : step(_step, gradientAnim))
#define GRADIENT_MIX(animAlongLines) animAlongLines ? CustomOutlinesGradient * lineLength : fragDistance / 2.0
#define GRADIENT_ANIMATION(animAlongLines, gradientMix, animWithDistance, animSpeed, animDirection, colourPeriod) fract( ( ( animAlongLines ? gradientMix : gradientMix * int(animWithDistance) ) + GameTime * animSpeed * animDirection ) / colourPeriod )

void main() {
  vec4 color = vertexColor * ColorModulator;

  vec3 pos = pos3.w == 0 ? pos1.xyz / pos1.w : pos2.xyz / pos2.w;
  float lineLength = round(length(pos - pos3.xyz) * 0x1000) / 0x1000;

  float fragDistance = length(vertexPos);
  vec4 gradient = color;

  // block selection
  if (CustomOutlinesLineType == 1) {
    if(block_COLOURS.length() <= 1) {
      gradient = block_COLOURS[0];
    }
    else{
      float gradientrender_GRADIENT_MIX = GRADIENT_MIX(block_ANIMATE_ALONG_LINES);
      float gradientrender_GRADIENT_ANIM = GRADIENT_ANIMATION(
        block_ANIMATE_ALONG_LINES,
        gradientrender_GRADIENT_MIX,
        block_ANIMATE_WITH_DISTANCE,
        block_ANIM_SPEED,
        block_ANIM_DIRECTION,
        block_COLOUR_PERIOD
      );

      float len = float(block_COLOURS.length());
      for(int i = 0; i < len; i++){
        float _step = block_SMOOTH_MIX ? i/len : (i+0.5)/len;
        float _step2 = block_SMOOTH_MIX ? (i+1.)/len : (i-0.5)/len;

        gradient = MIX_GRADIENT(block_COLOURS, block_SMOOTH_MIX, gradientrender_GRADIENT_ANIM);
      }
    }
  }
  
  // entity hitbox
  else if (CustomOutlinesLineType == 2) {
    if(hitbox_COLOURS.length() <= 1) {
      gradient = hitbox_COLOURS[0];
    }
    else{
      float gradientrender_GRADIENT_MIX = GRADIENT_MIX(hitbox_ANIMATE_ALONG_LINES);
      float gradientrender_GRADIENT_ANIM = GRADIENT_ANIMATION(
        hitbox_ANIMATE_ALONG_LINES,
        gradientrender_GRADIENT_MIX,
        hitbox_ANIMATE_WITH_DISTANCE,
        hitbox_ANIM_SPEED,
        hitbox_ANIM_DIRECTION,
        hitbox_COLOUR_PERIOD
      );

      float len = float(hitbox_COLOURS.length());
      for(int i = 0; i < len; i++){
        float _step = hitbox_SMOOTH_MIX ? i/len : (i+0.5)/len;
        float _step2 = hitbox_SMOOTH_MIX ? (i+1.)/len : (i-0.5)/len;

        gradient = MIX_GRADIENT(hitbox_COLOURS, hitbox_SMOOTH_MIX, gradientrender_GRADIENT_ANIM);
      }
    }
  }
  
  // high contrast block outline (inner)
  else if (CustomOutlinesLineType == 3) {
    if(hc_block_COLOURS.length() <= 1) {
      gradient = hc_block_COLOURS[0];
    }
    else{
      float gradientrender_GRADIENT_MIX = GRADIENT_MIX(hc_block_ANIMATE_ALONG_LINES);
      float gradientrender_GRADIENT_ANIM = GRADIENT_ANIMATION(
        hc_block_ANIMATE_ALONG_LINES,
        gradientrender_GRADIENT_MIX,
        hc_block_ANIMATE_WITH_DISTANCE,
        hc_block_ANIM_SPEED,
        hc_block_ANIM_DIRECTION,
        hc_block_COLOUR_PERIOD
      );

      float len = float(hc_block_COLOURS.length());
      for(int i = 0; i < len; i++){
        float _step = hc_block_SMOOTH_MIX ? i/len : (i+0.5)/len;
        float _step2 = hc_block_SMOOTH_MIX ? (i+1.)/len : (i-0.5)/len;

        gradient = MIX_GRADIENT(hc_block_COLOURS, hc_block_SMOOTH_MIX, gradientrender_GRADIENT_ANIM);
      }
    }
  }
  
  // high contrast block outline (outer)
  else if (CustomOutlinesLineType == 4) {
    if(hc_block_outer_COLOURS.length() <= 1) {
      gradient = hc_block_outer_COLOURS[0];
    }
    else{
      float gradientrender_GRADIENT_MIX = GRADIENT_MIX(hc_block_outer_ANIMATE_ALONG_LINES);
      float gradientrender_GRADIENT_ANIM = GRADIENT_ANIMATION(
        hc_block_outer_ANIMATE_ALONG_LINES,
        gradientrender_GRADIENT_MIX,
        hc_block_outer_ANIMATE_WITH_DISTANCE,
        hc_block_outer_ANIM_SPEED,
        hc_block_outer_ANIM_DIRECTION,
        hc_block_outer_COLOUR_PERIOD
      );

      float len = float(hc_block_outer_COLOURS.length());
      for(int i = 0; i < len; i++){
        float _step = hc_block_outer_SMOOTH_MIX ? i/len : (i+0.5)/len;
        float _step2 = hc_block_outer_SMOOTH_MIX ? (i+1.)/len : (i-0.5)/len;

        gradient = MIX_GRADIENT(hc_block_outer_COLOURS, hc_block_outer_SMOOTH_MIX, gradientrender_GRADIENT_ANIM);
      }
    }
  }
  
  if(gradient.a < 0.05) {
    discard;
  }
  color = gradient;

  fragColor = apply_fog(color, sphericalVertexDistance, cylindricalVertexDistance, FogEnvironmentalStart, FogEnvironmentalEnd, FogRenderDistanceStart, FogRenderDistanceEnd, FogColor);
}