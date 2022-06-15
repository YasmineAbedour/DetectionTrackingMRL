using Images, ImageFeatures, FileIO, ImageView, ImageEdgeDetection, ImageFiltering

function detect_circles(path)

    img = Gray.(load(path));
    img = imfilter(img, Kernel.gaussian(3));


    img_edges = detect_edges(img, Canny(spatial_scale = 3)) ##for gaia1.jpg
    dx, dy=imgradients(img, KernelFactors.ando5);

    img_phase = phase(dx, dy)
    bool_img_edges = !=(0).(img_edges)

    circle_centers, circle_radius = hough_circle_gradient(bool_img_edges, img_phase, 8:10) 

    ##ajoute boucle for pour quil arrete de compter les centres hors de limage 
    img_demo = Float64.(bool_img_edges); for c in circle_centers img_demo[c] = 2; end
    imshow(img_demo)

end

#path must be written with quotation marks
detect_circles("C:\\Users\\xy\\images\img1.jpg")
