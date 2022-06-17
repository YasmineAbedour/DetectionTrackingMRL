# DetectionTrackingMRL

## Circle detection in pictures (detect_circles.jl)

The detect_circles.jl script allows to detect circular shapes on an input image.

First, the image is loaded and converted to grayscale. 
Applying a [Gaussian filter](https://en.wikipedia.org/wiki/Gaussian_filter) on it helps with the upcoming detection.

```julia
img = Gray.(load("C:\\Users\\Yasmine\\SANDBOX\\git files\\pontedera\\images_semaine1\\gaia1.jpg"));
img = imfilter(img, Kernel.gaussian(3));
```
[Canny edge detection algorithm](https://en.wikipedia.org/wiki/Canny_edge_detector) is applied on the blurred picture. The spatial_scale can be tuned to reduce the noise on the resultant image "img_edges".

```Julia
img_edges = detect_edges(img, Canny(spatial_scale = 3)) 
dx, dy=imgradients(img, KernelFactors.ando5);
img_phase = phase(dx, dy)
```

img_edges and img_phase are used in the [Hough Circle Transform](https://en.wikipedia.org/wiki/Circle_Hough_Transform) function to detect the circles in img. The third parameter is an array containing the radii range of circles we want to detect. This is the most important parameter to tune with precision.

```Julia
circle_centers, circle_radius = hough_circle_gradient(bool_img_edges, img_phase, 8:10)
```
To visualize the detection, the following lines plot img_edges with the circle centers.

```Julia
img_demo = Float64.(bool_img_edges); for c in circle_centers img_demo[c] = 2; end
imshow(img_demo)
```
## Tracking circular shapes in video and on camera live stream 
## track_particles.jl

Using [BlobTracking.jl](https://github.com/baggepinnen/BlobTracking.jl) package, which uses [Laplacian-of-Gaussian filtering](https://en.wikipedia.org/wiki/Blob_detection) (from [Images.jl](https://juliaimages.org/latest/function_reference/#Images.blob_LoG)) and a Kalman filter from [LowLevelParticleFilters.jl](https://github.com/baggepinnen/LowLevelParticleFilters.jl).

The track_particles.jl script allows to track blobs on a video.

This portion of the code opens the video and creates a iterable stack of frames, which is then stored in "vid"

```Julia
path = "C:\\Users\\Yasmine\\SANDBOX\\git files\\pontedera\\images_semaine1\\h2o2_1_whitouttag.mp4"
io   = VideoIO.open(path)
vid  = VideoIO.openvideo(io)
img  = first(vid)
```

Then the user has to tune the Blob Tracker parameters that will be used in the BlobTracking.track_blobs. 
Tuning the size parameters and amplitude_th is the most decisive part to detect precisely the wanted objects and avoid detecting noise in the video.


```Julia
#creates a blob tracker with the desired parameters.
bt = BlobTracker(5:11, #array of blob sizes we want to detect 
                3.0, # σw Dynamics noise std. (kalman filter param)
                10.0,  # σe Measurement noise std. (pixels) (kalman filter param)
                #mask=mask, #image processing before the detection, not implemented here because unecessary
                #preprocessor = preprocessor, #image processing before the detection, not implemented here because unecessary
                amplitude_th = 0.008, 
                correspondence = HungarianCorrespondence(p=0.5, dist_th=4), # dist_th is the number of sigmas away from a predicted location a measurement is accepted.
)

#tune_size can be used to automatically tune the size array in bt based on img (the first img of vid). not mandatory.
#tune_sizes(bt, img)
```
Base.display plots the frame one after the other with the detected blobs in each frame. Recorder() provides a video with the detected blobs.
```Julia
result = track_blobs(bt, vid,
                        display = Base.display, # use nothing to omit displaying.
                        recorder = Recorder(),) # records result to video on disk
```
## track_particles_live.jl

Using the same operations mentionned in the previous part, but with a modified track_blobs function, a camera stream can be used to track objects.
The function takes a new argument, nbframes, corresponding to the number of frames we want to track the objects on. 

The tracking will automatically stop after having processed "nbframes" frames.  

```Julia
result = track_blobs(bt, cam,nbframes,
                            display = nothing, #Base.display, # use nothing to omit displaying.
                            recorder=nothing,) # records result to video on disk
```

## Exporting data using save_data.jl

The results of the tracking are exported in a .csv file containing a Dataframe with Blob ID (example: blob 1 is the first one detected in the first frame etc), time of detection on each frame, and x and y coordinates in pixels.

## Credits

These scripts use Open Source components. You can find the source code of their open source projects along with license information below. We acknowledge and are grateful to this developer for their contributions to open source.

Project: [Blob Tracking](https://github.com/baggepinnen/BlobTracking.jl)

Copyright (c) 2020 Fredrik Bagge Carlson

License (MIT) [https://github.com/madninja/MNColorKit/blob/master/LICENSE.txt](https://github.com/baggepinnen/BlobTracking.jl/blob/master/LICENSE)
