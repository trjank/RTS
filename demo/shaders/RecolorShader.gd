class_name RecolorShader extends RefCounted

# NOTE: The set and binding numbers need to match those in the .glsl file.
const SET_NUM := 0
const IMAGE_BINDING_NUM := 0
const COLOR_BINDING_NUM := 1
const SHADER_FILE := preload("res://shaders/recolor.glsl")
const NUM_WORK_GROUPS_X := 4
const NUM_WORK_GROUPS_Y := 4

# NOTE: Ensure rendering is set to Forward+, not Compatibility
var rd := RenderingServer.create_local_rendering_device()
var shader := rd.shader_create_from_spirv(SHADER_FILE.get_spirv())

func create_image_buffer(image: Image)->RID:
	var format := RDTextureFormat.new()
	format.width = image.get_width()
	format.height = image.get_height()
	format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	format.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	return rd.texture_create(format, RDTextureView.new(), [image.get_data()] )

func create_image_uniform(rid: RID)->RDUniform:
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	uniform.binding = IMAGE_BINDING_NUM
	uniform.add_id(rid)
	return uniform

func create_color_uniform(color: Color)->RDUniform:
	var vec4_array := PackedColorArray( [color] )
	var vec4_bytes := vec4_array.to_byte_array()
	var buffer := rd.storage_buffer_create(vec4_bytes.size(), vec4_bytes)
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = COLOR_BINDING_NUM
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

func recolor_image(image: Image, color: Color)->float:
	var start_time := Time.get_ticks_msec()
	var image_rid := create_image_buffer(image)
	var image_uniform := create_image_uniform(image_rid)
	var color_uniform := create_color_uniform(color)
	setup_compute_list( [image_uniform, color_uniform] )
	rd.submit()
	rd.sync()
	var output_bytes := rd.texture_get_data(image_rid, 0)
	image = Image.create_from_data(image.get_width(), image.get_height(), false, Image.FORMAT_RGBA8, output_bytes)
	image.save_png("res://ship_image.png")
	return Time.get_ticks_msec() - start_time
