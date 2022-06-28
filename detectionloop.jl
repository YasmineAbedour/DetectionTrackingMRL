using BlobTracking, Images, VideoIO, ImageView, ImageDraw, Colors
using CSV
using DataFrames
using Plots; gr()
include("save_data.jl")
using Plots;             


cam = VideoIO.opencamera()
img = read(cam)
close(cam)
bt = BlobTracker(5:10, #sizes 
                #2.0, # σw Dynamics noise std.
                3.0,
                10.0,  # σe Measurement noise std. (pixels)
                #mask=mask,
                #preprocessor = preprocessor,
                amplitude_th = 0.008, ## a 0.007 ca detecte des faux positifs 
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)
tune_sizes(bt, img)

ws = BlobTracking.Workspace(img, length(bt.sizes))

coordos = Trace[]

function detection_frame(bt::BlobTracker, coordos, ws; threads=Threads.nthreads()>1,)
    img = read(cam)
    img, coord_or_img = img isa Tuple ? img : (img,img)
    coord = BlobTracking.measure(ws, bt, img)
    push!(coordos, coord)
    for i in 1:length(coord)
        draw!(img, ImageDraw.CirclePointRadius(coord[i], 8))
    end
    display(img)
end


for i in 1:10
    detection_frame(bt, coordos, ws; threads=Threads.nthreads()>1,)
end


