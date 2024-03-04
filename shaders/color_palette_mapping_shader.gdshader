shader_type canvas_item;

uniform sampler2D palette;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec4 rgba = texture(TEXTURE, UV);
	vec4 palette_color = texture(palette, vec2(rgba.r, rgba.g));
	palette_color.a = rgba.a;
	
	COLOR = palette_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
