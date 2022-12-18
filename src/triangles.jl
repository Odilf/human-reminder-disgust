using Luxor, Images, Colors

luminance(rgb::RGB) = 0.3rgb.r + 0.59rgb.g + 0.11rgb.b

"""
	distribute(target_resolution::Integer, input_resolution::Tuple{<:Integer, <:Integer})

Returns a tuple of x and y coordinates in the aspect ratio of `input_resolution` such that `x*y = resolution^2`
"""
function distribute(target_resolution::Integer, input_resolution::Tuple{<:Integer, <:Integer})
	aspect_ratio = input_resolution[1] // input_resolution[2]
	y = target_resolution / sqrt(aspect_ratio)
	x = y * aspect_ratio
	return round.(Int, (x, y))
end

function trianglify(
	image; 
	resolution=60, 
	output_resolution=(1920, 1080),
	pixel_scalar=3,
	sides=3
)
	# Scaffolding
	Drawing(output_resolution..., :png)
	image = transpose(image)
	background(Gray(sum(luminance, image) / length(image) - 0.3))

	# Get other resolutions
	input_resolution = size(image)
	triangle_resolution = distribute(resolution, input_resolution)

	# Set pixel size
	pixel_size = output_resolution[1] / triangle_resolution[1] / 2
	pixel_size *= pixel_scalar
	
	for t_coords ∈ CartesianIndices(triangle_resolution)	

		# Get all different useful coordinate spaces
		percentage_coords = t_coords.I ./ triangle_resolution
		input_coords = round.(Int, percentage_coords .* input_resolution)
		output_coords = percentage_coords .* output_resolution .- pixel_size/2

		# Set color
		pixel = image[input_coords...]
		setcolor(pixel)
		rotation = luminance(pixel) * 2π + rand() * 0.1

		# Create triangle
		ngon(output_coords..., pixel_size, sides, rotation; action = :fill)
	end

	mat = image_as_matrix()
	finish()

	map(p -> RGB(p), Matrix(mat))
end

save("out/heptagon.png", trianglify(ugh))
ugh = load("samples/bass_down_ugh.jpg");