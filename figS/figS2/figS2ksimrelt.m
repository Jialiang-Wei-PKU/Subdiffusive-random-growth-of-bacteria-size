%% 1. 参数定义与仿真初始化（与上次实验参数完全一致）
clear; close all; clc;

num_cells = 18524;            % 轨迹条数 (18,524 条)
deltat    = 0.05;             % 基础仿真步长 (min)
binnumber = 25;             % 相对年龄分桶数
k_prime   = sqrt(0.0014);     % 噪声强度

% 4 种采样间隔 dt 与对应的下采样步长因子 (0.05 * [1, 10, 20, 40])
dt_list      = [0.05, 0.5, 1.0, 2.0];
step_factors = dt_list / deltat; % [1, 10, 20, 40]
num_dt       = length(dt_list);

% 预分配累加器：存储每个 Bin 的加权生长速率与权重之和 [4 x 25]
sum_weighted_rates = zeros(num_dt, binnumber);
sum_weights        = zeros(num_dt, binnumber);

%% 2. 轨迹生成与相对年龄在线分桶累加
v = 1 + 0.12 * randn; % 初始体积 (噪声系数 0.12)

for num = 1:num_cells
    c = v;
    b = 1 + sqrt(3) * 0.12 * randn + c; % 分裂阈值 (噪声系数 0.12)
    k = 0.026 * (1 + 0 * randn);       % 基础生长速率

    % 模拟单个细胞生命周期
    l = zeros(1, 1000); % 预分配临时缓冲区
    idx = 0;
    while v < b
        idx = idx + 1;
        l(idx) = log(v);
        v = exp(l(idx) + k * deltat + k_prime * sqrt(deltat) * randn);
    end
    log_v = l(1:idx);
    v = b / 2; % 下一代初始体积

    % 针对不同 \Delta t 进行下采样与相对年龄分桶统计
    for d = 1:num_dt
        step = step_factors(d);
        log_v_sub = log_v(1:step:end);
        n_steps = length(log_v_sub) - 1;
        if n_steps < 1, continue; end

        % 1. 计算对数生长速率 \Delta \ln(V) / \Delta t
        rates = diff(log_v_sub) / dt_list(d); 
        
        % 2. 每个 step 的权重 (1 / n_steps)
        w = 1 / n_steps; 
        
        % 3. 计算每个 step 在相对年龄 (Relative Age) 轴上的中点 (0 到 1 之间)
        tau = (0.5 : n_steps - 0.5) / n_steps; 
        
        % 4. 映射到 1 ~ binnumber 的离散 Bin 索引
        b_idxs = floor(tau * binnumber) + 1;
        b_idxs = min(binnumber, max(1, b_idxs)); % 安全截断范围
        
        % 5. 向量化在线累加至对应的相对年龄 Bin
        sum_weighted_rates(d, :) = sum_weighted_rates(d, :) + accumarray(b_idxs', (rates * w)', [binnumber, 1])';
        sum_weights(d, :)        = sum_weights(d, :)        + accumarray(b_idxs', w,          [binnumber, 1])';
    end
end

%% 3. 计算加权平均生长速率并绘图
% 相对年龄 Bin 中心点
x_rel = (1 / (2 * binnumber)) : (1 / binnumber) : (1 - 1 / (2 * binnumber));

% 计算加权平均：sum(len) / sum(wei)
bin_rates = sum_weighted_rates ./ sum_weights;

figure('Position', [200, 200, 750, 480]);

hold on;
for d = 1:num_dt
    plot(x_rel, bin_rates(d, :),'-o');
end

% 图形美化
xlabel('Relative Age', 'Interpreter', 'tex', 'FontSize', 12);
ylabel('Growth Rate', 'Interpreter', 'tex', 'FontSize', 12);
title('Simulated Growth Rate vs. Relative Age', 'Interpreter', 'tex', 'FontSize', 13);
ylim([0, 0.08]);
grid on;
legend({'$\Delta t$=0.05 min', '$\Delta t$=0.5 min', '$\Delta t$=1 min', '$\Delta t$=2 min'}, ...
       'Interpreter', 'latex', 'FontSize', 11, 'Location', 'best');