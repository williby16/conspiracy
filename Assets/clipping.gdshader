shader_type spatial;

uniform vec4 plane = vec4(1.0, 0.5, 0.0, 0.0);

bool culls(vec3 vertex, mat4 cam) {
	vec3 pos = (cam * vec4(vertex, 1.0)).xyz;
	return plane.x * pos.x
		+ plane.y * pos.y
		+ plane.z * pos.z
		+ plane.w < 0.0;
}

void fragment() {
	if (culls(VERTEX, INV_VIEW_MATRIX)) {
		discard;
	}
	ALBEDO = vec3(1.0, 0.0, 0.0);
}