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
	if LEN > length(diagind(MAT,offset)), automatically use elements of the last row to append (continuing the last element); if still not enough, repeat the last element of matrix; 如果指定长度大于该offset处对角线向量的长度，那么用矩阵最后一行的元素，接着对角线结束处填充，如果还不够，则用矩阵最后一个元素重复填充
	if LEN < length(diagind(MAT,offset)), automatically drop the ending elements;
	returns a vector;

	## Depends:
	1. LinearAlgebra.diagind()
	2. LinearAlgebra.diag()

	## An example of case LEN > length
	for a matrix [1 2 3; 4 5 6] (a 2×3 matrix), if offset = 0 & LEN = 2 = min(row,col), then we get [1,5];
	if LEN = 3 ≦ max(row,col), we get [1,5,6]; if LEN = 6 > max(row,col), we get [1,5,6,6,6,6];
	## Another example:
	for a matrix [1 2 3; 4 5 6; 7 8 9; 10 11 12] (a 4×3 matrix), there are cases:
	1. offset = 0 < min(row,col)-1 & LEN = 2 < min(row,col): [1,5]
	2. offset = 0 < min(row,col)-1 & LEN = 3 = min(row,col): [1,5,9]
	3. offset = 0 < min(row,col)-1 & LEN = 6 > min(row,col): [1,5,9,9,9,9]
	4. offset = -2 = 1 - min(row,col) & LEN = 2: [7,11]
	5. offset = -2 = 1 - min(row,col) & LEN = 3 = min(col,row): [7,11,12]
	5. offset = -2 = 1 - min(row,col) & LEN = 5 > min(col,row): [7,11,12,12,12]
	6. offset = 1 > 0 & LEN = 5: [2,6,6,6,6]

	## p.s. there are relationships universal for all matrix to help to understand the function:
	obviously, offset is always in range [1-r, c-1], where r is number of rows, c is number of columns;
	denote rawLEN as length(diag(MAT,offset)), i.e. length of original diagonal vector;
	then, for the function *rawLEN(offset)*, there are three cases (with offset from 1-r to c-1):
	1. Case 1: touching the last/bottom row, where offset ∈ [1-r, X], X is an unknown integer
	3. Case 2: touching the last/right column, where offset ∈ [X, c-1]
	What we need to do is determine X & Y for different cases of r & c.
	There are three (in fact, two) cases of r & c: 1. r < c; 2. r = c; 3. r > c.
	We then have:
	1. for r < c: X = r - 1
	2. for r = c: X = 0
	3. for r > c: X = 1 - c

	## Depends on:
	1. vecExpand [EasyMath]
	"""
	function diagr( MAT::Matrix; offset::Int = 0, LEN::Int = length(diagind(MAT,offset)) )
		# measures
		local r,c = size(MAT);
		# get diagonal elements
		tmpVal = diag(MAT,offset); tmpLen = length(tmpVal)
		# add or cut
		if LEN > tmpLen  # need to add extra elements
			if r > c
				if offset < 1 - c
					append!( tmpVal, vecExpand(MAT[end,tmpLen+1:end], LEN - tmpLen) )  # use left elements in the last row to continue tmpVal, if not enough, repeat the very last element of MAT
				else
					append!( tmpVal, fill(tmpVal[end], LEN - tmpLen) )  # if not touching the very last row, just repeat the last element of tmpVal
				end
			else  # (r < c)
				if offset < r - 1
					append!( tmpVal, vecExpand(MAT[end,tmpLen+1:end], LEN - tmpLen) )
				else
					append!( tmpVal, fill(tmpVal[end], LEN - tmpLen) )
				end
			end
		elseif LEN < tmpLen  # just drop extra elements
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
