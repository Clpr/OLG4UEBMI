# plotting (ζ -> 2020's relative deviation from benchmark)
afunc_PctRelDeviaFrom1stElement( x::AbstractArray ) = (x ./ x[1] .- 1.0) .* 100
figure(figsize = (8,4))
      plot( afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["zetalevels"]) ,
            afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["gap/exp"]), "-" )
      plot( afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["zetalevels"]) ,
            afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["gap/in"]), "-.b" )
      # plot( afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["zetalevels"]) ,
      #       afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["gap/gdp"]), "--r" )
      # plot( afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["zetalevels"]) ,
      #       afunc_PctRelDeviaFrom1stElement(res_ContriRatRise["gap/taxrev"]), ":m" )
      ylabel("Relative Deviation from Benchmark (%)");
      xlabel("ζ - Relative Deviation from Benchmark (%)");
      grid(true);
      legend([ "Gap / Pool Expenditure",
               # "Gap / Tax Revenues"
               # "Gap / GDP",
               "Gap / Pool Income", ], loc = "best");
      tight_layout()
# save figure
savefig( "./output/ContributionRateRise_Elasticity.pdf", format = "pdf" )




#
