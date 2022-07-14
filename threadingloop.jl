using BlobTracking, Images, VideoIO, ImageView, ImageDraw, Colors
using Plots; gr()         

## this script detects blobs/particles with good enough contrast from the background, from a steady camera frame stream.

cam = VideoIO.opencamera()
img = read(cam)

## creates a BlobTracker (structure for tracking in BlobTracking.jl)
## Dynamics and Measurement noise are Kalman Filter parameters
## amplitude_th is brigthness of particles to be detected, should be tuned correctly for good detection

bt = BlobTracker(5:10, ## sizes of particles of interest in pixels (length of sizes has a big impact on runtime)
                3.0, # σw Dynamics noise 
                10.0,  # σe Measurement noise (pixels)
                #mask=mask, ## can be used to preprocess frame before detection (cf BlobTracking.jl documentation)
                #preprocessor = preprocessor,
                amplitude_th = 0.008, 
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)

tune_sizes(bt, img) ## GUI with a slider to help find sizes values (works in Juno and IJulia)


## creates a Workspace (structure in BlobTracking.jl to control memory allocations)
ws = BlobTracking.Workspace(img, length(bt.sizes))
## creates a Trace, empty array that will be filled with cordinates of detection
coordos = Trace[]

## creates a lock for datarace free multithreading usage (the camera is a shared ressource)
const my_global_lock = ReentrantLock()


function detection_frame(bt::BlobTracker, coordos, ws; threads=Threads.nthreads()>1,)
  
    lock(my_global_lock) do
        img = read(cam)
    end
    img, coord_or_img = img isa Tuple ? img : (img,img)
    coord = BlobTracking.measure(ws, bt, img)
    push!(coordos, coord)
    for i in 1:length(coord)
        draw!(img, ImageDraw.CirclePointRadius(coord[i], 4))
    end
    display(img)
    coordos
end

## for i in 1:(nb of frames you want to run detection on)
for i in 1:20
detection_frame(bt, coordos, ws; threads=Threads.nthreads()>1,)
end

close(cam)
