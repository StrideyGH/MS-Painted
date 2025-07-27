float spherical_distance(mat4 modelViewMat, vec3 pos) {
  return length((modelViewMat * vec4(pos, 1.0)).xyz);
}

bool rougheq(vec4 color, vec4 target) {
  // creds: godlander
  return all(lessThan(abs(color-target),vec4(0.0001)));
}