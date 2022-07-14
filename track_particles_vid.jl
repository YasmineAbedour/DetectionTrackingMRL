using BlobTracking, Images, VideoIO, ImageView


#opens the video, creates a iterable stack of frames stored in "vid"
path = "add path here"
io   = VideoIO.open(path)
vid  = VideoIO.openvideo(io)
img  = first(vid)

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


result = track_blobs(bt, vid,
                        display = Base.display, # use nothing to omit displaying.
                        recorder = Recorder(),) # records result to video on disk


## plots trajectories and start-end points for each blob
traces = trace(result, minlife=15) # Filter minimum lifetime of 5
measurement_traces = tracem(result, minlife=5)
drawimg = RGB.(img)
draw!(drawimg, traces, c=RGB(0,0,0.5))
draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))

## gets coordinates of blobs whitout tracking
coords = get_coordinates(bt, vid)
