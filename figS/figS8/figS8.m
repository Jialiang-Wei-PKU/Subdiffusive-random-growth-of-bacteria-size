close all; 
clc;
rng('shuffle');

%% ========================================================
% 1. 实验数据处理 (Experimental Data Processing)
% ========================================================
fprintf('正在处理实验数据...\n');
% 读取数据
lengt = MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time  = MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width = MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;

max_tau_physical = 5; % 最大物理滞后时间 tau = 5.0

% 统计量初始化 (实验数据)
corr_sum_exp    = zeros(1, max_tau_physical + 1);
corr_sum_sq_exp = zeros(1, max_tau_physical + 1);
corr_count_exp  = zeros(1, max_tau_physical + 1);

for i = 1:size(lengt, 2)
    length_i = lengt{i};
    time_i   = time{i};
    width_i  = width{i};
    
    % 过滤掉太短或含有非法宽度的轨迹
    if size(length_i, 2) <= 3 || any(isnan(width_i) | width_i == 0) || any(isnan(time_i))
        continue
    end
    
    % 1. 计算体积公式
    volume_i = (length_i .* ((width_i/2).^2) - (2/3) * ((width_i/2).^3)) * pi;
    
    % 2. 计算瞬时生长率 \lambda(t) = \Delta \ln(V)
    g_i = diff(log(volume_i));
    
    % 3. 计算各个生长率采样点对应的相对年龄 (Relative Age)
    g_time = (time_i(1:end-1) + time_i(2:end)) / 2; 
    t_start = time_i(1);
    t_end   = time_i(end);
    
    if t_end <= t_start
        continue;
    end
    
    rel_age = (g_time - t_start) / (t_end - t_start);
    
    % 筛选出相对年龄在 0.2 ~ 0.8 之间的点
    valid_age_mask = (rel_age >= 0.2) & (rel_age <= 0.8);
    
    % 如果过滤后剩余的数据点太少，跳过此轨迹
    if sum(valid_age_mask) < 2
        continue;
    end
    
    % 取出满足相对年龄要求的生长率
    g_filtered = g_i(valid_age_mask);
    
    % 4. 减去该筛选范围内轨迹本身的平均生长率，得到涨落 \delta\lambda(t)
    dg_i = g_filtered - mean(g_filtered);
    
    % 5. 计算时间关联函数 (实验采样间隔为 1)
    len_g = length(dg_i);
    for tau = 0:min(max_tau_physical, len_g - 1)
        products = dg_i(1 : end-tau) .* dg_i(1+tau : end);
        corr_sum_exp(tau + 1)    = corr_sum_exp(tau + 1) + sum(products);
        corr_sum_sq_exp(tau + 1) = corr_sum_sq_exp(tau + 1) + sum(products.^2); 
        corr_count_exp(tau + 1)  = corr_count_exp(tau + 1) + length(products);
    end
end

% 计算实验的平均关联函数 C_exp(\tau) 和标准误 (SEM)
valid_idx_exp = corr_count_exp > 1;
C_tau_exp = zeros(1, max_tau_physical + 1);
C_err_exp = zeros(1, max_tau_physical + 1);
C_tau_exp(valid_idx_exp) = corr_sum_exp(valid_idx_exp) ./ corr_count_exp(valid_idx_exp);
var_exp = (corr_sum_sq_exp(valid_idx_exp) - (corr_sum_exp(valid_idx_exp).^2 ./ corr_count_exp(valid_idx_exp))) ./ (corr_count_exp(valid_idx_exp) - 1);
C_err_exp(valid_idx_exp) = sqrt(var_exp ./ corr_count_exp(valid_idx_exp));

%% ========================================================
% 2. 数值模拟 (滑动窗口：Delta t = 1.0 窗口，tau = 0.1 密集采样)
% ========================================================
deltat     = 0.05;
alpha_dist = 0.375; 
tau_min    = 0.001;
N          = round(1000 * (100 * tau_min)^(-alpha_dist));
dt         = 0.001;
exponent   = -1 / alpha_dist;

% 采样设置：
% 内层 50 步 (50 * 0.001 = 0.05)，降采样取间隔 2，则密集采样点时间间隔 dt_sample = 0.1
downsample_factor = 2; 
dt_sample = 50 * dt * downsample_factor; % 0.1

% 保持 Delta t = 1.0 的物理生长窗口，1.0 / 0.1 = 10 步采样间隔
step_win = round(1.0 / dt_sample); 

% tau 物理离散步长 (tau = 0, 0.1, 0.2, ..., 5.0，共 50 步)
max_lag_steps = round(max_tau_physical / dt_sample); 

% 构建长轨迹结构：388条包含47个cycle + 6条包含48个cycle (共394条轨迹，18524个cycle)
traj_lengths = [47 * ones(1, 388), 48 * ones(1, 6)];
total_trajectories = length(traj_lengths);
total_sim_cycles = sum(traj_lengths); % 18524

% 统计量初始化 (模拟数据)
corr_sum_sim    = zeros(1, max_lag_steps + 1);
corr_sum_sq_sim = zeros(1, max_lag_steps + 1);
corr_count_sim  = zeros(1, max_lag_steps + 1);

fprintf('开始密集采样模拟 (窗口 Delta t = 1.0, tau 步长 = %.1f)，共 %d 个细胞周期...\n', dt_sample, total_sim_cycles);
num_count = 0;

for traj_idx = 1:total_trajectories
    cycles_in_this_traj = traj_lengths(traj_idx);
    
    % 1. 每条长轨迹单独取样专属的 tau (X)
    U = rand(1, N);
    X = tau_min * (U.^exponent);
    
    % 2. 仅在长轨迹开头初始化噪声状态 s 并预热 10 分钟 (10000 步)
    s = zeros(1, N);
    for i = 1:10000
        dW = randn * sqrt(dt) / 140; 
        s = s .* (1 - dt ./ X) + dW;
    end
    
    % 3. 初始化当前轨迹第一代细胞的初始体积
    v = 1 + 0.12 * randn;
    
    for c_idx = 1:cycles_in_this_traj
        num_count = num_count + 1;
        
        % 每个 cell-cycle 重新单独 sample 一次 k
        k = 0.026 * (1 + 0.2 * randn);
        
        if mod(num_count, 2000) == 0 || num_count == total_sim_cycles
            fprintf('正在处理第 %d/%d 个细胞周期 (轨迹 %d/%d)...\n', ...
                num_count, total_sim_cycles, traj_idx, total_trajectories);
        end
        
        l = [];
        c = v;
        b = 1 + sqrt(3) * 0.12 * randn + c;
        r = sum(s) / (N * alpha_dist * (tau_min^alpha_dist));
        
        % 细胞生长阶段
        while v < b
            for i = 1:50
                dW = randn * sqrt(dt) / 140; 
                s = s .* (1 - dt ./ X) + dW;
            end
            w = sum(s) / (N * alpha_dist * (tau_min^alpha_dist));
            h = w - r;
            r = w;
            l = [l, v];
            v = exp(log(v) + k * deltat + h);
        end
        
        v = b / 2;
        
        % 1. 以 dt = 0.1 的物理时间间隔记录对数体积 ln(V)
        l_dense = l(1:downsample_factor:end); 
        log_v = log(l_dense);
        
        % 2. 数据点不足以覆盖一个完整的 Delta t = 1.0 窗口时跳过
        if length(log_v) <= step_win + 2
            continue;
        end
        
        % 3. 滑动窗口计算保持物理时间窗口 Delta t = 1.0 的生长率：
        %    lambda(t) = ln V(t + 1.0) - ln V(t)
        g_i = log_v(1 + step_win : end) - log_v(1 : end - step_win);
        dg_i = g_i - mean(g_i);
        
        % 4. 计算关联函数 (时间差以 0.1 为基础步长增加)
        len_g = length(dg_i);
        for tau_step = 0:min(max_lag_steps, len_g - 1)
            products = dg_i(1 : end - tau_step) .* dg_i(1 + tau_step : end);
            corr_sum_sim(tau_step + 1)    = corr_sum_sim(tau_step + 1) + sum(products);
            corr_sum_sq_sim(tau_step + 1) = corr_sum_sq_sim(tau_step + 1) + sum(products.^2); 
            corr_count_sim(tau_step + 1)  = corr_count_sim(tau_step + 1) + length(products);
        end
    end
end

% 计算模拟关联函数 C_sim(\tau)
valid_idx_sim = corr_count_sim > 1;
C_tau_sim = zeros(1, max_lag_steps + 1);
C_tau_sim(valid_idx_sim) = corr_sum_sim(valid_idx_sim) ./ corr_count_sim(valid_idx_sim);

% 模拟点对应的物理时间坐标 (0, 0.1, 0.2, ..., 5.0)
tau_sim_physical = (0:max_lag_steps) * dt_sample;

%% ========================================================
% 3. 理论曲线计算 (Theoretical Model)
% ========================================================
alpha_theory = 1 - 2 * alpha_dist; 
A_exp = C_tau_exp(1); 
lags_fine = linspace(0, max_tau_physical, 501); 

% 理论归一化曲线
C_theory_fine = (A_exp / 2) * ((lags_fine + 1).^alpha_theory + abs(lags_fine - 1).^alpha_theory - 2 * lags_fine.^alpha_theory);

%% ========================================================
% 4. 统一对比作图 (Visualization)
% ========================================================
figure('Position', [100, 100, 850, 520]); 
hold on;

% 1. 画理论曲线 (黑色实线)
plot(lags_fine, C_theory_fine, '-', 'Color', [0.2 0.2 0.2], 'LineWidth', 2.0, ...
    'DisplayName', sprintf('Theory (\\alpha = %.2f)', alpha_theory));

% 2. 画模拟数据点 (蓝色密集空心圆，步长 tau = 0.1)
plot(tau_sim_physical(valid_idx_sim), C_tau_sim(valid_idx_sim), ...
    'o', 'Color', [0 0.4470 0.7410], 'LineWidth', 1.2, ...
    'MarkerSize', 4.5, 'MarkerFaceColor', 'w', ...
    'DisplayName', 'Simulation Data');

% 3. 画实验数据点 (红色空心方块，无误差棒，整数 tau 采样)
lags_exp = 0:max_tau_physical;
plot(lags_exp(valid_idx_exp), C_tau_exp(valid_idx_exp), ...
    's', 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.5, ...
    'MarkerSize', 7, 'MarkerFaceColor', 'w', ...
    'DisplayName', 'Experimental Data');

% 4. 辅助虚线 y = 0
yline(0, '--k', 'LineWidth', 1.0, 'HandleVisibility', 'off'); 
hold off;

% 格式美化
xlabel('$\tau$', 'Interpreter', 'latex', 'FontSize', 14);
ylabel('$\langle \lambda(t) \lambda(t+\tau) \rangle$', 'Interpreter', 'latex', 'FontSize', 14);
legend('Location', 'northeast', 'FontSize', 11);
xlim([0, max_tau_physical]); 

% 动态下限设置
y_min_bound = min([C_theory_fine, C_tau_sim(valid_idx_sim), C_tau_exp(valid_idx_exp)]);
ylim([y_min_bound - abs(y_min_bound)*0.2, A_exp + abs(A_exp)*0.15]); 
set(gca, 'FontSize', 12, 'LineWidth', 1.2, 'TickDir', 'out', 'Box', 'on');