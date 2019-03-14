# REFINE OF HOUSEHOLD PROBLEM

## $q_t\to q_{s,t}$

现状：统计局数据统计的$q_t$是不含报销部分的expenditure，而我们的$q_{s,t}=m_{s,t} / c_{s,t}$是包含了报销部分的，所以统计局数字需要调整一下。将统计局直接统计出的居民人均医疗支出/总消费的比例记作$\tilde{q}_{t}$（注意，统计局给出的是某一年的平均值。
$$
\frac{p_s {cp}^A_t + {cp}^B_t}{1+p_s} q_{s,t} = \tilde{q}_t
$$
其实这一版模型里没有${cp}^A_t$，但因为统计局只统计流量数字（不包含医保账户），而门诊支出实际上是以savings支付的，所以在变换时候要考虑。UE-BMI的${cp}^A_t​$设定为固定的40%。





## 问题表述

澄清家庭问题的公式（预算约束）：

首先，家庭问题的==工作期==跨期预算约束（两个名义账户）：
$$
\begin{cases}
	\mathbb{S}_{s,t} a_{s+1,t+1} = (1+r_{t}) a_{s,t} + ( 1 - \sigma_s - \pi_t - \pi^M_t) w_{s,t}l_{s,t} - (1+\mu_t) [c_s - m^A_{s,t} + (1-{cp}^B_t) m^B_{s,t}] - \Delta_{s,t}, s = 1,\dots,S_r  \\
	\mathbb{S}_{s,t} \Phi_{s+1,t+1} = (1+r_{t}) \Phi_{s,t} + \frac{\Phi_t + \mathbb{A}_t \zeta_t}{1 + z_t \eta_t + \zeta_t} w_{s,t} l_{s,t} - (1+\mu_t) m^A_{s,t} + \Delta_{s,t}, s = 1,\dots,S_r  \\
\end{cases}
$$
合并而来的个人资本$k_{s,t}$：
$$
{S}_{s,t} k_{s+1,t+1} = (1+r_{t}) k_{s,t} + ( 1 - \sigma_s - \pi_t - \pi^M_t + \frac{\Phi_t + \mathbb{A}_t \zeta_t}{1 + z_t \eta_t + \zeta_t}) w_{s,t}l_{s,t} - (1+\mu_t) [c_s + (1-{cp}^B_t) m^B_{s,t}]
$$
退休期的两个名义账户：
$$
\begin{cases}
	\mathbb{S}_{s,t} a_{s+1,t+1} = (1+r_{t}) a_{s,t} + \Lambda_t - (1+\mu_t) [c_s - m^A_{s,t} + (1-{cp}^B_t) m^B_{s,t}] - \Delta_{s,t}, s = S_r+1,\dots,S  \\
	\mathbb{S}_{s,t} \Phi_{s+1,t+1} = (1+r_{t}) \Phi_{s,t} + \mathbb{P}_t - (1+\mu_t) m^A_{s,t} + \Delta_{s,t}, s = S_r+1,\dots,S  \\
	\end{cases}
$$
合并而来的个人资本：
$$
{S}_{s,t} k_{s+1,t+1} = (1+r_{t}) k_{s,t} + \Lambda_t + \mathbb{P}_t  - (1+\mu_t) [c_s + (1-{cp}^B_t) m^B_{s,t}]
$$
将两个时期合并起来：
$$
\begin{cases}
{S}_{s,t} k_{s+1,t+1} = (1+r_{t}) k_{s,t} + ( 1 - \sigma_s - \pi_t - \pi^M_t + \frac{\Phi_t + \mathbb{A}_t \zeta_t}{1 + z_t \eta_t + \zeta_t}) w_{s,t}l_{s,t} - (1+\mu_t) [c_s + (1-{cp}^B_t) m^B_{s,t}]   \\
{S}_{s,t} k_{s+1,t+1} = (1+r_{t}) k_{s,t} + \Lambda_t + \mathbb{P}_t  - (1+\mu_t) [c_s + (1-{cp}^B_t) m^B_{s,t}]
\end{cases}
$$
代入$m^B_{s,t} = q_{s,t}\frac{1}{1+p_s}c_{s,t}$和$m^A_{s,t} = q_{s,t}\frac{p_s}{1+p_s}c_{s,t}$
$$
\begin{cases}
{S}_{s,t} k_{s+1,t+1} = (1+r_{t}) k_{s,t} + ( 1 - \sigma_s - \pi_t - \pi^M_t + \frac{\Phi_t + \mathbb{A}_t \zeta_t}{1 + z_t \eta_t + \zeta_t}) w_{s,t}l_{s,t} - (1+\mu_t)[ 1+(1-{cp}^B_t)q_{s,t}\frac{1}{1+p_s} ] c_s   \\
{S}_{s,t} k_{s+1,t+1} = (1+r_{t}) k_{s,t} + \Lambda_t + \mathbb{P}_t  - (1+\mu_t)[ 1+(1-{cp}^B_t)q_{s,t}\frac{1}{1+p_s} ] c_s
\end{cases}
$$


## 标准形式

（其实主要是$E_s$变了）

现在是：
$$
E_s = (1+\mu_t)[ 1+(1-{cp}^B_t)q_{s,t}\frac{1}{1+p_s} ]
$$
原来是：
$$
E_s = 1+\mu_t - (1-{cp}^B_t)q_{s,t}\frac{1}{1+p_s}
$$




















