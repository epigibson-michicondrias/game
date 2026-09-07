shader_type spatial;
render_mode blend_add, depth_draw_opaque;

uniform sampler2D noise1;
uniform sampler2D noise2;

void fragment() {
    float n1 = texture(noise1, UV + TIME * 0.05).r;
    float n2 = texture(noise2, UV - TIME * 0.03).r;

    // Multiply noises for caustics effect
    float caustic = n1 * n2;

    // Project only on surfaces pointing mostly upwards
    vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;
    float up_mask = clamp(dot(world_normal, vec3(0.0, 1.0, 0.0)), 0.0, 1.0);

    ALBEDO = vec3(0.0, 1.0, 1.0) * caustic * up_mask * 2.0;
}
