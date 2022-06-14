using BlobTracking, Images, VideoIO, ImageView
import BlobTracking.track_blobs

cam = VideoIO.opencamera()

img = read(cam)

bt = BlobTracker(5:6, #sizes 
                #2.0, # σw Dynamics noise std.
                3.0,
                10.0,  # σe Measurement noise std. (pixels)
                #mask=mask,
                #preprocessor = preprocessor,
                amplitude_th = 0.008, ## a 0.007 ca detecte des faux positifs 
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)
tune_sizes(bt, img)


function BlobTracking.track_blobs(bt::BlobTracker, vid, nbframes::Int; display=nothing, recorder=nothing, threads=Threads.nthreads()>1, ignoreempty=false)
    result = TrackingResult()
    #buffer = threads ? coordinate_iterator(bt, vid) : vid
    buffer=vid
    img,buffer = Iterators.peel(buffer)
    ws = BlobTracking.Workspace(img, length(bt.sizes))
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
                            display = nothing, #Base.display, # use nothing to omit displaying.
                            recorder=nothing,) # records result to video on disk

close(cam)

traces = trace(result, minlife=5) # Filter minimum lifetime of 5
measurement_traces = tracem(result, minlife=5)
drawimg = RGB.(img)
draw!(drawimg, traces, c=RGB(0,0,0.5))
draw!(drawimg, measurement_traces, c=RGB(0.5,0,0))

coords = get_coordinates(bt, cam)
