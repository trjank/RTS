class_name PlanetGenerator extends RefCounted

const HEIGHT_MAP_SCALE := 300.0
const RESOLUTION_LOW := 64
const RESOLUTION_MEDIUM := 128
const RESOLUTION_HIGH := 256

static func generate_icosphere(resolution: int, radius: float) -> IcoSphereMesh:
	var icosphere := IcoSphereMesh.new()
	icosphere.radius = radius
	icosphere.heigth = radius * 2
	icosphere.edge_count = resolution
	return icosphere

static func generate_mesh(resolution: int, radius: float, height_variation: float, height_map: FastNoiseLite, color_ramp: Gradient) -> Mesh:
	# Start with an unaltered sphere mesh
	var sphere_mesh := generate_icosphere(resolution, radius)
	var arrays := sphere_mesh.surface_get_arrays(0)
	var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
	# Apply height map to each vertex
	for i in vertices.size():
		var xy = Vector3(0.5, 0.5, 0.5) + 0.5 * vertices[i].normalized()
		var v_noise := 0.5 + 0.5 * height_map.get_noise_3dv(HEIGHT_MAP_SCALE * xy)
		v_noise = color_ramp.sample(v_noise).r
		vertices[i] *= 1.0 + height_variation * v_noise
	#
	arrays[Mesh.ARRAY_VERTEX] = vertices
	var st := SurfaceTool.new()
	st.create_from_arrays(arrays, Mesh.PRIMITIVE_TRIANGLES)
	st.generate_normals()
	st.generate_tangents()
	return st.commit()
