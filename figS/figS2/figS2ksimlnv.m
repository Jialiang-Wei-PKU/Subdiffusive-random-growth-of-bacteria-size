%% 1. 参数定义与仿真初始化
clear; close all; clc;

num_cells = 18524;            % 轨迹条数 (18,524 条)
deltat    = 0.05;             % 基础仿真步长 (min)
k_prime   = sqrt(0.0014);     % 噪声强度

% 4 种采样间隔 dt 与对应的下采样步长因子 (0.05 * [1, 10, 20, 40])
dt_list      = [0.05, 0.5, 1.0, 2.0];
step_factors = dt_list / deltat; % [1, 10, 20, 40]
num_dt       = length(dt_list);

% 体积分桶参数设置 (\ln(V / \bar{V}_b))
binnumber = 25;
dx        = 1 / binnumber;    % 箱宽 0.04
x_min     = -7 * dx;          % -0.28
num_bins  = 29;               % 共 29 个分桶 (对应 n = -7 到 21)

% 横轴 Bin 中心点坐标 (-0.26 : 0.04 : 0.86)
x_centers = (-6.5 : 21.5) * dx; 

% 预分配累加器：存储每个 Bin 的生长速率总和与数据点计数 [4 x 29]
sum_rates   = zeros(num_dt, num_bins);
count_rates = zeros(num_dt, num_bins);

%% 2. 轨迹生成与细胞体积在线分桶累加
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
        l(idx) = v;
        v = exp(log(v) + k * deltat + k_prime * sqrt(deltat) * randn);
    end
    v_seq = l(1:idx);
    v = b / 2; % 下一代初始体积

    % 针对不同 \Delta t 进行下采样与体积分桶统计
    for d = 1:num_dt
        step = step_factors(d);
        v_sub = v_seq(1:step:end);
        
        n_points = length(v_sub) - 1;
        if n_points < 1, continue; end

        % 1. 计算区间起点对数体积 \ln(V)
        log_v_start = log(v_sub(1:end-1));
        
        % 2. 计算对数生长速率 \Delta \ln(V) / \Delta t
        rates = diff(log(v_sub)) / dt_list(d); 
        
        % 3. 映射到离散体积 Bin 索引 (1 ~ num_bins)
        b_idxs = floor((log_v_start - x_min) / dx) + 1;
        
        % 4. 筛选有效 Bin 索引范围
        valid_mask = (b_idxs >= 1) & (b_idxs <= num_bins);
        
        if any(valid_mask)
            b_valid = b_idxs(valid_mask);
            r_valid = rates(valid_mask);
            
            % 5. 向量化在线累加至对应的体积 Bin
            sum_rates(d, :)   = sum_rates(d, :)   + accumarray(b_valid', r_valid', [num_bins, 1])';
            count_rates(d, :) = count_rates(d, :) + accumarray(b_valid', 1,        [num_bins, 1])';
        end
    end
end

%% 3. 计算平均生长速率与绘图
figure('Position', [200, 200, 750, 480]);

hold on;
for d = 1:num_dt
    % 计算系综平均
    mean_rate = sum_rates(d, :) ./ count_rates(d, :);
    
    % 过滤无数据的 Bin
    valid_idx = count_rates(d, :) > 0;
    
    plot(x_centers(valid_idx), mean_rate(valid_idx),'-o');
end

% 图形美化
xlabel('$\ln(V/ \bar{V}_b)$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Growth Rate', 'Interpreter', 'tex', 'FontSize', 12);
title('Simulated Growth Rate vs. Cell Volume', 'Interpreter', 'tex', 'FontSize', 13);
xlim([-0.28, 0.88]);
ylim([0, 0.08]);
grid on;
legend({'$\Delta t$=0.05 min', '$\Delta t$=0.5 min', '$\Delta t$=1 min', '$\Delta t$=2 min'}, ...
       'Interpreter', 'latex', 'FontSize', 11, 'Location', 'southwest');