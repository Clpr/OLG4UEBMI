
# SECTION 2: fertility experiments plotting
# ---------------------------------------
# ---------------------------------------
# 2.1 Fertility experiments and UE-BMI
   # 2.1.1 a temp macro for fast plotting
   macro fastexpr( Ylab::String, Loc::String )
      return :(
         grid(true); xlabel("Year"); ylabel($Ylab);
         legend(( "Benchmark", "High Fertility", "Low Fertility" ), loc = $Loc );
      )
   end
   # 2.1.2 do plotting
   # NOTE: it is a 4-subfigure figure
   figure(figsize = (13,8))
      subplot(2,2,1)  # gap / pool expenditure
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolExp] )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ DatPkg_high.Dt[:AggPoolExp] )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ DatPkg_low.Dt[:AggPoolExp] )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / Pool Expenditures (%)", "upper left" )
      subplot(2,2,2)  # gap / pool income
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolIn] )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ DatPkg_high.Dt[:AggPoolIn] )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ DatPkg_low.Dt[:AggPoolIn] )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / Pool Incomes (%)", "upper left" )
      subplot(2,2,3)  # gap / GDP
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:Y] )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ DatPkg_high.Dt[:Y] )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ DatPkg_low.Dt[:Y] )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / GDP (%)", "upper left" )
      subplot(2,2,4)  # gap / tax revenues
         plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ (DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc]) )[idx_plot]  );
         plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI] ./ (DatPkg_high.Dt[:TRw] .+ DatPkg_high.Dt[:TRc]) )[idx_plot], "-.b" );
         plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI] ./ (DatPkg_low.Dt[:TRw] .+ DatPkg_low.Dt[:TRc]) )[idx_plot], "--r" );
         @fastexpr( "Pool Gap / Tax Revenues (%)", "upper left" )
      tight_layout()
   # 2.1.3 save figure
   savefig( "./output/FertilityShockProfile.pdf", format = "pdf" )








   # 2.2 Summary table for benchmark & fertility experiments
      # 2.2.1 a function to summarize a DatPkg_, where x is the index to slice the transition path
      afunc_SummaryDatPkg( d::NamedTuple, year::Int ) = begin
         local v::Vector{Any} = []
         # convert year -> index
         x = year - env.START_YEAR + 1

         # 0. population size
         push!(v, d.Dt[:N][x] )
         # 1. gdp per capita
         push!(v, d.Dt[:Y][x] / d.Dt[:N][x] )
         # 2. capital per capita
         push!(v, d.Dt[:K][x] / d.Dt[:N][x] )
         # 3. consumption per capita
         push!(v, d.Dt[:C][x] / d.Dt[:N][x] )
         # 4. health expenditure per capita
         push!(v, sum(d.Dst[:m][x,:] .* d.Ps[:N][x,:]) / d.Dt[:N][x] )
         # 5. outpatient expenditure per capita
         push!(v, sum(d.Dst[:MA][x,:] .* d.Ps[:N][x,:]) / d.Dt[:N][x] )
         # 6. inpatient expenditure per capita
         push!(v, sum(d.Dst[:MB][x,:] .* d.Ps[:N][x,:]) / d.Dt[:N][x] )
         # 7. investment per capita
         push!(v, d.Dt[:I][x] / d.Dt[:N][x] )
         # 8. labor supply per capita (endowment = 1)
         push!(v, d.Dt[:L][x] / d.Dt[:N][x] )
         # 9. average wage level (wage rate)
         push!(v, d.Dt[:w̄][x] )
         # 10. interest rate (net investment returns) (%)
         push!(v, 100 * d.Dt[:r][x] )
         # 11. income tax revenues
         push!(v, d.Dt[:TRw][x] )
         # 12. consumption tax revenues
         push!(v, d.Dt[:TRc][x] )
         # 13. gov purchase / GDP (%)
         push!(v, 100 * d.Dt[:G][x] / d.Dt[:Y][x] )
         # 14. UEBMI pooling gap / GDP (%)
         push!(v, 100 * d.Dt[:LI][x] / d.Dt[:Y][x] )

         return v::Vector{Any}
      end # func
      # 2.2.2 prepare a column of variable names
      tmpvarlist = [
         "Population size", "Output per capita", "Capital per capita",
         "Consumption per capita", "Health expenditure per capita", "Outpatient expenditure per capita",
         "Inpatient expenditure per capita", "Investment per capita",
         "Labor supply per capita (endowment=1)", "Average wage rate",
         "Interest rate (%)", "Income tax revenues", "Consumption tax revenues",
         "Government purchase / Output (%)", "UE-BMI's pooling gap / Output (%)"
      ]
      # 2.2.3 summary benchmark in different years
      df_SummaryFertility = DataFrames.DataFrame(
         :Variables => tmpvarlist,
         :Year2010 => afunc_SummaryDatPkg( DatPkg_base, 2010 ),
         :Year2020 => afunc_SummaryDatPkg( DatPkg_base, 2020 ),
         :Year2050 => afunc_SummaryDatPkg( DatPkg_base, 2050 ),
         :Year2110 => afunc_SummaryDatPkg( DatPkg_base, 2110 ),
         :FinalSS  => afunc_SummaryDatPkg( DatPkg_base, 2344 ),
      )
      # 2.2.4 output to a csv file
      CSV.write( "$(pwd())/output/SummaryBench.csv" , df_SummaryFertility )

















#
