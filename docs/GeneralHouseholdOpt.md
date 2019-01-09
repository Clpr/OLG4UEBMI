<head>
    <style>
        body {font-family:"Times New Roman"; font-size:20px}
    </style>
</head>
<!-- encoding UTF-8 -->

# Notes of a general household life-cycle problem with linear budget
*Tianhao Zhao (GitHub: Clpr) Jan 2019*

## Background



------------------------------
## Assumptions
### Denotation
1. lowercase letters, such as $c,k,l$, are used to denote the variables with economic meanings
2. capital letters, such as $A,B,C$, are used to denote general algebrae. These algebrae are usually input by users
3. specifically, $s$ denotes time/moment/period; $c$ denotes consumption; $l$ denotes **labor** (not leisure!); $k$ denotes wealth/capital; $b$ denotes bequests (if applicable)
### Demography
1. One life-cycle problem is solved for only a (group of homogeneous) agent(s). If there are multiple agent groups (e.g. income groups), each group's life-cycle problem needs to be separately solved.
2. Finite life expectancy, where the maximum limit of life is $S\geq2$ (years).
3. Determined retirement age $1 \leq S_r < S$, i.e. an agent works for $S_r$ years.
4. $s = 1,\dots,S+1$ is used to denote the moment of the **beginning** of a year; e.g. when we talk about "year $t$", it means we are talking about a period from the moment $s=t,s=1,\dots,S$ to moment $s=t+1$. However, we define some special moments:
   1. An agent is born at the **beginning** of the 1st year; the moment of birth is marked as $s=1$.
   2. An agent begins to work when born at the moment $s=1$, then retires at the **end** of the last working year $S_r$; the moment of retirement is marked as $s=S_r+1$. It means that the agent is still working in year $S_r$. He/she becomes retired at moment $S_r+1$ (the beginning of age-year $S_r+1$!), then he/she begins to receive pension benefits in year $S_r+1$.
   3. An agent dies at the **end** of the very last year, where the moment is marked as $s=S+1$. It means this agent spends his last year, makes all deals (e.g. consumptions) then dies at the end of year $S$.
5. Deaths, no matter accidental deaths before $s=S+1$ or the fatal natural death at moment $s=S+1$, always happen at the end of years, i.e. agents always finish other activities such as consumption in their dead years before the moment of death.
6. No agent dies at moment $s=1$ (no die-young case considered)

### Utility
1. Cross-sectional utility function $u(c,l)$ is defined as the utility obtained from one year's consumption and labor supply. $u(c,l)$ is consumption-labor separable, i.e. $u(c_s,l_s) = u_1(c_s) + u_2(l_s)$
2. Agents try to maximize $U$, the summation of the present values of every year's cross-sectional utilities. The optimization can be denoted with a Bellman equation.
3. Agents use utility discounting factors $\beta_s \neq 0,1\leq s\leq S$ to discount the cross-sectional utility $u(c_s,l_s)$ in year $s$ to moment $s-1$. 



### Consumption, Work, Retirement
1. Agents only care his/her private interests; no children's interests considered.
2. Perfect forward-looking.
3. Agents possess capital $k_s,s=1,\dots,S+1$, where $k_s$ is a moment amount. $k_s$ denotes the capital at the **beginning** of year $s$.
4. Agent decide every year's consumption $c_s,s=1,\dots,S$ & labor $0\leq l_s\leq \bar{l}_s,s=1,\dots,S_r$, where $\bar{l}_s$ is time endowment; by default, $\bar{l}_s \equiv 1$ for each $s$. And, be careful, both $c_s$ & $l_s$ is a period amount, i.e. they indicates the consumption/labor during the period from moment $s=s$ to moment $s=s+1$.
5. For the convenient of computing, $l_s\equiv 0$ for $s=S_r,\dots,S$.
6. No final bequest left, i.e. agents always try to spend all their capital before natural fatal death at $s=S+1$.
7. No capital when born.
8. Capital is never less than zero ($k_s\geq 0$)

### Budget Constraint
1. Agents' consumption & labor supply are constrained by **linear** inter-temporal budget constraints: 
   1. Before retirement: $A_s k_{s+1} = B_s k_{s} + D_s l_s - E_s c_s + F_s, 1\leq s \leq S_r$
   2. After retirement: $A_s k_{s+1} = B_s k_{s} - E_s c_s + F_s, S_r< s\leq S$
   3. where $A_s>0$ is a multiplier; $B_s>0$ is a multiplier; $D_s, E_s \neq 0$ are multipliers; and $F_s \in \bm{R}$ is the extra cash/capital flows not related to possessed capital, labor or consumption.
2. According to our assumptions in previous sections, we have some boundary conditions:
   1. $A_s k_{2} = D_1 l_1 - E_1 c_1 + F_1$, which is equivalent to $k_1 \equiv 0$.
   2. $0 = B_S k_{S} + D_S l_S - E_S c_S + F_S$, which is equivalent to $k_{S+1} \equiv 0$.


----------------------------
## Mathematics: Problem Statements (DP)
This life-cycle problem can be written as a standard DP problem:
$$
v(s) = \max_{c_s,l_s} [ u(c_s,l_s) + \beta_s v(s+1) ], s=1,\dots,S \\
s.t. \begin{cases}
A_s k_{s+1} = B_s k_{s} + D_s l_s - E_s c_s + F_s, 1\leq s \leq S \\
l_s = 0, s=S_r+1,\dots,S \\
k_1 = k_{S+1} = 0 \\
v(S+1) = 0 \\
-k_s \leq 0, s= 1,\dots,S+1 \\
-c_s \leq 0, s = 1,\dots,S \\
l_s \leq \bar{l_s}, s=1,\dots,S_r \\
-l_s \leq 0, s=1,\dots,S_r \\
\end{cases} 
\tag{1}$$
where $A_s>0,B_s>0,D_s\neq 0,E_s\neq 0,F_s\in\bm{R},\beta_s\geq0$ are **exogeneous** parameters which should be manually input/set by users/economists.
Meanwhile, users need to explicitly define the structure of the cross-sectional utility function $u(c,l)$ according to our assumptions.

Based on Eq (1), users may use standard DP algorithms to solve this problem.
However, solving this DP problem for many times (esp. in a large model system) may bring un-acceptable time cost. Therefore, I introduce a half-analytical approximated solution instead.
This half-analytical algorithm uses Lagrange functions without the inequalities of endowment constraints ($c_s,l_s,k_s$ etc.). It solves such a partial-constrained (only equality constraints!) problem, then uses a simple root-searching algorithm to find the consumption & labor & capital paths which meet those inequality endowment constraints). Of course, quite different from DP which does not require the structure of $u(\bullet)$, the proposed half-analytical algorithm uses the **analytical** FOCs of $u(\bullet)$ to accelerate computations. Therefore, the proposed algorithm requires the explicit definition of $u(\bullet)$, which leads to so many strong assumptions above. In this document, I will state one of the most simplest case: <font color=red>consumption-leisure separable $u(\bullet)$</font>.


-------------------------

## A Recursive Series

Before discussing the proposed half-analytical algorithm, let's look at the recurrence formula of a series:
$$
x_{t+1} = a_{t} x_{t} + b_{t}, t\geq1
\tag{2}$$
where $\{x_{t}| t\geq1\}$ is the real-number series, $a_{t}>0$ and $b_t\in\bm{R}$ are exogeneous parameters, and $x_{1}$ is a known constant. Readers may feel familiar with this series because it is an abstract form of our inter-temporal budget constraint. However, this series cannot be simply summarized because $a_{t}$ is variant with $t$.
Now, our task is clear: how to use $k_{1}$, the known constant, to denote any $k_{s}$ for $s>1$?

Let's use mathematical induction:
> ### Proof 1: $x_{s}(x_{1}), s>1$
> 1. Substitute $x_{2} = a_1 x_1 +b_1$ to $x{3} = a_2 x_2 + b_2$, then get:
> $x_3 = a_2(a_1 x_1 + b_1) + b_2 = a_2 a_1 x_1 + a_2 b_1 + b_2$;
> 2. Substitute $x_3$ to $x_4$, then get:
> $x_4 = x_1 \prod^4_{i=3} a_i + ( a_4 a_3 a_2 b_1 + a_4 a_3 b_2 + a_4 b_3 + b_4 )$;
> 3. Define: $\prod^m_{i=n} a_i \equiv 1$ for $\forall n>m$;
> 4. Therefore, guess:
> $x_{s+1} = x_1 \prod^s_{i=1} a_i + \sum^s_{j=1}( b_j \prod^s_{i=j+1} a_i ), s\geq 1$;
> 5. If our guess is true, we have:
> $x_{s+2} = x_1 \prod^{s+1}_{i=1} a_i + \sum^{s+1}_{j=1}( b_j \prod^{s+1}_{i=j+1} a_i ), s\geq 1$;
> 6. Substitute $x_{s+1}$ to $x_{s+2} = a_{s+1}x_{s+1} + b_{s+1}$, then get:
> $x_{s+2} = x_1 \prod^{s+1}_{i=1} a_i + \sum^{s+1}_{j=1}( b_j \prod^{s+1}_{i=j+1} a_i ), s\geq 1$;
> 7. Therefore, our guess is true.

So far, we have proved:
$$
x_{s+1} = x_1 \prod^s_{i=1} a_i + \sum^s_{j=1}( b_j \prod^s_{i=j+1} a_i ), s\geq 1
\tag{3}$$

Now, let's go back to our inter-temporal budget constraint:
$$
A_s k_{s+1} = B_s k_{s} + D_s l_s - E_s c_s + F_s, 1\leq s \leq S
\tag{4}$$
Because we have assumed $A_s>0,B_s>0$, this recursive formula of budget constraint can be written as:
$$
k_{s+1} = \frac{B_s}{A_s} k_{s} + ( \frac{D_s}{A_s} l_s - \frac{E_s}{A_s} c_s + \frac{F_s}{A_s}  ) , 1\leq s \leq S
\tag{5}$$
Eq (5) looks familiar? Right! Denote $x_{s} = k_s$, $a_i = \frac{B_i}{A_i}$ and $b_j = \frac{D_j}{A_j} l_j - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}$, then substitute them to Eq (3), we have:
$$
k_{s+1} = k_1 \prod^s_{i=1} \frac{B_i}{A_i} + \sum^s_{j=1}[ (\frac{D_j}{A_j} l_j - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}) \prod^s_{i=j+1} \frac{B_i}{A_i} ], s\geq 1
\tag{6}$$
or equivalently:
$$
k_{s+1} = k_1 \prod^s_{i=1} \frac{B_i}{A_i} + \sum^s_{j=1} (\frac{D_j}{A_j} l_j \prod^s_{i=j+1}\frac{B_i}{A_i}) - \sum^s_{j=1}(\frac{E_j}{A_j} c_j\prod^s_{i=j+1}\frac{B_i}{A_i}) + \sum^s_{j=1}(\frac{F_j}{A_j} \prod^s_{i=j+1} \frac{B_i}{A_i}) , s\geq 1
\tag{7}$$

Now, let $s=S$, then $k_{S+1}$ becomes bequests, the capital when agents die.
According to our assumptions, $k_{S+1}=0$, thus, define:
$$
G(c_s,l_s|s=1,\dots,S) = k_1 \prod^S_{i=1} \frac{B_i}{A_i} + \sum^S_{j=1}[ (\frac{D_j}{A_j} l_j - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}) \prod^S_{i=j+1} \frac{B_i}{A_i} ], s\geq 1
\tag{8}$$
Therefore, all inter-temporal budget constraints have been compressed to a single equation:
$$
G(c_s,l_s|s=1,\dots,S) = 0
\tag{9.A}$$

For the convenience of the following inductions, we write the partial differentiations of $c_s$ and $l_s$:
$$
\begin{cases}
\frac{\partial G}{\partial c_s} = - \frac{E_s}{A_s} \prod^S_{i=s+1}\frac{B_i}{A_i}  \\
\frac{\partial G}{\partial l_s} = \frac{D_s}{A_s} \prod^S_{i=s+1}\frac{B_i}{A_i}
\end{cases}
\tag{9.B}$$



## Mathematics: Problem Statements (Lagrange)

The proposed half-analytical algorithm requires the following partial-constrained optimization problem denoted as an standard maximization problem:
$$
\max_{c_s,s=1,\dots,S; l_s,s=1,\dots,S_r} U = \sum^S_{s=1} \beta_s u(c_s,l_s) \\
\text{s.t. }G(c_s,l_s|s=1,\dots,S) = 0
\tag{10}$$
In Eq (10), we temporarily neglect all endowment constraints because they are inequalities, and use standard Lagrange multiplier to solve Eq (10). The Lagrange function is:
$$
\max_{c_s,s=1,\dots,S; l_s,s=1,\dots,S_r} L = U(c_s,l_s|s=1,\dots,S) - \lambda G(c_s,l_s|s=1,\dots,S)
\tag{11}$$
Now, we are going to solve this problem with FOCs & Euler equation.

## FOCs and Euler Equation
To solve Eq (11), we need the first-order conditions (FOCs) of Eq (11).
We have assumed that the cross-sectional utility function $u(c,l)$ is explicitly defined and it is a consumption-labor separable $u(c,l) = u_1(c) + u_2(l)$.
Therefore, we write the FOCs of Eq(11):
$$
\begin{cases}
\frac{\partial U}{\partial c_s} = \beta_s \frac{\partial u}{\partial c_s} - \lambda \frac{\partial G}{\partial c_s} = 0, s = 1,\dots,S \\
\frac{\partial U}{\partial l_s} = \beta_s \frac{\partial u}{\partial l_s} - \lambda \frac{\partial G}{\partial l_s} = 0, s = 1,\dots,S_r \\
\frac{\partial U}{\partial \lambda} = G = 0
\end{cases}
\tag{12}$$

Because $\lambda>0$, combining $\frac{\partial U}{\partial c_s}$ and $\frac{\partial U}{\partial c_{s+1}}$, we get our Euler equation:
$$
\frac{ \partial u / \partial c_s }{ \partial u / \partial c_{s+1} } = \frac{\beta_{s+1}}{\beta_{s}} \frac{ \partial G / \partial c_s }{ \partial G / \partial c_{s+1} } , s = 1,\dots,S-1
\tag{13}$$
The Euler equation, when $\partial u/\partial c_s$ is explicitly defined, can be equivalently denoted as a recursive formula of $c_s$:
$$
c_s = \varepsilon(s|c_1)
\tag{14}$$
which we will use to compress the optimization about many $c_s$ to a new one only about $c_1$. 
Meanwhile, combining $\frac{\partial U}{\partial l_s}$ and $\frac{\partial U}{\partial c_{s}}$, we can get the optimal conversion formula from $l_s$ to $c_s$ without endowment constraints:
$$
\frac{ \partial u / \partial c_s }{ \partial u / \partial l_{s} } = \frac{ \partial G / \partial c_s }{ \partial G / \partial l_{s} } , s = 1,\dots,S_r
\tag{15}$$
which is equivalent to the following conversion function:
$$
l_s = \tilde{\gamma}(c_s) = \tilde{\gamma}(\varepsilon(s|c_1)) = \gamma(s|c_1)
\tag{16}$$

So far, we have used the information of the first two conditions of Eq(12).
Now, we substitute Eq(14) and Eq(16) to $G = 0$ to solve the optimal $c^*_1$ where no endowment constraints are considered:
$$
G(c^*_s,l^*_s|s=1,\dots,S) = G(c^*_1) = 0
\tag{17}$$

## Adjustment on $l_s$

Eq (17) has answered the optimal paths of $c^*_s$ and $l^*_s$ under the conditions without endowment constraints.
However, endowment constraints, i.e. $c_s\geq 0$ and $0\leq l_s \leq \bar{l}_s$, are essential which $c^*_s$ and $l^*_s$ cannot always meet.
Therefore, we need to adjust $c^*_s$ and $l^*_s$ to make them meet these endowment constraints.
> ### Algorithm: adjust $l^*_s$ and $c^*_s$
> 1.Assumptions:
> > 1. The dynamics of consumptions (Euler equation) are retained, no matter what the value of $c^*_1$ and/or what the values of $l^*_s$;
> > 2. However, the conversion formula $l^*_s = \tilde{\gamma}(c^*_s)$ is now not retained because we adjusted $l^*_s$;
> > 3. Budget constraint $G=0$ must be satisfied.
> 2. Algorithm:
> > 1. Let $\tilde{l}^*_s = [[l^*_s,\bar{l}_s]^-,0]^+$ be the bounded/adjusted labor supplies, where $[a,b]^+$ denotes the larger one of $a,b$, and $[a,b]^-$ denotes the smaller one of $a,b$;
> > 2. Solve the equation $G(\tilde{c}_s|\tilde{l}_s,s=1,...,S) = G(\tilde{c}_1|\varepsilon(\cdot),\tilde{l}_s,s=1,...,S) = 0$ with numerical root-searching algorithms (e.g. bisection search).

-------------------------
## Our problem

Specific to our household problem in this paper, we use a logarithm cross-sectional utility function:
$$
u(c,l|\bar{l}>0,q\in(0,1)) = \frac{1}{1-\gamma^{-1}} [ [(1-q)c + \epsilon]^{1-\gamma^{-1}} + \alpha [\bar{l} - l + \epsilon ]^{1-\gamma^{-1}} ]
\tag{18}$$
where $\epsilon$ is an infinitesimal which is the tolerance of computer's float point arithmetics. It is used to avoid the domain errors raised by exact zero.
Therefore, we have:
$$
\begin{cases}
\frac{\partial u}{\partial c_s} = (1-q_s)^{1-\gamma^{-1}} c_s^{-\gamma^{-1}}, 1\leq s\leq S \\
\frac{\partial u}{\partial c_s} = -\alpha (\bar{l}_s - l_s) ^ {-\gamma^{-1}}, 1\leq s\leq S_r
\end{cases}
\tag{19}$$
where we neglect $\epsilon$ in analytical solutions but add it when programming.

Then, we re-write our Euler equation in Eq (13):
$$
\begin{cases}
[\frac{1-q_s}{1-q_{s+1}}]^{1-\gamma^{-1}} [\frac{c_{s+1}}{c_{s}}]^{\gamma^{-1}} = \frac{\beta_{s+1}}{\beta_{s}} \frac{E_{s}}{E_{s+1}} \frac{A_{s+1}}{A_{s}} \frac{\prod^S_{s+1} \frac{B_i}{A_i}}{\prod^S_{s+2} \frac{B_i}{A_i}}, s= 1,\dots,S-1 \\
\frac{(1-q_s)^{1-\gamma^{-1}}}{-\alpha} [\frac{\bar{l}_s-l_s}{c_s} ]^{\gamma^{-1}} = - \frac{E_s}{D_s}, s= 1,\dots,S_r
\end{cases}
$$
Naturally, we ask for: $\gamma\neq 0$, $q\in(0,1)$, $\alpha\neq 0$, $\beta\neq 0$, $D,E \neq 0$, $A,B > 0$.
After simplification, we have Eq (20):
<!-- $$
\begin{cases}
[\frac{c_{s+1}}{c_{s}}]^{\gamma^{-1}} = [\frac{1-q_{s+1}}{1-q_{s}}]^{\frac{\gamma-1}{\gamma}} \frac{\beta_{s+1}}{\beta_{s}} \frac{E_{s}}{E_{s+1}}  \frac{B_{s+1}}{A_{s}}, s= 1,\dots,S-1 \\
 [\frac{\bar{l}_s-l_s}{c_s} ]^{\gamma^{-1}} = \alpha (1-q_s)^{\frac{1-\gamma}{\gamma}} \frac{E_s}{D_s}, s= 1,\dots,S_r
\end{cases}
\tag{20}$$  (commented but not deleted because may be useful when reviewing) -->
$$
\begin{cases}
\frac{c_{s+1}}{c_{s}} =  [ \frac{\beta_{s+1}}{\beta_{s}} \frac{E_{s}}{E_{s+1}}  \frac{B_{s+1}}{A_{s}} ]^{\gamma}  [\frac{1-q_{s}}{1-q_{s+1}}]^{1-\gamma}  , s= 1,\dots,S-1 \\
\frac{\bar{l}_s-l_s}{c_s} = [\alpha \frac{E_s}{D_s}]^{\gamma}  (1-q_s)^{1-\gamma}   , s= 1,\dots,S_r
\end{cases}
\tag{20}$$
Because $\gamma>0$ and it is usually less than 1, we specially requires $E_s/D_s > 0$.

Then, we define some new abbreviations:
$$
\begin{cases}
M_{s,s+1} = \frac{\beta_{s+1}}{\beta_{s}} \frac{E_{s}}{E_{s+1}}  \frac{B_{s+1}}{A_{s}}, s= 1,\dots,S-1 \\
N_{s,s+1} = \frac{1-q_{s}}{1-q_{s+1}}, s=1,\dots,S-1 \\
P_{s} = \alpha \frac{E_s}{D_s}, s=1,\dots,S_r \\
Q_{s} = 1-q_s, s=1,\dots,S_r
\end{cases}
\tag{21}$$
where according to our assumptions, we have: $M_{s,s+1},N_{s,s+1},P_{s},Q_{s} > 0$.
Therefore, we can rewrite our Euler equation and the conversion equation between consumption and labor in Cobb-Douglas form:
$$
\begin{cases}
\frac{c_{s+1}}{c_{s}} =  M_{s,s+1}^{\gamma}  N_{s,s+1}^{1-\gamma}  , s= 1,\dots,S-1 \\
\frac{\bar{l}_s-l_s}{c_s} = P_{s}^{\gamma}  Q_{s}^{1-\gamma}   , s= 1,\dots,S_r
\end{cases}
\tag{22}$$

In Eq (14) and Eq (16), we defined $c_s = \hat{\varepsilon}(s|c_1)$ and $l_s = \hat{\gamma}(s|c_1)$ (well, to avoid misleading marks, I replaced $\varepsilon(\cdot)$ with $\hat{\varepsilon}(\cdot)$, and $\gamma(\cdot)$ with $\hat{\gamma}(\cdot)$). The two formulae are the products of Eq (22):
$$
\begin{cases}
c_{s} = \hat{\varepsilon}(s,c_1|s=1,\dots,S) = c_1 (\prod^{s-1}_{i=1} M_{i,i+1})^{\gamma} (\prod^{s-1}_{i=1} N_{i,i+1})^{1-\gamma}  \\
l_{s} = \hat{\gamma}(s,c_1|s=1,\dots,S_r) = \bar{l}_s - c_s (\prod^{s}_{i=1} P_{i})^{\gamma} (\prod^{s}_{i=1} Q_{i})^{1-\gamma} = \bar{l}_s - c_1 (\prod^{s-1}_{i=1} M_{i,i+1})^{\gamma} (\prod^{s-1}_{i=1} N_{i,i+1})^{1-\gamma} (\prod^{s}_{i=1} P_{i})^{\gamma} (\prod^{s}_{i=1} Q_{i})^{1-\gamma}  \\
\end{cases}
\tag{23}$$
Of course, here we still have the relationship $\prod^m_n x \equiv 1$ for $\forall n>m$.

So far, we have got the all conditions to solve $c_1$. Then, we substitute Eq (23) into our linear budget constraint $G = 0$ in Eq (9.A) to solve $c_1$:
> ### Proof
> 1. To solve: 
> $$
> G(c_s,l_s|s=1,\dots,S) = k_1 \prod^S_{i=1} \frac{B_i}{A_i} + \sum^S_{j=1}[ (\frac{D_j}{A_j} l_j - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}) \prod^S_{i=j+1} \frac{B_i}{A_i} ]
> \tag{24}$$
> substitute $l_j = \hat{\gamma}(j,c_1)$ and $c_j = \hat{\gamma}(j,c_1)$ into $G(c_s,l_s)$.
> 2. Then, get $G(c_1)$, where we delete the terms of $l_s,s>S_r$:
> > 1. $G(c_1) = k_1 \prod^S_{i=1} \frac{B_i}{A_i} + \sum^{S_r}_{j=1} \{ \frac{D_j}{A_j} [ \bar{l}_j - c_1 (\prod^{j-1}_{i=1} M_{i,i+1})^{\gamma} (\prod^{j-1}_{i=1} N_{i,i+1})^{1-\gamma} (\prod^{j}_{i=1} P_{i})^{\gamma} (\prod^{j}_{i=1} Q_{i})^{1-\gamma} ] \prod^S_{i=j+1} \frac{B_i}{A_i} \} + \sum^S_{j=1}\{ [ - \frac{E_j}{A_j} [  c_1 (\prod^{j-1}_{i=1} M_{i,i+1})^{\gamma} (\prod^{j-1}_{i=1} N_{i,i+1})^{1-\gamma}  ] + \frac{F_j}{A_j} ] \prod^S_{i=j+1} \frac{B_i}{A_i} \}$
> > 2. Define some new abbreviations: 
> > $\begin{cases}
H = k_1 \prod^S_{i=1} \frac{B_i}{A_i}  \\
I_j = \frac{D_j}{A_j} \prod^S_{i=j+1} \frac{B_i}{A_i},j=1,\dots,S_r  \\
J_j = - \frac{E_j}{A_j} \prod^S_{i=j+1} \frac{B_i}{A_i},j=1,\dots,S  \\
K_j = \frac{F_j}{A_j}  \prod^S_{i=j+1} \frac{B_i}{A_i},j=1,\dots,S  \\
X_j = (\prod^{j-1}_{i=1} M_{i,i+1})^{\gamma} (\prod^{j-1}_{i=1} N_{i,i+1})^{1-\gamma},j=1,\dots,S  \\
Y_j = (\prod^{j}_{i=1} P_{i})^{\gamma} (\prod^{j}_{i=1} Q_{i})^{1-\gamma},j=1,\dots,S_r \\
\end{cases}$
> > 3. Re-write $G(c_1)$ as:
> > $$
> > G(c_1) = H + \sum^{S_r}_{j=1} I_j \bar{l}_j - c_1 \sum^{S_r}_{j=1} I_j X_j Y_j + c_1 \sum^{S}_{j=1} J_j X_j + \sum^{S}_{j=1} J_j K_j
> > \tag{25}$$
> 3. Finally, get $c^*_1$:
> $c^*_1 = \frac{    H + \sum^{S_r}_{j=1} I_j \bar{l}_j + \sum^{S}_{j=1} J_j K_j    }{    \sum^{S_r}_{j=1} I_j X_j Y_j - \sum^{S}_{j=1} J_j X_j    }$
> 4. Then, use $c^*_s = \hat{\varepsilon}(s,c_1)$ and $l^*_s = \hat{\gamma}(s,c_1)$ to get $c_s,s=1,\dots,S$ and $l_s,s=1,\dots,S_r$

Now, we add the endowment constraints $0 \leq l_s \leq \bar{l}_s$ to adjust $l^*_s$.
As stated before, we define $\tilde{l}^*_s = [[l^*_s,\bar{l}_s]^-,0]^+$.
Then, substitute $\tilde{l}^*_s$ into Eq (24) as constants, we get:
$$
G(c_s,l_s|s=1,\dots,S) = k_1 \prod^S_{i=1} \frac{B_i}{A_i} + 
\sum^{S_r}_{j=1}\frac{D_j}{A_j} \tilde{l}^*_j \prod^S_{i=j+1} \frac{B_i}{A_i} +
\sum^S_{j=1}[ ( - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}) \prod^S_{i=j+1} \frac{B_i}{A_i} ]
\tag{26}$$
Or equivalently:
$$
G(c_s,l_s|s=1,\dots,S) = H + 
\sum^{S_r}_{j=1} I_j \tilde{l}^*_j +
\sum^S_{j=1} J_j c_j + 
\sum^S_{j=1} K_j
\tag{27}$$
Because we have assumed that our Euler equation is still kept, we substitute Eq (23) into Eq (27):
$$
G(c_s,l_s|s=1,\dots,S) = H + 
\sum^{S_r}_{j=1} I_j \tilde{l}^*_j +
c_1 \sum^S_{j=1} J_j X_j + 
\sum^S_{j=1} K_j
\tag{28}$$
Then, we solve the adjusted optimal first consumption $\tilde{c}^*_1$:
$$
\tilde{c}^*_1 = \frac{  H + \sum^{S_r}_{j=1} I_j \tilde{l}^*_j + \sum^S_{j=1} K_j }{  - \sum^S_{j=1} J_j X_j  }
\tag{29}$$
Finally, use Eq (23) to get $\tilde{c}^*_s, s=1,\dots,S$.


-----------------
## Summary of Our Problem

Up to now, we have obtained the half-analytical solutions of our problem.
In this section, we summarize this problem.

### a. Cross-sectional Utility Function
$$
u(c,l|\bar{l}>0,q\in(0,1)) = \frac{1}{1-\gamma^{-1}} [ [(1-q)c + \epsilon]^{1-\gamma^{-1}} + \alpha [\bar{l} - l + \epsilon ]^{1-\gamma^{-1}} ]
$$
### b. Problem Statement
$$
\max_{c_s,s=1,\dots,S; l_s,s=1,\dots,S_r} U = \sum^S_{s=1} \beta_s u(c_s,l_s) \\
\text{s.t. }G(c_s,l_s|s=1,\dots,S) = 0
$$
where
$$
\begin{cases}
G(c_s,l_s|s=1,\dots,S) = k_1 \prod^S_{i=1} \frac{B_i}{A_i} + \sum^S_{j=1}[ (\frac{D_j}{A_j} l_j - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}) \prod^S_{i=j+1} \frac{B_i}{A_i} ] \\
\prod^m_n x \triangleq 1, \forall n > m    
\end{cases}
$$

### c. Domains of Parameters

| Type | Variable | Domain |
|:-----|:---------|:------------------------|
|General Parameters| $S,S_r \in \bm{Z}^+$  | $S > S_r \geq 1$ |
|Data| $k_s,s=1,\dots,S+1$  | $k_1 \geq 0, k_{S+1} = 0$ |
|Data| $c_s,s=1,\dots,S$  | $c_s \geq 0$ |
|Data| $l_s,s=1,\dots,S_r$  | $l_s \in [0,\bar{l}_s]$ |
|General Parameters| $A_s,B_s;s=1,\dots,S$ | $A_s,B_s>0$  |
|General Parameters| $D_s,s=1,\dots,S_r$   | $D_s > 0$  |
|General Parameters| $E_s,s=1,\dots,S$     | $E_s > 0$  |
|General Parameters| $F_s,s=1,\dots,S$     | $F_s\in \bm{R}$   |
|General Parameters| $\bar{l}_s,s=1,\dots,S_r$  | $\bar{l}_s > 0$   |
|General Parameters| $\beta_s,s=1,\dots,S$   | $\beta_s \neq 0$  |
|Custom Parameters| $q_s,s=1,\dots,S$       | $q_s \in (0,1)$   |
|Custom Parameters| $\alpha$                | $\alpha > 0$      |
|Custom Parameters| $\gamma$                | $\gamma \neq 0$   |




### d. Abbreviations

| Level | Abbreviation | Domain |
|:------|:-------------|:-------|
|Lev 1  | $M_{s,s+1} = \frac{\beta_{s+1}}{\beta_{s}} \frac{E_{s}}{E_{s+1}}  \frac{B_{s+1}}{A_{s}}, s= 1,\dots,S-1$ |  $M_{s,s+1} > 0$  |
|Lev 1  | $N_{s,s+1} = \frac{1-q_{s}}{1-q_{s+1}}, s=1,\dots,S-1$ | $N_{s,s+1} > 0$ |
|Lev 1  | $P_{s} = \alpha \frac{E_s}{D_s}, s=1,\dots,S_r$ | $P_s > 0$ |
|Lev 1  | $Q_{s} = 1-q_s, s=1,\dots,S_r$ | $Q_s \in (0,1)$ |
|Lev 1  | $H = k_1 \prod^S_{i=1} \frac{B_i}{A_i}$ | $H \geq 0$ |
|Lev 1  | $I_s = \frac{D_s}{A_s} \prod^{S}_{i=s+1} \frac{B_i}{A_i}$ | $I_s \neq 0$ |
|Lev 1  | $J_s = - \frac{E_s}{A_s} \prod^S_{i=s+1} \frac{B_i}{A_i}$ | $J_s \neq 0$ |
|Lev 1  | $K_s = \frac{F_s}{A_s}  \prod^S_{i=s+1} \frac{B_i}{A_i}$ | $K_s \in \bm{R}$ |
|Lev 2  | $X_s = (\prod^{s-1}_{i=1} M_{i,i+1})^{\gamma} (\prod^{s-1}_{i=1} N_{i,i+1})^{1-\gamma}, s = 1,\dots,S$ | $X_s > 0$ |
|Lev 2  | $Y_j = (\prod^{j}_{i=1} P_{i})^{\gamma} (\prod^{j}_{i=1} Q_{i})^{1-\gamma},s=1,\dots,S_r$  | $Y_j>0$ |


### e. Useful Functions
$$
\begin{cases}
c_{s+1} = c_s M_{s,s+1}^\gamma N_{s,s+1}^{1-\gamma}, s=1,\dots,S-1  \\
l_{s} = \bar{l}_s - c_s P_{s}^\gamma Q_{s}^{1-\gamma}, s=1,\dots,S_r  \\
c_s = \hat{\varepsilon}(s,c_1|s=1,\dots,S) = c_1 X_s  \\
l_s = \hat{\gamma}(s,c_1|\bar{l}_s,s=1,\dots,S_r) = \bar{l}_s - c_1 X_s Y_s  \\
k_{s} = \begin{cases}
    k_1 &,s=1 \\
    k_1 \prod^{s-1}_{i=i} \frac{B_i}{A_i} + \sum^{s-1}_{j=1} [ (\frac{D_j}{A_j} l_j - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}) \prod^{s-1}_{i=j+1} \frac{B_i}{A_i} ]  &,s=2,\dots,S+1
    \end{cases} \\
G(\cdot) = k_{S+1} = 0 
\end{cases}
$$


### f. Solutions

| Without Time Endowment Constraints (Un-adjusted) |
|:------------------|
| $c^*_1 = \frac{    H + \sum^{S_r}_{j=1} I_j \bar{l}_j + \sum^{S}_{j=1} J_j K_j    }{    \sum^{S_r}_{j=1} I_j X_j Y_j - \sum^{S}_{j=1} J_j X_j    }$ |
| Get un-adjusted paths |
| $c^*_s = \hat{\varepsilon}(s,c^*_1), l^*_s = \hat{\gamma}(s,c^*_1)$
| Labor Adjustment |
| $\tilde{l}^*_s = [[l^*_s,\bar{l}_s]^-,0]^+$ |
| With Time Endowment constraints (Adjusted) |
| $\tilde{c}^*_1 = \frac{  H + \sum^{S_r}_{j=1} I_j \tilde{l}^*_j + \sum^S_{j=1} K_j }{ - \sum^S_{j=1} J_j X_j  }$  |


### g. Level 0 Abbreviations

|Abbreviation | Components | Component Domain | Definition |
|:------------|:-----------|:-----------------|:-----------|
| $A_s = \mathbb{S}_s,s=1,\dots,S$ | $\mathbb{S}_s$ | $\mathbb{S}_s \in (0,1]$, and $\mathbb{S}_S = 1$ | $\mathbb{S}_s$ is the survival rate in year $s$ |
| $B_s = 1+r_s,s=1,\dots,S$ | $r_s$ | $r_s > -1$ | $r_s$ is the net investment returns (interest rate) in year $s$ |
| $D_s = (1-\sigma_s -\frac{ z_s(\theta_s+\eta_s) + (1-\mathbb{A}_s)\zeta_s  }{1+z_s\eta_s+\zeta_s}   )w_s,s=1,\dots,S_r$ | $\sigma_s$ | | taxation on nominal wage |
|  | $z_s,\theta_s,\eta_s,\zeta_s,\phi_s$ | $[0,1)$ | contributions rates, collection rate |
|  | $w_s$ | $D_s > 0$ | nominal wage level |
|  | $\mathbb{A}_s$ | $[0,1]$ | policy parameter of UE-BMI, the transfer rate from firm contribution amount to individual accounts |
| $E_s = 1 + \mu_s - q_s\frac{1-\text{cp}^B_s}{1+p_s},s=1,\dots,S$ | $\mu_s$ | $\mu_s > 0$ | taxation on consumption |
|  | $q_s$ | $q_s\in(0,1)$ | | the rate of health expenditure on total consumption |
|  | $p_s,\text{cp}^B_s$   | | policy functions of health demands |
| $F_s = \begin{cases} 0 &,s=1,\dots,S_r \\ \Lambda_s+\mathbb{P}_s &,s=S_r+1,\dots,S  \end{cases}$ | $\Lambda_s$ | $\Lambda_s \geq 0$ | the amount of pension benefits |
|  | $\mathbb{P}_s$    | $\mathbb{P}_s \geq 0$ | the amount of the transfer payment from the firm contribution amount to UE-BMI this year |
| $\bar{l}_s = 1$ | | | time endowments |





## Summary of Our Problem (Only Retired Years)

In practice, we not only need to solve the problems with both working and retired years, but also need to solve the problems with only retired years.
This happens when we compute the transition path in years $t=1,\dots,S$.
In these years, those who are alive in year 0 (initial steady state), according to shocks in year 1, will re-solve the optimal consumption-leisure-capital paths in their left years.
For those who have retired in year 0, naturally, they optimize their utilities with a budget constraint without labor supply, i.e. they just decide how to consume their savings but won't worry about whether to work.
Therefore, the solutions of these only-retired problems changed, but still similar to our original problems.
We restate the only-retired problem in this section.

### a. Cross-sectional Utility Function
$$
u(c,l\equiv 0|\bar{l}>0,q\in(0,1)) = \frac{1}{1-\gamma^{-1}} [ [(1-q)c + \epsilon]^0{1-\gamma^{-1}} + \alpha [\bar{l} - l + \epsilon ]^{1-\gamma^{-1}} ]
$$
### b. Problem Statement
$$
\max_{c_s,s=1,\dots,S; l_s,s=1,\dots,S_r} U = \sum^S_{s=1} \beta_s u(c_s,0) \\
\text{s.t. }G(c_s,0|s=1,\dots,S) = 0
$$
where $S$ now is defined as the number of maximum left years that the agents can live, and:
$$
\begin{cases}
G(c_s,0|s=1,\dots,S) = k_1 \prod^S_{i=1} \frac{B_i}{A_i} + \sum^S_{j=1}[ ( - \frac{E_j}{A_j} c_j + \frac{F_j}{A_j}) \prod^S_{i=j+1} \frac{B_i}{A_i} ] \\
\prod^m_n x \triangleq 1, \forall n > m
\end{cases}
$$
where $k_1$ now is defined as agents' capital held in year 0 (steady state), or equivalently, at the beginning of the year when agents make life-cycle decisions.

In fact, we can see this problem is equivalent to a standard problem with given zero labor supplies. Therefore, the solution of this problem is just a variant of Eq(29):
$$
\tilde{c}^*_1 = \frac{  H +  \sum^S_{j=1} K_j }{  - \sum^S_{j=1} J_j X_j  }
\tag{29}$$







## Functions in Computing

The type of "Custom" means this function should be made according to scenarios.
The type of "General" means this function is a general one as long as the cross-sectional utility function $u(c,l)$ is the same one as we use in our problem.

|Type|Function Name|Inheritance & Reference|Notes|
|:---|:------------|:----------------------|:----|
|Custom| lev0Abbr(::Dict) | No inheritance | Uses original data to create a Dict of those Level 0 abbreviations; also performs data validations|
|General| lev1Abbr(::Dict) | The results of lev0Abbr() | Creates a Dict of those Level 1 abbreviations; also performs data validations|
|General| lev2Abbr(::Dict) | The results of lev1Abbr() | Creates a Dict of those Level 2 abbreviations; also performs data validations|
|General| getks(::Int,::Real,::Vector,::Vector,::Dict) | The results of lev0Abbr() | Gets the capital $k_s,s=1,\dots,S+1$ in a specific year |
|General| G(::Vector,::Vector,::Dict) | The results of lev0Abbr()  | The budget constraint; used to exam if solutions are right |
|General| HHSolve() | all others | Solves the household life-cycle problem, considering both working & retired phases |
|General| lev0Abbr_Retired() | No inheritance | Create Level 0 abbreviations for the only-retired problems |
|General| lev1Abbr_Retired() | The results of lev0Abbr_Retired() | |
|General| lev2abbr_Retired() | The results of lev1Abbr_Retired() | |
|General| getks_Retired()   | The results of lev0Abbr_Retired()  | |
|General| G_Retired() | The results of lev0Abbr_Retired()  |  |
|General| HHSolve_Retired() | all others & some new functions | Solves the household life-cycle problem, only considering the retired phase; allows $S=1$ |













