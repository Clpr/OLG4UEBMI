
# 3.4 plotting
tmpexpr = :(
   xlabel("Year"); grid(true);
   xlim([ idx_year2plot[1] - 1, idx_year2plot[end] + 1 ]);
)
figure(figsize = (13,8))
   subplot(2,2,1)  # gap / exp
      for tmpreform in 1:length(res_IndiInDesc["reformNames"])
         plot( Dt[:Year][idx_plot], res_IndiInDesc["gap/exp"][tmpreform], res_IndiInDesc["plotstyles"][tmpreform] )
      end
      eval(tmpexpr); ylabel("Gap / Pool Expenditure (%)");
      legend( res_IndiInDesc["plotlegends"] , loc = "lower right")
   subplot(2,2,2)  # gap / in
      for tmpreform in 1:length(res_IndiInDesc["reformNames"])
         plot( Dt[:Year][idx_plot], res_IndiInDesc["gap/in"][tmpreform], res_IndiInDesc["plotstyles"][tmpreform] )
      end
      eval(tmpexpr); ylabel("Gap / Pool Income (%)");
      # legend( string.("ζ = ",reform_zeta_levs) , loc = "upper left")
   subplot(2,2,3)  # gap / gdp
      for tmpreform in 1:length(res_IndiInDesc["reformNames"])
         plot( Dt[:Year][idx_plot], res_IndiInDesc["gap/gdp"][tmpreform], res_IndiInDesc["plotstyles"][tmpreform] )
      end
      eval(tmpexpr); ylabel("Gap / GDP (%)");
      # legend( string.("ζ = ",reform_zeta_levs) , loc = "upper left")
   subplot(2,2,4)  # gap / taxrev
      for tmpreform in 1:length(res_IndiInDesc["reformNames"])
         plot( Dt[:Year][idx_plot], res_IndiInDesc["gap/taxrev"][tmpreform], res_IndiInDesc["plotstyles"][tmpreform] )
      end
      eval(tmpexpr); ylabel("Gap / Tax Revenues (%)");
      # legend( string.("ζ = ",reform_zeta_levs) , loc = "upper left")
   tight_layout()
# 3.5 save figure
savefig( "./output/IndiAcctReform.pdf", format = "pdf" )



#
