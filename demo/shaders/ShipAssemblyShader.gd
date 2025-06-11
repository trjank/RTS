class_name ShipAssemblyShader extends RefCounted

# NOTE: The set and binding numbers need to match those in the .glsl file.
const SET_NUM := 0
const ATLAS_BINDING_NUM := 0
const IMAGE_BINDING_NUM := 1
const INDEX_BUFFER_BINDING_NUM := 2
const ROTATION_BUFFER_BINDING_NUM := 3
const ATLAS_ID_BUFFER_BINDING_NUM := 4
const PART_OFFSETS_BUFFER_BINDING_NUM := 5
const ATLAS_OFFSETS_BUFFER_BINDING_NUM := 6
const SHADER_FILE := preload("res://shaders/ship_assembly.glsl")
const NUM_WORK_GROUPS_X := 2
const NUM_WORK_GROUPS_Y := 2

# NOTE: Ensure rendering is set to Forward+, not Compatibility
var rd := RenderingServer.create_local_rendering_device()
var shader := rd.shader_create_from_spirv(SHADER_FILE.get_spirv())

func create_image_buffer(image: Image)->RID:
	var format := RDTextureFormat.new()
	format.width = image.get_width()
	format.height = image.get_height()
	format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	return rd.texture_create(format, RDTextureView.new(), [image.get_data()] )

func create_image_uniform(rid: RID, binding_num: int)->RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = binding_num
	uniform.add_id(rid)
	return uniform

func create_buffer_uniform(bytes: PackedByteArray, binding_num: int)->RDUniform:
	var buffer := rd.storage_buffer_create(bytes.size(), bytes)
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = binding_num
	uniform.add_id(buffer)
	return uniform

func setup_compute_list(uniform_list: Array[RDUniform])->void:
	var uniform_set := rd.uniform_set_create(uniform_list, shader, SET_NUM)
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, NUM_WORK_GROUPS_X, NUM_WORK_GROUPS_Y, 1)
	rd.compute_list_end()

func generate_ship_image()->float:
	var index_bytes := PackedInt32Array([0, 1, 2, 0]).to_byte_array()
	var rotation_bytes := PackedInt32Array([0, 0, 0]).to_byte_array()
	var atlas_id_bytes := PackedInt32Array([0, 1, 1]).to_byte_array()
	var part_offset_bytes := PackedVector2Array([Vector2.ZERO, Vector2(1.5, 0.5), Vector2(0.5, 1.5)]).to_byte_array()
	var atlas_offset_bytes := PackedVector2Array([Vector2(16, 16), Vector2(48, 16)]).to_byte_array()
	
	var atlas := preload("res://test_atlas.png").get_image()
	var atlas_rid := create_image_buffer(atlas)
	var atlas_uniform := create_image_uniform(atlas_rid, ATLAS_BINDING_NUM)

	var image := Image.create(2 * 32, 2 * 32, false, Image.FORMAT_RGBA8)
	var image_rid := create_image_buffer(image)
	var image_uniform := create_image_uniform(image_rid, IMAGE_BINDING_NUM)

	var start_time := Time.get_ticks_msec()
	var index_uniform := create_buffer_uniform(index_bytes, INDEX_BUFFER_BINDING_NUM)
	var rotation_uniform := create_buffer_uniform(rotation_bytes, ROTATION_BUFFER_BINDING_NUM)
	var atlas_id_uniform := create_buffer_uniform(atlas_id_bytes, ATLAS_ID_BUFFER_BINDING_NUM)
	var part_offsets_uniform := create_buffer_uniform(part_offset_bytes, PART_OFFSETS_BUFFER_BINDING_NUM)
	var atlas_offsets_uniform := create_buffer_uniform(atlas_offset_bytes, ATLAS_OFFSETS_BUFFER_BINDING_NUM)
	setup_compute_list( [atlas_uniform, image_uniform, index_uniform, rotation_uniform, atlas_id_uniform, part_offsets_uniform, atlas_offsets_uniform] )
	rd.submit()
	rd.sync()
	var output_bytes := rd.texture_get_data(image_rid, 0)
	image = Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, output_bytes)
	image.save_png("res://compute_ship_image.png")
	return Time.get_ticks_msec() - start_time
