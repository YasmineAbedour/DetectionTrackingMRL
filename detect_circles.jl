using Images, ImageFeatures, FileIO, ImageView, ImageEdgeDetection, ImageFiltering

## this script detects circles on an image given a strong enough contrast between particles and background and correct tuning of the parameters

function detect_circles(path)
    
    ## converts the img into grayscale 
    img = Gray.(load(path));  
    ## blurs img with 3x3 gaussian kernel
    img = imfilter(img, Kernel.gaussian(3));

    ## spatial_scale : regulates noise in edge detection ( increase to reduce noise )
    img_edges = detect_edges(img, Canny(spatial_scale = 3)) 
    ## converts img_edges to binary img (hough_circle_gradient requires binary)
    bool_img_edges = !=(0).(img_edges)
    
    
    dx, dy=imgradients(img, KernelFactors.ando5);
    img_phase = phase(dx, dy)
    
    ## applies hough circle transform to img
    ## third parameter = range of the radii of the particles to detect (in pixels)
    ## circle_centers = array containing the centers cordinates of detected circles
    ## circle_radius = array containing the radii of detected circles
   
    circle_centers, circle_radius = hough_circle_gradient(bool_img_edges, img_phase, 8:10) 

    ## prints circle centers on edges image
    img_demo = Float64.(bool_img_edges); for c in circle_centers img_demo[c] = 2; end
    imshow(img_demo)

end

#path must be written with quotation marks
detect_circles("C:\\Users\\xy\\images\img1.jpg")
