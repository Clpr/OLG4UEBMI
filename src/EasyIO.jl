"""
    EasyIO

Quick I/O APIs, covers extra pacakge-import from other enviroments
"""
module EasyIO
    # 1. 3rd-party APIs
    import Dates  # for time tags
    import DelimitedFiles  # std lib, delimited files e.g. csv

# ------------------------------------------------------------------------------
"""
   LogTag()

generates a tag of logging; the tag can be used to mark time or name files.
returns a String.
"""
function LogTag()
   local tagstr = replace(string(Dates.now()), "-" => "_" )
   tagstr = replace( tagstr, "T" => "_" )
   tagstr = replace( tagstr, ":" => "_" )
   tagstr = replace( tagstr, "." => "_" )
   return tagstr::String
end
# ----------
# Two IO functions from Julia 0.6
# NOTE: well ... the readcsv() & writecsv() before Julai 0.6 are SO convenient in some ways ...
#       I re-define the two functions here; (directly copied from base Julia 0.6)
readcsv(io; opts...)          = DelimitedFiles.readdlm(io, ','; opts...)
readcsv(io, T::Type; opts...) = DelimitedFiles.readdlm(io, ',', T; opts...)
"""
    writecsv(filename, A; opts)
Equivalent to [`writedlm`](@ref) with `delim` set to comma.
"""
writecsv(io, a; opts...) = DelimitedFiles.writedlm(io, a, ','; opts...)
# ---------

"""
    SaveModel( OutPath::String, Dt::Dict, Dst::Dict, Pt::Dict, Ps::Dict, Pc::Dict, env::NamedTuple )

Save a model (datasets) to a specific folder indicated with :OutPath.
:OutPath should be a FOLDER-level directory, please use '/' rather than "\\";
and, please use "/" to end the :OutPath string!
if not existed, a new folder will be auto created
returns nothing.
"""
function SaveModel( OutPath::String, Dt::Dict, Dst::Dict, Pt::Dict, Ps::Dict, Pc::Dict, env::NamedTuple )
    # check OutPath
    # @assert( isdir(OutPath) , "requries a path, not file or something else" )
    @assert( OutPath[end] == '/' , "requries a '/' to end your path" )
    # check if the assigned folder exists
    try
        mkdir( OutPath )
    catch
    end

    # Part 1: parameters
        # 1. demography
        writecsv( string(OutPath,"Population.csv"), Ps[:N] )
        writecsv( string(OutPath,"Mortality.csv"), Ps[:F] )
        # NOTE: save two vectors, total & labor popualtions, to plot
        writecsv(   string(OutPath,"AggDemography.csv"),
                    Dict(   "TotalPopu" => Dt[:N],
                            "LaborPopu" => sum(Ps[:N][:,1:env.Sr],dims=2)[:]  # using [:] to get a one-way vector
                        )
                )
        # 2. age-specific
        writecsv( string(OutPath,"Index_Age.csv"), Dst[:Age] )
        writecsv( string(OutPath,"ma2mb.csv"), Ps[:p] )
        writecsv( string(OutPath,"WageProfile.csv"), Ps[:ε] )
        writecsv( string(OutPath,"ProfiledQ_m2c.csv"), Ps[:q] )
        # 3. constants
        writecsv( string(OutPath,"ConstParameters.csv"), Pc )
        # 4. year-related parameters
        writecsv( string(OutPath,"YearParameters.csv"), Pt )

    # Part 2: year-related data
        writecsv( string(OutPath,"Index_Year.csv"), Dst[:Year] )
        writecsv( string(OutPath,"YearData.csv"), Dt )

    # Part 3: matrix data
        writecsv( string(OutPath,"Mat_Consumption.csv"), Dst[:c] )
        writecsv( string(OutPath,"Mat_Labor.csv"), Dst[:Lab] )
        writecsv( string(OutPath,"Mat_MedicalExp.csv"), Dst[:m] )
        writecsv( string(OutPath,"Mat_OutpatientExp.csv"), Dst[:MA] )
        writecsv( string(OutPath,"Mat_InpatientExp.csv"), Dst[:MB] )
        writecsv( string(OutPath,"Mat_Capital.csv"), Dst[:𝒜] )
        writecsv( string(OutPath,"Mat_Asset.csv"), Dst[:a] )
        writecsv( string(OutPath,"Mat_UEBMI_Indi.csv"), Dst[:Φ] )
        writecsv( string(OutPath,"Mat_Wage.csv"), Dst[:w] )

    return nothing
end












end   #module ends
#
