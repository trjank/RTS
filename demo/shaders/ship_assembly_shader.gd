class_name ShipAssemblyShader extends RefCounted

const SET_NUM := 0
const BINDING_NUM_ATLAS := 0
const BINDING_NUM_IMAGE := 1
const BINDING_NUM_PARTS := 2
const BINDING_NUM_GRID := 3
const SHADER_FILE := preload("res://shaders/ship_assembly.glsl")

const NUM_WORK_GROUPS_X := 2
const NUM_WORK_GROUPS_Y := 2

# NOTE: Ensure rendering is set to Forward+, not Compatibility
var rd := RenderingServer.create_local_rendering_device()
var shader := rd.shader_create_from_spirv(SHADER_FILE.get_spirv())

func _create_image(image: Image, flags: int) -> RID:
	var format := RDTextureFormat.new()
	format.width = image.get_width()
	format.height = image.get_height()
	format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	format.usage_bits = flags
	return rd.texture_create(format, RDTextureView.new(), [image.get_data() ] )

func _create_uniform(rid: RID, type: RenderingDevice.UniformType, binding_num: int) -> RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = type
	uniform.binding = binding_num
	uniform.add_id(rid)
	return uniform

func _setup_compute_list(uniform_list: Array[RDUniform] ) -> void:
	var uniform_set := rd.uniform_set_create(uniform_list, shader, SET_NUM)
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, NUM_WORK_GROUPS_X, NUM_WORK_GROUPS_Y, 1)
	rd.compute_list_end()

func generate_ship_image() -> float:
	var bytes_parts := PackedByteArray([
		0, 0, 0, 0,
		
	])
	var bytes_grid := PackedInt32Array( [0, 1, 1] ).to_byte_array()
	
	var parts_rid := rd.storage_buffer_create(bytes_parts.size(), bytes_parts)
	var grid_rid := rd.storage_buffer_create(bytes_grid.size(), bytes_grid)
	
	var atlas := preload("res://design/atlas_test.png").get_image()
	var atlas_rid := _create_image(atlas, RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT)
	var atlas_uniform := _create_uniform(atlas_rid, RenderingDevice.UNIFORM_TYPE_SAMPLER, BINDING_NUM_ATLAS)

	var image := Image.create_empty(2 * 32, 2 * 32, false, Image.FORMAT_RGBA8)
	var image_rid := _create_image(image, RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT)
	var image_uniform := _create_uniform(image_rid, RenderingDevice.UNIFORM_TYPE_IMAGE, BINDING_NUM_IMAGE)

	var start_time := Time.get_ticks_msec()
	var parts_uniform := _create_uniform(parts_rid, RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, BINDING_NUM_PARTS)
	var grid_uniform := _create_uniform(grid_rid, RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER, BINDING_NUM_GRID)
	_setup_compute_list( [atlas_uniform, image_uniform, parts_uniform, grid_uniform] )
	rd.submit()
	rd.sync()
	var output_bytes := rd.texture_get_data(image_rid, 0)
	image = Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, output_bytes)
	image.save_png("res://design/compute_ship_image.png")
	return Time.get_ticks_msec() - start_time
