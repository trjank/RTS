@tool
class_name PlanetGenerator extends EditorScript

# NOTE: You can right click this script and select "Run" to generate a mesh
const HEIGHT_MAP_SCALE  := 300.0
const RESOLUTION_LOW    := 32
const RESOLUTION_MEDIUM := 64
const RESOLUTION_HIGH   := 128
# NOTE: Ensure this file does not already exist (the script will not overwrite)
const EXPORT_PATH := "res://map/planet/generated_mesh.res"
# Parameters for _run() function
const RESOLUTION := RESOLUTION_MEDIUM
const RADIUS := 1.0
const HEIGHT_VARIATION := 0.02
const HEIGHT_MAP := preload("res://map/moon/crater_height_map.tres")
const COLOR_RAMP := preload("res://map/moon/crater_color_ramp.tres")

static func generate_icosphere(resolution: int, radius: float) -> IcoSphereMesh:
	var icosphere := IcoSphereMesh.new()
	icosphere.radius = radius
	icosphere.heigth = 2 * radius
	icosphere.edge_count = resolution
	return icosphere

static func generate_mesh(resolution: int, radius: float, height_variation: float, height_map: FastNoiseLite, color_ramp: Gradient) -> Mesh:
	var mesh := generate_icosphere(resolution, radius)
	var arrays := mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	#
	for i in vertices.size():
		vertices[i] = _raise_vertex(vertices[i], height_variation, height_map, color_ramp)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var st := SurfaceTool.new()
	st.create_from_arrays(arrays, Mesh.PRIMITIVE_TRIANGLES)
	st.generate_normals()
	return st.commit()

static func generate_lods(mesh: Mesh, normal_merge_angle := 45.0) -> Mesh:
	var importer_mesh := ImporterMesh.from_mesh(mesh)
	importer_mesh.generate_lods(normal_merge_angle, 0.0, [] )
	print("(PlanetGenerator) LODs generated: %d" % importer_mesh.get_surface_lod_count(0) )
	return importer_mesh.get_mesh()

static func _raise_vertex(vertex: Vector3, height_variation: float, height_map: FastNoiseLite, color_ramp: Gradient) -> Vector3:
	var xyz = Vector3(0.5, 0.5, 0.5) + 0.5 * vertex.normalized()
	var v_noise := 0.5 + 0.5 * height_map.get_noise_3dv(HEIGHT_MAP_SCALE * xyz)
	v_noise = color_ramp.sample(v_noise).r
	return vertex * (1.0 + height_variation * v_noise)

func _run() -> void:
	var mesh := generate_mesh(RESOLUTION, RADIUS, HEIGHT_VARIATION, HEIGHT_MAP, COLOR_RAMP)
	mesh = generate_lods(mesh)
	ResourceSaver.save(mesh, EXPORT_PATH)
	print("(PlanetGenerator) Exported mesh to %s" % EXPORT_PATH)
