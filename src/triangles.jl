using Luxor, Images, Colors

luminance(rgb::RGB) =  0.3rgb.r + 0.59rgb.g + 0.11rgb.b

"""
	decimate(target_resolution::Integer, input_resolution::Tuple{<:Integer, <:Integer})

Returns a tuple of x and y coordinates in the aspect ratio of `input_resolution` such that `x*y = resolution^2`
"""
function distribute(target_resolution::Integer, input_resolution::Tuple{<:Integer, <:Integer})
	aspect_ratio = input_resolution[1] // input_resolution[2]
	y = target_resolution / sqrt(aspect_ratio)
	x = y * aspect_ratio
	return round.(Int, (x, y))
end

ugh = load("samples/bass_down_ugh.jpg")

function trianglify(
	image; 
	resolution=60, 
	output_resolution=(2560, 1440),
	pixel_scalar=3,
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

		percentage_coords = t_coords.I ./ triangle_resolution
		input_coords = round.(Int, percentage_coords .* input_resolution)
		output_coords = percentage_coords .* output_resolution .- pixel_size/2

		# println(output_coords)

		pixel = image[input_coords...]
		setcolor(pixel)

		ngon(
			output_coords..., # Position
			pixel_size, # Size
			3, # Sides
			luminance(pixel) * 2π + rand() * 0.1; 
			action = :fill
		)
	end

	mat = image_as_matrix()
	finish()

	map(p -> RGB(p), Matrix(mat))
end

save("out/output.png", trianglify(ugh))
ugh = load("samples/bass_down_meh.jpg")