plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:N] )[idx_plot]  );
plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( DatPkg_high.Dt[:LI]  ./ DatPkg_high.Dt[:N]  )[idx_plot], "-.b" );
plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( DatPkg_low.Dt[:LI]  ./ DatPkg_low.Dt[:N] )[idx_plot], "--r" );
legend(["base","high","low"]); grid(true)






plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( 1.0 .- dict_Demog_base["LaborPopu"] ./ dict_Demog_base["TotalPopu"] )[idx_plot]  );
plot( DatPkg_high.Dt[:Year][idx_plot], 100 .* ( 1.0 .- dict_Demog_high["LaborPopu"]  ./ dict_Demog_high["TotalPopu"]  )[idx_plot], "-.b" );
plot( DatPkg_low.Dt[:Year][idx_plot], 100 .* ( 1.0 .- dict_Demog_low["LaborPopu"]  ./ dict_Demog_low["TotalPopu"] )[idx_plot], "--r" );
legend(["base","high","low"]); grid(true)
title(L"\rho")



expr_GetDemogDat = :(
   Dict( "TotalPopu" => Dt[:N],
      "LaborPopu" => sum(Ps[:N][:,1:env.Sr],dims=2)[:],
      "AgingPopu_65plus" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:],
      "AgingPopuRatio" => sum(Ps[:N][:, (65 - env.START_AGE + 1):env.S],dims=2)[:] ./ sum(Ps[:N][:,1:env.Sr],dims=2)[:]
   )
)


figure()
   subplot(1,3,1)
      plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( DatPkg_base.Dt[:LI] ./ DatPkg_base.Dt[:N] )[idx_plot]  );
      plot( DatPkg_base.Dt[:Year][idx_plot], 100 .* ( 1.0 .- dict_Demog_base["LaborPopu"] ./ dict_Demog_base["TotalPopu"] )[idx_plot]  );
      legend(["gap/exp",L"\rho"])
   subplot(1,3,2)











#
