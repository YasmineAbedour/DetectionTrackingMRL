using BlobTracking, Images, VideoIO, ImageView, ImageDraw
using Plots; gr()
using Plots;            

## this script detects blobs/particles with good enough contrast from the background, from a video (.avi or .mp4).

path = "add path here"
io   = VideoIO.open(path)
vid  = VideoIO.openvideo(io)
img1  = first(vid)

## creates a BlobTracker (structure for tracking in BlobTracking.jl)
## Dynamics and Measurement noise are Kalman Filter parameters
## amplitude_th is brigthness of particles to be detected, should be tuned correctly for good detection

bt = BlobTracker(8:12, #sizes 
                3.0, # σw Dynamics noise 
                10.0,  # σe Measurement noise (pixels)
                #mask=mask, ## can be used to preprocess frame before detection (cf BlobTracking.jl documentation)
                #preprocessor = preprocessor,
                amplitude_th = 0.008, 
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)

tune_sizes(bt, img) ## GUI with a slider to help find sizes values (works in Juno and IJulia)

## detects particles in each frames, adds coordinates detected to coords, and prints blobs at the coordinates.
function detection(bt::BlobTracker, vid; threads=Threads.nthreads()>1)
    
      coords = Trace[] ## creates a Trace, empty array that will be filled with cordinates of detection
      img,vid = Iterators.peel(vid) ## "peels off" top frame in vid (vid is a stack of frames)
      ws = BlobTracking.Workspace(copy(img), length(bt.sizes)) ## creates a Workspace (structure in BlobTracking.jl to control memory allocations)
      coord = BlobTracking.measure(ws, bt, img) ## detects blobs on a single frame
      push!(coords, coord) ## adds coord of detected blobs from one frame to coords
      for img in vid ## frame by frame detection through the video
          coord = BlobTracking.measure(ws, bt, img)
          push!(coords, coord)
          for i in 1:length(coord)
              draw!(img, ImageDraw.CirclePointRadius(coord[i], 8)) ## last argument is radius of plotted blobs in pixels
          end
          display(img)
      end
    coords
end

coords = detection(bt::BlobTracker, vid; threads=Threads.nthreads()>1)

## for offline tracking after the detection
result = track_blobs(bt::BlobTracker, coords::Vector{Trace})
