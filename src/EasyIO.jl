"""
    EasyIO

Quick I/O APIs, covers extra pacakge-import from other enviroments
"""
module EasyIO
    # 1. 3rd-party APIs
    import DataFrames  # dataframe APIs
    import CSV  # csv file APIs
# ------------------------------------------------------------------------------
"""
    WriteMat( Mat::Array{T,2} where T ; output::String = "./" )

writes a Array{T,2} matrix to a csv file; output= indicates the file to write;
no header written.
returns nothing
"""
function WriteMat( Mat::Array{T,2} where T ; output::String = "./" )
    # convert to a dataframe
    local Df = DataFrames.DataFrame(Mat)
    # output
    local fp = open( output, "w" )
    CSV.write( fp, Df )
    close(fp)
    return nothing
end
# ------------























end   #module ends
#
