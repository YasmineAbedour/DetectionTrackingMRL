using BlobTracking, Images, VideoIO, ImageView, ImageDraw, Colors
using Plots; gr()         

cam = VideoIO.opencamera()
img = read(cam)

bt = BlobTracker(5:10, #sizes 
                3.0,   # σw Dynamics noise std.
                10.0,  # σe Measurement noise std. (pixels)
                #mask=mask,
                #preprocessor = preprocessor,
                amplitude_th = 0.008, 
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)
tune_sizes(bt, img)

ws = BlobTracking.Workspace(img, length(bt.sizes))
coordos = Trace[]
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

for i in 1:20
detection_frame(bt, coordos, ws; threads=Threads.nthreads()>1,)
end

close(cam)
