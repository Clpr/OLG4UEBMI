# 测试稳态与死亡率关系的脚本

t = env.T

@time EasySearch.SteadyState!( t, Guess,
   Dt, Dst, Pt, Ps, Pc, env,
   atol = 1E-8,  # tolerance of Gauss-Seidel iteration
   MaxIter = 50,  # maximum loops
   PrintMode = "final",  # mode of printing
   MagicNum = 2.0,  # magic number, the lower bound of K/L (capital per labor)
   StepLen = 0.5  # relative step length to update guesses, in range (0,1]
)
PyPlot.subplot(2,2,1)
   PyPlot.plot(Ps[:F][t,:])
PyPlot.subplot(2,2,2)
   PyPlot.plot(Dst[:𝒜][t,:])
PyPlot.subplot(2,2,3)
   PyPlot.plot(Ps[:N][t,:])
PyPlot.tight_layout()




# # 3. plotting & output
# EasyPlot.Plot_SteadyState( 1, Dt, Dst, Pt, Ps, Pc, env,
#    outpdf = string("./output/", "InitSS_", EasyIO.LogTag(), ".pdf" )
#    )



PyPlot.plot(diff(Ps[:N][env.T,:]) )































#
