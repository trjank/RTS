shader_type canvas_item;


uniform float grid = 32.0;
uniform float big_grid_size = 288;
uniform vec4 line_color:source_color = vec4(0.0, 1.0,1.0, 1.0);
uniform vec4 big_line_color:source_color = vec4(0.0,1.0,1.0,1.0);
uniform vec4 panel_color:source_color = vec4(1.0,1.0,1.0,0);
uniform float thickness = 1.0;
uniform float padding = 3.0;
uniform vec2 mouse_pos = vec2(0.0,0.0);
varying vec2 position;

float make_grid(vec2 pos, float grid_size, float line_thickness){
 vec2 cell_pos = mod(pos, grid_size);//alpha channel the grid should be from the left side
 float line_x = step(cell_pos.x, line_thickness) + step(grid_size - cell_pos.x, line_thickness);
	//alpha channel the grid should be from the left side
 float line_y = step(cell_pos.y, line_thickness) + step(grid_size - cell_pos.y, line_thickness); 
float line = clamp(line_x + line_y, 0.0, 1.0);
return line;
}

void vertex(){
	  position = (CANVAS_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy ;
}

void fragment() {
	COLOR = texture(TEXTURE,UV);

	//we want to compare the mouse position with the position.
	float line = make_grid(position, grid, thickness);
	float big_line = make_grid(position, big_grid_size, thickness*2.0);
    // output either line color or panel color
    COLOR = mix(panel_color,line_color, line);
	COLOR = mix(COLOR, line_color, big_line);
	//COLOR = mix(COLOR, line_color, line);
	//COLOR = mix(COLOR, panel_color, 1);

	
}