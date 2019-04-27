
# 2.4 plotting
   tmpexpr = :(
      xlabel("Year"); grid(true);
      xlim([ idx_year2plot[1] - 1, idx_year2plot[end] + 1 ]);
   )
   figure(figsize = (13,8))
      subplot(2,2,1)  # gap / exp
         for tmpzeta in 1:length(reform_zeta_levs)
            plot( Dt[:Year][idx_plot], res_ContriRatRise["gap/exp"][tmpzeta], reform_zeta_stys[tmpzeta] )
         end
         eval(tmpexpr); ylabel("Gap / Pool Expenditure (%)");
         legend( string.("ζ = ",reform_zeta_levs) , loc = "lower right")
      subplot(2,2,2)  # gap / in
         for tmpzeta in 1:length(reform_zeta_levs)
            plot( Dt[:Year][idx_plot], res_ContriRatRise["gap/in"][tmpzeta], reform_zeta_stys[tmpzeta] )
         end
         eval(tmpexpr); ylabel("Gap / Pool Income (%)");
         # legend( string.("ζ = ",reform_zeta_levs) , loc = "upper left")
      subplot(2,2,3)  # gap / gdp
         for tmpzeta in 1:length(reform_zeta_levs)
            plot( Dt[:Year][idx_plot], res_ContriRatRise["gap/gdp"][tmpzeta], reform_zeta_stys[tmpzeta] )
         end
         eval(tmpexpr); ylabel("Gap / GDP (%)");
         # legend( string.("ζ = ",reform_zeta_levs) , loc = "upper left")
      subplot(2,2,4)  # gap / taxrev
         for tmpzeta in 1:length(reform_zeta_levs)
            plot( Dt[:Year][idx_plot], res_ContriRatRise["gap/taxrev"][tmpzeta], reform_zeta_stys[tmpzeta] )
         end
         eval(tmpexpr); ylabel("Gap / Tax Revenues (%)");
         # legend( string.("ζ = ",reform_zeta_levs) , loc = "upper left")
      tight_layout()
# 2.5 save figure
savefig( "./output/ContributionRateRise.pdf", format = "pdf" )





#
