#version 150

#moj_import <enchanted-games-custom-outlines/utils.glsl>
#moj_import <enchanted-games-custom-outlines/config.glsl>

#moj_import <minecraft:fog.glsl>
#moj_import <minecraft:globals.glsl>
#moj_import <minecraft:dynamictransforms.glsl>
#moj_import <minecraft:projection.glsl>

in vec3 Position;
in vec4 Color;
in vec3 Normal;

out float sphericalVertexDistance;
out float cylindricalVertexDistance;
out vec4 vertexColor;

/* -- modified for custom outlines -- */
flat out int CustomOutlinesLineType;
out float CustomOutlinesGradient;
out vec3 vertexPos;

out vec4 pos1;
out vec4 pos2;
flat out vec4 pos3;
/* -- -- */

const float VIEW_SHRINK = 1.0 - (1.0 / 256.0);
const mat4 VIEW_SCALE = mat4(
    VIEW_SHRINK, 0.0, 0.0, 0.0,
    0.0, VIEW_SHRINK, 0.0, 0.0,
    0.0, 0.0, VIEW_SHRINK, 0.0,
    0.0, 0.0, 0.0, 1.0
);

void main() {
  /* -- modified for custom outlines -- */
  sphericalVertexDistance = fog_spherical_distance(Position);
  cylindricalVertexDistance = fog_cylindrical_distance(Position);
  float vertexDistance = sphericalVertexDistance;
  vertexPos = Position;
  int id = gl_VertexID % 4;
  /* -- -- */

  vec4 linePosStart = ProjMat * VIEW_SCALE * ModelViewMat * vec4(Position, 1.0);
  vec4 linePosEnd = ProjMat * VIEW_SCALE * ModelViewMat * vec4(Position + Normal, 1.0);

  vec3 ndc1 = linePosStart.xyz / linePosStart.w;
  vec3 ndc2 = linePosEnd.xyz / linePosEnd.w;

  vec2 lineScreenDirection = normalize((ndc2.xy - ndc1.xy) * ScreenSize);

  /* -- modified for custom outlines -- */
  float newLineWidth = LineWidth;
  CustomOutlinesLineType = 0;
  if( rougheq( Color, vec4(0., 0., 0., 0.4) ) ) {
    // block selection outline
    newLineWidth = vertexDistance > 7 ? clamp(float(block_LINE_THICKNESS), 0.0, 1.0) : block_LINE_THICKNESS;
    CustomOutlinesLineType = 1;
  }
  else if( 
    rougheq( Color, vec4(1.) ) || // white lines
    ( hitbox_APPLY_TO_ALL_LINES && rougheq( Color, vec4(1.,0.,0.,1.) ) ) || // red lines
    ( hitbox_APPLY_TO_ALL_LINES && rougheq( Color, vec4(0.,0.,1.,1.) ) ) || // blue lines
    ( hitbox_APPLY_TO_ALL_LINES && rougheq( Color, vec4(1.,1.,0.,1.) ) ) // yellow lines
  ) {
    // entity hitbox (+ other white lines)
    newLineWidth = vertexDistance > 7 ? clamp(float(hitbox_LINE_THICKNESS), 0.0, 1.0) : hitbox_LINE_THICKNESS;
    CustomOutlinesLineType = 2;
  }
  else if( rougheq( Color, vec4(0.3412, 1.0, 0.8824, 1.0) ) ) {
    // high contrast block selection (inner)
    newLineWidth = vertexDistance > 7 ? clamp(float(hc_block_LINE_THICKNESS), 0.0, 1.0) : hc_block_LINE_THICKNESS;
    CustomOutlinesLineType = 3;
  }
  else if( rougheq( Color, vec4(0., 0., 0., 1.) ) && LineWidth <= 7.01 && LineWidth >= 6.99 ) {
    // high contrast block selection (outer)
    newLineWidth = vertexDistance > 7 ? clamp(float(hc_block_outer_LINE_THICKNESS), 0.0, 1.0) : hc_block_outer_LINE_THICKNESS;
    CustomOutlinesLineType = 4;
  }
  vec2 lineOffset = vec2(-lineScreenDirection.y, lineScreenDirection.x) * newLineWidth / ScreenSize;

  if(block_ANIMATE_ALONG_LINES || hitbox_ANIMATE_ALONG_LINES || hc_block_ANIMATE_ALONG_LINES || hc_block_outer_ANIMATE_ALONG_LINES) {
    CustomOutlinesGradient = float(id == 0 || id == 1);
  }
  /* -- -- */

  if (lineOffset.x < 0.0) {
    lineOffset *= -1.0;
  }

  /* -- modified for custom outlines -- */
  if (gl_VertexID % 2 == 0) {
    vertexPos = (ndc1 + vec3(lineOffset, 0.0)) * linePosStart.w;
    gl_Position = vec4(vertexPos, linePosStart.w);
  } else {
    vertexPos = (ndc1 - vec3(lineOffset, 0.0)) * linePosStart.w;
    gl_Position = vec4(vertexPos, linePosStart.w);
  }

  if( (CustomOutlinesLineType == 1 && block_IGNORES_DEPTH) || (CustomOutlinesLineType == 3 && hc_block_IGNORES_DEPTH) || (CustomOutlinesLineType == 4 && hc_block_outer_IGNORES_DEPTH) ) {
    gl_Position.z *= 0.01;
  }

  vertexColor = Color;

  // for line length calculations, credits: https://github.com/DartCat25
  pos1 = pos2 = vec4(0);
  pos3 = vec4(Position, id == 1);
  if (id == 0) pos1 = vec4(Position, 1);
  if (id == 2) pos2 = vec4(Position, 1);
  /* -- -- */
}