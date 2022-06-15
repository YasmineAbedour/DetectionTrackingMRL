# DetectionTrackingMRL

## Circle detection in pictures (CircleDetection.jl)

First, we load the image and convert it to grayscale. 
Applying a [Gaussian filter](https://en.wikipedia.org/wiki/Gaussian_filter) on it helps with the detection that is done in the next part of the code.

```julia
img = Gray.(load("C:\\Users\\Yasmine\\SANDBOX\\git files\\pontedera\\images_semaine1\\gaia1.jpg"));
img = imfilter(img, Kernel.gaussian(3));
```
[Canny edge detection algorithm](https://en.wikipedia.org/wiki/Canny_edge_detector) is applied on the blurred picture. The spatial-scale can be tuned to reduce the noise on the resultant image "img_edges".


```Julia
img_edges = detect_edges(img, Canny(spatial_scale = 3)) 
dx, dy=imgradients(img, KernelFactors.ando5);
img_phase = phase(dx, dy)
```

img_edges and img_phase are used in the [Hough Circle Transform](https://en.wikipedia.org/wiki/Circle_Hough_Transform) function to detect the circles in img. The third parameter is an array of radii of circles we want to detect. This is the most important parameter to tune precisely.

```Julia
circle_centers, circle_radius = hough_circle_gradient(bool_img_edges, img_phase, 8:10)
```
To visualize the detection, the following lines plot img_edges with the circle centers.

```Julia
img_demo = Float64.(bool_img_edges); for c in circle_centers img_demo[c] = 2; end
imshow(img_demo)
```
