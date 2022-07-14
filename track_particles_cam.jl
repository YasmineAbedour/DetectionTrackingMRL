using BlobTracking, Images, VideoIO, ImageView
import BlobTracking.track_blobs

## this script detects and tracks blobs/particles with good enough contrast from the background, from a steady camera frame stream. not real time !! works on the first frames acquired from the cam when opened.
## reading BlobTracking.jl documentation is advised

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

tune_sizes(bt, img)  ## GUI with a slider to help find sizes values (works in Juno and IJulia)

##cf BlobTracking.jl documentation
function BlobTracking.track_blobs(bt::BlobTracker, vid, nbframes::Int; display=nothing, recorder=nothing, threads=Threads.nthreads()>1, ignoreempty=false)
    result = TrackingResult()
    buffer=vid
    img,buffer = Iterators.peel(buffer)
    ws = BlobTracking.Workspace(img, length(bt.sizes)) ## creates a Workspace (structure in BlobTracking.jl to control memory allocations)
    img, coord_or_img = img isa Tuple ? img : (img,img)
    measurement = Measurement(ws, bt, coord_or_img, result)
    BlobTracking.spawn_blobs!(result, bt, measurement)
    BlobTracking.showblobs(RGB.(Gray.(img)), result, measurement, recorder = recorder, display=display)

    try
        for (ind,img) in enumerate(Base.Iterators.take(buffer, nbframes))
            println("Frame $ind")
            img, coord_or_img = img isa Tuple ? img : (img,img)
            measurement = update!(ws, bt, coord_or_img , result)
            BlobTracking.showblobs(RGB.(Gray.(img)),result,measurement, rad=6, recorder=recorder, display=display, ignoreempty=ignoreempty)
        end
    finally
        finalize(recorder)
    end
    result
end

nbframes = 15
result = track_blobs(bt, cam,nbframes,
                            display = Base.display, # use nothing to omit displaying.
                            recorder= nothing ,) # use Recorder to record result to video on disk

## plotting of trajectories
traces = trace(result, minlife=5) # Filter minimum lifetime of 5
measurement_traces = tracem(result, minlife=5)
drawimg = RGB.(img)
draw!(drawimg, traces, c=RGB(0,0,0.5))
draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))
    
coords = get_coordinates(bt, cam)
close(cam)

