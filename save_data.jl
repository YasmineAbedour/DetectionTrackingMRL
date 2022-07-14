using CSV
using DataFrames

## this script saves data in a dataframe in .csv file. 4 columns: blob ID, time, x and y for each frame.
## framerate is the frame rate of the video

function save_data(result,vid_framerate)
    
    ## creates the columns
    blobid = []
    time = []
    coord_x = []
    coord_y = []
    
    ## fills the columns
    for i in eachindex(result.blobs)
        for j in eachindex(result.blobs[i].trace)
            coords = result.blobs[i].trace[j]
            push!(blobid,i)
            push!(time,j/vid_framerate)
            push!(coord_x,coords[1])
            push!(coord_y,coords[2])

        end
    end

    ## creates new file
    touch("coordinates.csv")
    
    ## opens the file
    efg = open("coordinates.csv", "w")
    
    ## creates DataFrame
    data = DataFrame(BlobID = blobid,
    Time = time,
    x = coord_x,
    y= coord_y) 

    ## writes the columns in file
    CSV.write("coordinates.csv", data)
   
    
end

