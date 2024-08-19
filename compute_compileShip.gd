extends Node

#tests ship generation
var blocksize = 32
var shipX = 24 * blocksize
var shipY = 24 * blocksize


var computeShip_rid: RID
var textureAtlas_rid: RID
var rd : RenderingDevice
var uniform_set : RID
var shader_rid: RID
var pipeline: RID

@onready var text_rect: TextureRect = $Control/TextureRect
var textureShip
var stoptime
var time

func init_gpu() -> void:
	# These resources are expensive to make, so create them once and cache for subsequent runs.

	# Create a local rendering device (required to run compute shaders).
	rd = RenderingServer.create_local_rendering_device()

	if rd == null:
		OS.alert("""Couldn't create local RenderingDevice on GPU: %s

Note: RenderingDevice is only available in the Forward+ and Mobile rendering methods, not Compatibility.""" % RenderingServer.get_video_adapter_name())
		return
	
	shader_rid = load_shader(rd,"res://compute-computeShip.glsl")
	
	# Prepare our data. We use floats in the shader, so we need 32 bit.
	var index := PackedInt32Array([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29])
	var index_bytes := index.to_byte_array()
	
	var rotation := PackedInt32Array([0, 1, 0, 1, 2, 3, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1])
	var rotation_bytes := rotation.to_byte_array()
	
	# Create a storage buffer that can hold our float values.
	var index_buffer := rd.storage_buffer_create(index_bytes.size(), index_bytes)
	var rotation_buffer := rd.storage_buffer_create(rotation_bytes.size(), rotation_bytes)
	
	# Create a uniform to assign the buffer to the rendering device
	var index_uniform := RDUniform.new()
	index_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	index_uniform.binding = 0 # this needs to match the "binding" in our shader file
	index_uniform.add_id(index_buffer)
	
		# Create a uniform to assign the buffer to the rendering device
	var rotation_uniform := RDUniform.new()
	rotation_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	rotation_uniform.binding = 1 # this needs to match the "binding" in our shader file
	rotation_uniform.add_id(rotation_buffer)
	
	var imageAtlas = load("res://dynas2big6.png")
	var textureAtlas = ImageTexture.create_from_image(imageAtlas)
	
	var textureAtlas_format := RDTextureFormat.new()
	textureAtlas_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	textureAtlas_format.width = textureAtlas.get_width()
	textureAtlas_format.height = textureAtlas.get_height()
	textureAtlas_format.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT + RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT
	
	textureAtlas_rid = rd.texture_create(textureAtlas_format,RDTextureView.new(),[textureAtlas.get_image().get_data()])
	print("test")
	
	var textureAtlas_uniform := RDUniform.new()
	textureAtlas_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	textureAtlas_uniform.binding = 2
	textureAtlas_uniform.add_id(textureAtlas_rid)
	
	
	var computeShip_format := RDTextureFormat.new()

	computeShip_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	computeShip_format.width = shipX
	computeShip_format.height = shipY
	computeShip_format.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT + RenderingDevice.TEXTURE_USAGE_STORAGE_BIT

	computeShip_rid = rd.texture_create(computeShip_format, RDTextureView.new())
	
	var computeShip_uniform := RDUniform.new()
	computeShip_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	computeShip_uniform.binding = 3  # This matches the binding in the shader.
	computeShip_uniform.add_id(computeShip_rid)
	
	uniform_set = rd.uniform_set_create([index_uniform, rotation_uniform, textureAtlas_uniform, computeShip_uniform], shader_rid, 0) # the last parameter (the 0) needs to match the "set" in our shader file
	# Create a compute pipeline
	pipeline = rd.compute_pipeline_create(shader_rid)

func _ready():
	if rd == null:
		init_gpu()
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, shipX, shipY, 1)
	rd.compute_list_end()

	# Submit to GPU and wait for sync
	time = Time.get_ticks_usec()
	rd.submit()
	finish_gpu_call()
	
func finish_gpu_call():
	rd.sync()
	
	var output_bytes := rd.texture_get_data(computeShip_rid, 0)
	var imageShip := Image.create_from_data(shipX, shipY, false, Image.FORMAT_RGBA8, output_bytes)
	stoptime = Time.get_ticks_usec()
	
	textureShip = ImageTexture.create_from_image(imageShip)
	text_rect.texture = textureShip
	
	$Control/RichTextLabel.text = "Time: %s ms" % str((stoptime-time)*0.001)
	print("Time: %s ms" % str((stoptime-time)*0.001))

	# Read back the data from the buffer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func cleanup_gpu() -> void:
	if rd == null:
		return

	# All resources must be freed after use to avoid memory leaks.

	rd.free_rid(pipeline)
	pipeline = RID()

	rd.free_rid(uniform_set)
	uniform_set = RID()

	rd.free_rid(computeShip_rid)
	computeShip_rid = RID()

	rd.free_rid(textureAtlas_rid)
	textureAtlas_rid = RID()

	rd.free_rid(shader_rid)
	shader_rid = RID()

	rd.free()
	rd = null

# Import, compile and load shader, return reference.
func load_shader(p_rd: RenderingDevice, path: String) -> RID:
	var shader_file_data: RDShaderFile = load(path)
	var shader_spirv: RDShaderSPIRV = shader_file_data.get_spirv()
	return p_rd.shader_create_from_spirv(shader_spirv)


func _on_button_pressed():
	finish_gpu_call()
