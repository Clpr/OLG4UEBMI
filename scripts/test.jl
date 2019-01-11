tmpOriginData = Dict(
    # ---------- Constants
    :Smax => 10,  # maximum age
    :Sret => 1,  # retirement age
    :alpha => 1.5, # leisure preference than consumption
    :gamma => 0.5, # the inter-temporal elasticity of substitution
    :k1 => 0.0, # capital when born
    # ---------- Vectors
    :Survival => fill(0.001, 10),  # survival probabilities between two years
    :q => fill(0.15, 10),  # the ratio of health expenditure on consumption
    :r => fill(0.08, 10),  # interest rate
    :w => fill(3.25, 1),  # wage level
    :z => fill(0.85, 1),  # the collection rate of PAYG pension
    :θ => fill(0.08, 1),  # contribution: agent -> PAYG pension
    :η => fill(0.20, 1),  # contribution: firm  -> PAYG pension
    :ϕ => fill(0.02, 1),  # contribution: agent -> UEBMI
    :ζ => fill(0.06, 1),  # contribution: firm  -> UEBMI
    :cpB => fill(0.30, 10),  # copayment rate of UEBMI (inhospital)
    :p => fill(1.10, 10),  # the ratio of outpatient expenditure on inpatient expenditure
    :Λ => fill(0.95, 10-1),  # the benefits of PAYG pension
    :𝕡 => fill(0.10, 10-1),  # the amount of the transfer payment from this year's firm contribution to UEBMI to those have retired in this year
    :𝕒 => fill(0.30, 1),  # the rate of the money transferred from this year's firm contribution to those working men's individual account of UEBMI
    # ------------ Constant in this paper but converted to vectors
    :σ => fill(0.24, 1),  # wage taxation
    :μ => fill(0.10, 10),  # consumption taxation
    :δ => fill(1/0.99 - 1, 10), # the discounting rate of utility
)
# 正常working+retire
# tmpOriginData = House.SampleOrigindata;
tmpConst, tmpDict = House.lev0Abbr( tmpOriginData )
# tmpConst = House.SampleConst; tmpDict = copy(House.SampleLev0Abbr);
House.lev1Abbr!(tmpDict,tmpConst)
House.lev2Abbr!(tmpDict,tmpConst)
tmpcs, tmpls = House.getcls( 0.1, tmpDict, tmpConst )
tmpks = House.getks( tmpcs, tmpls, tmpDict, tmpConst )
House.G( 0.1, tmpDict, tmpConst )
@time tmpRes = House.HHSolve( tmpOriginData , ReturnData = true )
House.ExtractAPhi!( tmpRes, tmpOriginData , a1 = 0.0 )

# 只有1期working
tmpOriginData1 = House.SampleOrigindata1;
tmpConst1, tmpDict1 = House.lev0Abbr( tmpOriginData1 )
# tmpConst1 = House.SampleConst1; tmpDict1 = copy(House.SampleLev0Abbr1);
House.lev1Abbr!(tmpDict1,tmpConst1)
House.lev2Abbr!(tmpDict1,tmpConst1)
tmpcs1, tmpls1 = House.getcls( 0.1, tmpDict1, tmpConst1 )
tmpks1 = House.getks( tmpcs1, tmpls1, tmpDict1, tmpConst1 )
House.G( 0.1, tmpDict1, tmpConst1 )
@time tmpRes1 = House.HHSolve( tmpOriginData1 , ReturnData = true )
House.ExtractAPhi!( tmpRes1, tmpOriginData1 , a1 = 0.0 )


# 只有退休期
tmpOriginData_Retired = House.SampleOrigindata_Retired;
tmpConst_Retired, tmpDict_Retired = House.lev0Abbr_Retired( tmpOriginData_Retired )
# tmpConst_Retired = House.SampleConst_Retired; tmpDict_Retired = copy(House.SampleLev0Abbr_Retired);
House.lev1Abbr_Retired!(tmpDict_Retired,tmpConst_Retired)
House.lev2Abbr_Retired!(tmpDict_Retired,tmpConst_Retired)
tmpcs_Retired = House.getcls_Retired( 0.1, tmpDict_Retired, tmpConst_Retired )
tmpks_Retired = House.getks_Retired( tmpcs_Retired, tmpDict_Retired, tmpConst_Retired )
House.G_Retired( 0.1, tmpDict_Retired, tmpConst_Retired )
@time tmpRes_Retired = House.HHSolve_Retired( tmpOriginData_Retired , ReturnData = true )
House.ExtractAPhi_Retired!( tmpRes_Retired, tmpOriginData_Retired , a1 = 0.0 )


# 只有1期退休期
tmpOriginData_Retired1 = House.SampleOrigindata_Retired1;
tmpConst_Retired1, tmpDict_Retired1 = House.lev0Abbr_Retired( tmpOriginData_Retired1 )
# tmpConst_Retired1 = House.SampleConst_Retired1; tmpDict_Retired1 = copy(House.SampleLev0Abbr_Retired1);
House.lev1Abbr_Retired!(tmpDict_Retired1,tmpConst_Retired1)
House.lev2Abbr_Retired!(tmpDict_Retired1,tmpConst_Retired1)
tmpcs_Retired1 = House.getcls_Retired( 0.1, tmpDict_Retired1, tmpConst_Retired1 )
tmpks_Retired1 = House.getks_Retired( tmpcs_Retired1, tmpDict_Retired1, tmpConst_Retired1 )
House.G_Retired( 0.1, tmpDict_Retired1, tmpConst_Retired1 )
@time tmpRes_Retired1 = House.HHSolve_Retired( tmpOriginData_Retired1 , ReturnData = true )
House.ExtractAPhi_Retired!( tmpRes_Retired1, tmpOriginData_Retired1 , a1 = 0.0 )















#
