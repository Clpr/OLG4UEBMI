__precompile__()
"""
    EasyMath (for Julia 1.0.1)

I refactor mathematical module of urban OLG model for the urban-rural OLG model, in Julia 1.0.1;
It embraces new features and support 1.0.1 grammars.

# Function List:
1. diagw() & diagw!(): write elements to matrices by diagonals, supports both in-place or in copy 向矩阵里沿对角线写入元素，有两种版本（用于transition path中更新数据）
2. diagr(): read elements in matrices by diagonals, automatically repeat the last element, or drop the last elements to make selected vector to a specific length LEN 沿对角线读取矩阵元素，如果指定的长度参数LEN=与对角线元素数目不同，要么不断复制最后一个元素令其扩充到指定长度，要么砍掉多余的元素（用于transition path，尤其是household problems中提取并准备数据）
3. year2idx(): converting between indices in collections (1...N) and years (e.g. 19xx...2xxx); supports range ⇋ array, array ⇋ array; if point to point, use findfirst(logical collection); 在数据脚标和年份之间实现转换，有多种派发，支持range, array之间的变换；如果是点对点的，请使用findfirst()
4. vecExpand(): expand/cut vectors to specific length, similar to diagr(); 类似diagr()，自动补全或删除元素，用于拓展或削断向量


# Notable Differences from Julia 0.6
1. diagm(), diag() now has been moved to LinearAlgebra
2. the name Val has been occupied by Base.Val

"""
module EasyMath
	import LinearAlgebra: diagind, diag  # diagind() gets index range for an assigned offline parameter, used in diagwrite()
    # using Statistics  # for Julia 1.0, cauz many basic statistical methods have been removed from the core language
    export diagw, diagw!,  # write elements into a matrix by diagonals
		   diagr, vecr, # read elements, automatically add/drop elements to specific length
		   year2idx,  # convert years to indices in a specific year collection/range
		   vecExpand  # expand/cut vectors, similar to diagr(), automatically adds/drops ending elements


# module begins --------------------
    """
        diagw( MAT::Matrix, VEC::Union{Vector,Tuple,NamedTuple,AbstractRange} ; offset::Int = 0 )

    Julia versions: 1.0+;
    Writes a vector "VEC" into a matrix "MAT" diagonally, according to offset= (value starts from 0).
	Returns a copy of MAT;

	# Depends:
	1. LinearAlgebra.diagind()
    """
    function diagw( MAT::Matrix, VEC::Union{Vector,Tuple,NamedTuple,AbstractRange} ; offset::Int = 0 )
        # validation
        LEN = length(VEC)
		# operate on copy
        MAT=copy(MAT); VEC = copy(VEC)
        # get indexes range
		tmpIdxRange = diagind(MAT, offset)
		# fill elements
		for s in 1:min( LEN, length(tmpIdxRange) )
			MAT[ tmpIdxRange[s] ] = VEC[s]
		end
        # return the copy of MAT
        return MAT::Matrix
    end
	# -------------------------------------------------------------------
	"""
        diagw!( MAT::Matrix, VEC::Union{Vector,Tuple,NamedTuple,AbstractRange} ; offset::Int = 0 )

    Julia versions: 1.0+;
    Writes a vector "VEC" into a matrix "MAT" diagonally, according to offset= (value starts from 0).
	Operates in-place, no return;

	# Depends:
	1. LinearAlgebra.diagind()
    """
    function diagw!( MAT::Matrix, VEC::Union{Vector,Tuple,NamedTuple,AbstractRange} ; offset::Int = 0 )
        # validation
        LEN = length(VEC)
        # get indexes range
		tmpIdxRange = diagind(MAT, offset)
		# fill elements
		for s in 1:min( LEN, length(tmpIdxRange) )
			MAT[ tmpIdxRange[s] ] = VEC[s]
		end
        # return the copy of MAT
        return nothing
    end
	# -------------------------------------------------------------------
	"""
		diagr( MAT::Matrix; offset::Int = 0, LEN::Int = length(diagind(MAT,offset)) )

	reads diagonal elements according to offset=;
	if LEN > length(diagind(MAT,offset)), automatically repeat the last element;
	if LEN < length(diagind(MAT,offset)), automatically drop the ending elements;
	returns a vector;

	# Depends:
	1. LinearAlgebra.diagind()
	2. LinearAlgebra.diag()
	"""
	function diagr( MAT::Matrix; offset::Int = 0, LEN::Int = length(diagind(MAT,offset)) )
		# get diagonal elements
		tmpVal = diag(MAT,offset); tmpLen = length(Val)
		# add or cut
		if LEN > tmpLen
			append!(tmpVal, fill(Val[end],LEN-tmpLen) )
		elseif LEN < tmpLen
			tmpVal = tmpVal[1:LEN]
		end
		return tmpVal
	end
	# -------------------------------------------------------------------
	"""
		year2idx( SubYearRange::Union{AbstractRange,Vector{Int}}, YearRange::Union{AbstractRange,Vector{Int}} )

	returns index array of locations of SubYearRange in YearRange
	"""
	function year2idx( SubYearRange::Union{AbstractRange,Vector{Int}}, YearRange::Union{AbstractRange,Vector{Int}} )
		tmpVal = ones(Int,0)  # initialize an empty Vector{Int} (Array{Int,1})
		for x in SubYearRange
			push!( tmpVal, findfirst( YearRange .== x ) )
		end
		return tmpVal
	end
	# -------------------------------------------------------------------
	"""
		vecExpand( VEC::Vector, LEN::Int )

	expands VEC to specific length LEN;
	if LEN > length(VEC), fill extra positions with the last element of VEC;
	if LEN < length(VEC), drop the ending elements;
	returns a Vector/1-D Array
	"""
	function vecExpand( VEC::Vector, LEN::Int )
		@assert( LEN >= 0, "LEN must be a non-negative integer" )
		tmpLen = length(VEC); tmpVec = copy(VEC)
		if LEN > tmpLen
			tmpVal = tmpVec[end]
			for s in range( tmpLen+1, length= LEN-tmpLen )
				push!( tmpVec, tmpVal )
			end
			return tmpVec
		else
			return tmpVec[1:LEN]
		end
		return nothing
	end
	# -------------------------------------------------------------------







































end # module ends
# ---------------------
