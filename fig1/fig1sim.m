clear;
% 使用电脑当前的高精度时间戳作为随机数种子，确保每次运行轨迹不同
rng('shuffle'); 

% 物理参数定义
k = 0.026;          % 平均生长速率
k_prime = sqrt(0.0014);     % 噪声强度系数
deltat = 0.05;      % 模拟时间步长 (min)

% 初始化第一个细胞
a = 1 + 0.12 * randn; % 初始体积 V_b
l1 = [];            % 存储时间轨迹
l2 = [];            % 存储体积轨迹
t = 0;              % 初始时间

% 模拟 56 个世代的连续生长和分裂
for i = 1:28
    c = a; % 当前世代的出生体积 V_b
    
    % Adder模型：设定分裂阈值体积 V_d = V_b + \Delta
    b = 1 + sqrt(3) * 0.12 * randn + c; 
    
    % 几何布朗运动 (GBM) 随机生长过程
    while a < b
        l1 = [l1, t];
        l2 = [l2, a];
        
        % 使用高斯白噪声更新体积 (标准的积分步长缩放为 sqrt(deltat) * randn)
        a = exp(log(a) + k * deltat + k_prime * sqrt(deltat) * randn);
        
        t = t + deltat;
    end
    
    % 发生对半分裂，进入下一个细胞周期
    a = b / 2; 
    l1 = [l1, t];
    l2 = [l2, a];
    t = t + deltat;
end

%% 绘图 (每 20 帧采样一次，相当于每 1 分钟记录一个点)
figure('Color', 'w');
plot(l1(1:20:end), l2(1:20:end))
xlabel('Elapsed time (min)', 'Interpreter', 'tex')
ylabel('Cell Volume', 'Interpreter', 'tex')
title('Simulated Single Cell Growth and Division', 'Interpreter', 'tex');
grid on;
pbaspect([1 0.3 1])