%% 1. 参数定义与仿真初始化
clear; close all; clc;

num_cells = 18524;            % 细胞轨迹总数
dt_base   = 0.05;             % 基础仿真步长 (min)
k_prime   = sqrt(0.0014);     % 噪声强度
max_time  = 32;               % 最大统计时间 (min)

% 统一的时间 Bin 尺度 (2 min)
bin_width = 2.0; 
num_bins  = floor(max_time / bin_width); % 共 16 个 Bin

% 采样间隔 dt 与对应的下采样步长因子 (0.05 * [1, 10, 20, 40])
dt_list      = [0.05, 0.5, 1.0, 2.0];
step_factors = dt_list / dt_base; % [1, 10, 20, 40]
num_dt       = length(dt_list);

% 为每种 dt 预分配统一大小 (num_bins) 的"总和"与"计数"累加器
sum_rates   = zeros(num_dt, num_bins);
count_rates = zeros(num_dt, num_bins);

%% 2. 轨迹生成与统一尺度分桶统计
v = 1 + 0.12 * randn; % 初始体积

for num = 1:num_cells
    c = v;
    b = 1 + sqrt(3) * 0.12 * randn + c; % 分裂阈值
    k = 0.026 * (1 + 0.1 * randn);       % 基础生长速率

    % 模拟单个细胞生命周期
    l = zeros(1, 1000); % 预分配临时缓冲区
    idx = 0;
    while v < b
        idx = idx + 1;
        l(idx) = log(v);
        v = exp(l(idx) + k * dt_base + k_prime * sqrt(dt_base) * randn);
    end
    log_v = l(1:idx);
    v = b / 2; % 下一代初始体积

    % 对不同 dt 下采样，并映射映射到统一的 2 min Bin 中
    for d = 1:num_dt
        step = step_factors(d);
        log_v_sub = log_v(1:step:end);
        rates = diff(log_v_sub) / dt_list(d); % 对数生长速率
        
        n_points = length(rates);
        if n_points == 0, continue; end
        
        % 计算每个测量点在绝对时间轴上的"时间中点"
        t_mids = (0.5 : n_points - 0.5) * dt_list(d);
        
        % 计算该中点落在第几个 2 min 的 Bin 中 (1, 2, ..., num_bins)
        b_idxs = floor(t_mids / bin_width) + 1;
        
        % 筛选有效范围内的 Bin 索引
        valid_mask = (b_idxs >= 1) & (b_idxs <= num_bins);
        
        if any(valid_mask)
            b_valid = b_idxs(valid_mask);
            r_valid = rates(valid_mask);
            
            % 向量化累加至对应的 2 min Bin 累加器中
            sum_rates(d, :)   = sum_rates(d, :)   + accumarray(b_valid', r_valid', [num_bins, 1])';
            count_rates(d, :) = count_rates(d, :) + accumarray(b_valid', 1,        [num_bins, 1])';
        end
    end
end

%% 3. 计算平均生长速率与绘图
figure('Position', [200, 200, 750, 480]);

% 统一的时间中心点：(1, 3, 5, ..., 31 min)
time_centers = (0.5 : num_bins - 0.5) * bin_width;

hold on;
for d = 1:num_dt
    % 计算该 dt 在统一 Bin 下的系综平均
    mean_rate = sum_rates(d, :) ./ count_rates(d, :);
    
    % 绘制折线图
    plot(time_centers, mean_rate,'-o');
end

% 图形美化与格式设置
xlabel('Elapsed Time (min)', 'Interpreter', 'tex', 'FontSize', 12);
ylabel('Growth Rate', 'Interpreter', 'tex', 'FontSize', 12);
title(sprintf('Simulated Growth Rate vs. Elapsed Time', bin_width), ...
      'Interpreter', 'tex', 'FontSize', 13);
xlim([0, 32]);
ylim([0, 0.08]);
grid on;
legend({'$\Delta t=0.05$ min', '$\Delta t=0.5$ min', '$\Delta t=1$ min', '$\Delta t=2$ min'}, ...
       'Interpreter', 'latex', 'FontSize', 11, 'Location', 'southwest');