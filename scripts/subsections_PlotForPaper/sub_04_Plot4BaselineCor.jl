
# SECTION 3: other visualization in BENCHMARK & fertility experiments
# ----------------------------------------------
# 3.1 benchmark: correlations (during plotting years)
   println(
      "Cor between Aging Population Ratio & gap/pool expenditures: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolExp])[idx_plot] )
   )
   println(
      "Cor between Aging Population Ratio & gap/pool incomes: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:AggPoolIn])[idx_plot] )
   )
   println(
      "Cor between Aging Population Ratio & gap/GDP: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:Y])[idx_plot] )
   )
   println(
      "Cor between Aging Population Ratio & gap/tax revenues: ",
      Statistics.cor( dict_Demog_base["AgingPopuRatio"][idx_plot], (DatPkg_base.Dt[:LI] ./ ( DatPkg_base.Dt[:TRw] .+ DatPkg_base.Dt[:TRc] ) )[idx_plot] )
   )



#
