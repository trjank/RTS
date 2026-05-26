@tool
class_name PlanetGenerator extends EditorScript

# NOTE: You can right click this script and select "Run" to generate a mesh

const HEIGHT_MAP_SCALE := 300.0
const RESOLUTION_LOW := 64
const RESOLUTION_MEDIUM := 128
const RESOLUTION_HIGH := 256
# NOTE: Ensure this file does not already exist (the script will not overwrite)
const EXPORT_PATH := "res://map/planet/generated_mesh.res"

static func generate_icosphere(resolution: int, radius: float) -> IcoSphereMesh:
	var icosphere := IcoSphereMesh.new()
	icosphere.radius = radius
	icosphere.heigth = radius * 2
	icosphere.edge_count = resolution
	return icosphere

static func _raise_vertex(vertex: Vector3, height_variation: float, height_map: FastNoiseLite, color_ramp: Gradient) -> Vector3:
	var xy = Vector3(0.5, 0.5, 0.5) + 0.5 * vertex.normalized()
	var v_noise := 0.5 + 0.5 * height_map.get_noise_3dv(HEIGHT_MAP_SCALE * xy)
	v_noise = color_ramp.sample(v_noise).r
	return vertex * (1.0 + height_variation * v_noise)

static func generate_mesh(resolution: int, radius: float, height_variation: float, height_map: FastNoiseLite, color_ramp: Gradient) -> Mesh:
	var sphere_mesh := generate_icosphere(resolution, radius)
	var arrays := sphere_mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	#
	for i in vertices.size():
		vertices[i] = _raise_vertex(vertices[i], height_variation, height_map, color_ramp)
	#
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var st := SurfaceTool.new()
	st.create_from_arrays(arrays, Mesh.PRIMITIVE_TRIANGLES)
	st.generate_normals()
	st.generate_tangents()
	return st.commit()

## This gives the mesh a stylized look, so low resolutions do not look blurry
static func make_low_poly(mesh: Mesh) -> ArrayMesh:
	var st := SurfaceTool.new()
	var arrays := mesh.surface_get_arrays(0)
	var vertices = arrays[Mesh.ARRAY_VERTEX]
	var indices = arrays[Mesh.ARRAY_INDEX]
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	#
	for i in indices:
		st.set_smooth_group(-1)
		st.add_vertex(vertices[i] )
	#
	st.generate_normals()
	st.generate_tangents()
	return st.commit()

func _run() -> void:
	var resolution := RESOLUTION_HIGH
	var radius := 1.0
	var height_variation := 0.02
	var height_map := preload("res://map/moon/crater_height_map.tres")
	var color_ramp := preload("res://map/moon/crater_color_ramp.tres")
	#
	var mesh := generate_mesh(resolution, radius, height_variation, height_map, color_ramp)
	mesh = make_low_poly(mesh)
	ResourceSaver.save(mesh, EXPORT_PATH)
	print("(PlanetGenerator) Exported mesh to %s" % EXPORT_PATH)
