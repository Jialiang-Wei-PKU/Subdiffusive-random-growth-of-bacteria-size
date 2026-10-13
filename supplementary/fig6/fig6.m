list=[];
deltat=0.05;
k=0.026;
k_prime=0.04;
for num=1:10000
    l=[];
    v=1;
    while v<2
        l=[l,v];
        v=exp(log(v)+k*deltat+k_prime*sqrt(deltat)*randn);
    end
    l=l(1:end);
    siz=size(l,2);
    list=[list,[1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1));diff(log(l))*20/(siz-1);1/(siz-1)+zeros(1,siz-1)]];
end
%% 
close all;
binnumber=50;
bin=zeros(1,binnumber);
timescale=list(1,:);
leng=list(2,:);
weight=list(3,:);
for n=0:binnumber-1
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    bin(n+1)=sum(len)/sum(wei);
end

plot(1/(2*binnumber):1/binnumber:1-1/(2*binnumber),bin,"ko")

xlabel('Relative Age','Interpreter','tex', 'Color', 'k')
ylabel('Growth Rate','Interpreter','tex', 'Color', 'k')
hold on
%%
a=k;
part_A = @(T, k_prime) log(2) ./ sqrt(2 * pi * k_prime^2 * T.^3);
part_B = @(T, a, k_prime) exp(-(log(2) - a * T).^2 ./ (2 * k_prime^2 * T));
part_C = @(T, tau, k_prime) (log(2)./T - k_prime^2/log(2)) .* ...
    erf(log(2) * sqrt((1-tau)./(2 * k_prime^2 * tau * T)));
part_D = @(T, tau, k_prime) sqrt((2 * tau * k_prime^2)./(pi * T * (1-tau))) .* ...
    exp(-(log(2))^2 * (1-tau) ./ (2 * k_prime^2 * T * tau));
integrand = @(T, tau, a, k_prime) part_A(T, k_prime) .* part_B(T, a, k_prime) .* (part_C(T, tau, k_prime) + part_D(T, tau, k_prime));
tau_values = 0:0.01:0.99;
x_prime_values = zeros(size(tau_values));
for i = 1:length(tau_values)
    current_tau = tau_values(i);
    fun_to_integrate = @(T) integrand(T, current_tau, a, k_prime);
    x_prime_values(i) = integral(fun_to_integrate, 0, inf);
end
plot(tau_values, x_prime_values, 'r', 'LineWidth', 1.5, 'MarkerSize', 5);
title('Simulated vs Analytic Solution','Interpreter','tex', 'Color', 'k')
hold on;
%% 
plot(tau_values, k+zeros(1,100), 'g-', 'LineWidth', 1.5, 'MarkerSize', 5);
hold on;
%% 
% === 1. 定义常量和参数 ===
a = 0.026;
k_prime = 0.04;
ln2 = log(2);

% 计算贝塞尔函数 K1 的参数 arg_bessel = a * ln2 / k'^2
arg_bessel = (a * ln2) / k_prime^2;

% --- 2. 计算常数因子 C ---
% C = (2a / pi) * 2^(a/k'^2) * K1(...)
bessel_K1 = besselk(1, arg_bessel);

% 2^(a/k'^2) factor
factor_exp = 2^(a / k_prime^2);

% 计算最终的常数 C
C = (2 * a / pi) * factor_exp * bessel_K1;

% --- 3. 定义 Tau 向量和函数 ---
% tau 范围从 0 到 0.99，步长 0.01
tau = 0:0.01:0.99;

% 计算函数值 f(tau) = C / sqrt(1 - tau)
% 使用点运算 (./) 进行向量除法
f_tau = C ./ sqrt(1 - tau);

plot(tau, f_tau, 'b-', 'LineWidth', 1.5, 'MarkerSize', 5);
legend('Simulation','Analytic Solution','Asymptotic Behavior Near 0','Asymptotic Behavior Near 1','Interpreter','tex','Location','best')