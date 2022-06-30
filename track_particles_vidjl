using BlobTracking, Images, VideoIO, ImageView
using CSV
using DataFrames
include("save_data.jl")


#opens the video, creates a iterable stack of frames stored in "vid"
path = "add path here"
io   = VideoIO.open(path)
vid  = VideoIO.openvideo(io)
img  = first(vid)

#creates a blob tracker with the desired parameters.
bt = BlobTracker(5:11, #array of blob sizes we want to detect 
                3.0, # σw Dynamics noise std. (kalman filter param)
                10.0,  # σe Measurement noise std. (pixels) (kalman filter param)
                #mask=mask, #image processing before the detection, not implemented here because unecessary
                #preprocessor = preprocessor, #image processing before the detection, not implemented here because unecessary
                amplitude_th = 0.008, ## with less, like 0.007, it detects false positives (in the Hirox videos)
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)

#tune_size can be used to automatically tune the size array in bt based on img (the first img of vid). not mandatory.
#tune_sizes(bt, img)


result = track_blobs(bt, vid,
                        display = Base.display, # use nothing to omit displaying.
                        recorder = Recorder(),) # records result to video on disk


#plots trajectories and start-end points for each blob
traces = trace(result, minlife=15) # Filter minimum lifetime of 5
measurement_traces = tracem(result, minlife=5)
drawimg = RGB.(img)
draw!(drawimg, traces, c=RGB(0,0,0.5))
draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))

#if we just need the coordinates whitout tracking, use this
coords = get_coordinates(bt, vid)


#saves data in a dataframe in .csv file. 4 columns: blob ID, time, x and y for each frame.
#framerate is the frame rate of the video
save_data(result,framerate)

