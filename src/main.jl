using VideoIO
using ProgressMeter

include("triangles.jl")

@time const sample = load("samples/sample for triangles.mp4");

function create_video(
	file; 
	output="out/output.mp4", 
	kwargs...
)	
	video_stream = openvideo(file)
	number_frames = VideoIO.get_number_frames(file)
	frames = []

	@showprogress for i ∈ 1:2:number_frames
		# Read frame
		frame = read(video_stream)
		
		# First fade to triangles
		# resolution = i > 180 ? 60 : round(Int, rescale(i, 1, 180, 500, 60))
		resolution = 60

		# Trianglify
		frame = trianglify(frame; resolution, sides = 5)

		# Push the frames
		push!(frames, frame)

		# Animate on 2s
		skipframe(video_stream)
	end

	close(video_stream)

	@info "Render is finished, saving to file..."
	save(output, frames; framerate=12)
end