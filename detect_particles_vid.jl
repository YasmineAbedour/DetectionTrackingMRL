using BlobTracking, Images, VideoIO, ImageView, ImageDraw
using Plots; gr()
using Plots;            

path = "add path here"
io   = VideoIO.open(path)
vid  = VideoIO.openvideo(io)
img1  = first(vid)

bt = BlobTracker(8:12, #sizes 
                #2.0, # σw Dynamics noise std.
                3.0,
                10.0,  # σe Measurement noise std. (pixels)
                #mask=mask,
                #preprocessor = preprocessor,
                amplitude_th = 0.008, ## a 0.007 ca detecte des faux positifs 
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)
tune_sizes(bt, img)

function detection(bt::BlobTracker, vid; threads=Threads.nthreads()>1)
    
    coords = Trace[]
    # if threads
    #     for (img, coord) in BlobTracking.coordinate_iterator(bt, vid)
    #         push!(coords, coord) 
    #         for i in 1:length(coord)
    #             draw!(img, ImageDraw.CirclePointRadius(coord[i], 1)) 
    #             plot!(img)
    #         end
    #     end
    # else
        img,vid = Iterators.peel(vid)
        ws = BlobTracking.Workspace(copy(img), length(bt.sizes))
        coord = BlobTracking.measure(ws, bt, img)
        push!(coords, coord)
        for img in vid
            coord = BlobTracking.measure(ws, bt, img)
            push!(coords, coord)
            for i in 1:length(coord)
                draw!(img, ImageDraw.CirclePointRadius(coord[i], 8)) 
            end
            display(img)
           
        end
    coords
end

coords = detection(bt::BlobTracker, vid; threads=Threads.nthreads()>1)

## for offline tracking 
result = track_blobs(bt::BlobTracker, coords::Vector{Trace})
