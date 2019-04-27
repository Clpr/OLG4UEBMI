# 3.6 profile the economies under the 5 (including benchmark) scenarios
# NOTE: the crowding out effect
idx_plot = (2015:2025) .- env.START_YEAR .+ 1
plot_symbol = :K
tmpexpr = :(
   xlabel("Year"); grid(true);
   xlim([ idx_plot[1] - 2 + env.START_YEAR, idx_plot[end] + env.START_YEAR ]);
)
figure(figsize = (9,5)) # (C+I)/G
      for tmpreform in 1:length(res_IndiInDesc["reformNames"])
         tmpploty = (res_IndiInDesc["Dt"][tmpreform][:C] .+ res_IndiInDesc["Dt"][tmpreform][:I]  ) ./ res_IndiInDesc["Dt"][tmpreform][:G]
         plot( Dt[:Year][idx_plot], 100 .* tmpploty[idx_plot], res_IndiInDesc["plotstyles"][tmpreform] )
      end
      eval(tmpexpr); ylabel("(C+I)/G (%)");
      legend( res_IndiInDesc["plotlegends"] , loc = "best")
# 3.7 save figure
savefig( "./output/CrowdingOutEffect.pdf", format = "pdf" )





#
