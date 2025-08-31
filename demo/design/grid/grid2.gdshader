//shader_type canvas_item;
//
//uniform float grid_size = 32.0;
//uniform vec4 line_color:source_color = vec4(0.0, 1.0, 1.0, 1.0);
//uniform vec4 panel_color:source_color = vec4(1.0, 1.0, 1.0, 0.0);
//uniform vec4 hover_color:source_color = vec4(1.0, 0.9, 0.2, 0.15);
//uniform float line_thickness = 1.0;
//uniform float padding = 3.0; // kept for compatibility
//uniform vec2 mouse_pos = vec2(0.0, 0.0);
//
//void fragment() {
    //vec2 pos = VERTEX.xy;
//
    //// position inside current grid cell
    //vec2 cell_pos = mod(pos, grid_size);
//
    //// grid lines on both sides of the cell
    //float line_x = step(cell_pos.x, line_thickness) +
                   //step(grid_size - cell_pos.x, line_thickness);
    //float line_y = step(cell_pos.y, line_thickness) +
                   //step(grid_size - cell_pos.y, line_thickness);
    //float line = clamp(line_x + line_y, 0.0, 1.0);
//
    //// decide if this fragment shares the same cell index as the mouse
    //vec2 cell_id = floor(pos / grid_size);
    //vec2 mouse_id = floor(mouse_pos / grid_size);
    //vec2 eq = 1.0 - step(vec2(0.5), abs(cell_id - mouse_id));
    //float same_cell = eq.x * eq.y;
//
    //// base cell color with hover override
    //vec4 base = mix(panel_color, hover_color, same_cell);
//
    //// draw grid lines on top for crisp edges
    //COLOR = mix(base, line_color, line);
//}

shader_type canvas_item;

uniform float grid_size = 32.0;
uniform vec4 line_color : source_color = vec4(0.0, 1.0, 1.0, 1.0);
uniform vec4 panel_color : source_color = vec4(1.0, 1.0, 1.0, 0.0);
uniform vec4 highlight_color : source_color = vec4(0.0, 0.5, 1.0, 0.2);
uniform float line_thickness = 1.0;
uniform vec2 mouse_pos = vec2(0.0, 0.0);
uniform float pulse_speed = 2.0;

void fragment() {
    vec2 pos = VERTEX.xy;

    // --- grid line logic (same as before) ---
    vec2 cell_pos = mod(pos, grid_size);
    float line_x = step(cell_pos.x, line_thickness) +
                   step(grid_size - cell_pos.x, line_thickness);
    float line_y = step(cell_pos.y, line_thickness) +
                   step(grid_size - cell_pos.y, line_thickness);
    float line = clamp(line_x + line_y, 0.0, 1.0);


    // --- highlight logic ---
    // get the coordinate of the cell the mouse is in
    vec2 mouse_cell_coord = floor(mouse_pos / grid_size);
    // get the coordinate of the cell this pixel is in
    vec2 current_cell_coord = floor(pos / grid_size);

    // check if the current pixel is in the same cell as the mouse
    // float(all(equal(...))) is a glsl trick to turn a bool into 0.0 or 1.0
    float is_hovered = float(all(equal(current_cell_coord, mouse_cell_coord)));

    // create a smooth pulse from 0.0 to 1.0 using time
    // (sin(t) + 1.0) / 2.0 is a classic way to map [-1, 1] to [0, 1]
    float pulse = (sin(TIME * pulse_speed) + 1.0) / 2.0;

    // the final panel color is a mix between the base and the highlight
    // it will only be highlighted if is_hovered is 1.0
    vec4 final_panel_color =
        mix(panel_color, highlight_color, is_hovered * pulse);


    // --- final output ---
    // now mix the final panel color with the grid lines
    COLOR = mix(final_panel_color, line_color, line);
}