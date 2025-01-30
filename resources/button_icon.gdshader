shader_type canvas_item;

uniform bool is_selected = false;

void fragment() {
    // Sample the texture color
    vec4 texture_color = texture(TEXTURE, UV);

    // If the icon is selected, invert the colors
    if (is_selected) {
        // Selected state: black paths on white background
        COLOR.rgb = vec3(0.0); // Set paths to black
        COLOR.a = texture_color.a; // Preserve the alpha for the paths
        // Set the background to white where the icon is transparent
        if (texture_color.a < 0.1) {
            COLOR.rgb = vec3(1.0); // White background
            COLOR.a = 1.0; // Fully opaque
        }
    } else {
        // Normal state: white path on transparent background
        COLOR = texture_color;
    }
}
