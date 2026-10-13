% 读取数据
lengt = MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time = MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width = MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
deltaV_list = []; % 记录增长体积 (Added volume)
T_list = [];      % 记录寿命 (Lifespan)
for i = 1:size(lengt, 2)
    length_i = lengt{i};
    time_i = time{i};
    width_i = width{i};
    
    % 过滤掉数据点过少或有非法数据的轨迹
    if size(length_i, 2) <= 3
        continue
    end
    if any(isnan(width_i) | width_i == 0)
        continue
    end
    
    % 计算每一帧的体积
    volume_i = (length_i .* ((width_i/2).^2) - (2/3) * ((width_i/2).^3)) * pi;
    
    % 提取初始和最终状态
    Vb = volume_i(1);               % 出生体积
    Vd = volume_i(end);             % 临分裂前体积
    deltaV = Vd - Vb;               % 增长体积
    T = time_i(end) - time_i(1);    % 寿命 (时间跨度)
    
    deltaV_list = [deltaV_list, deltaV];
    T_list = [T_list, T];
end
%% 3. 数据统计与处理 (时间用离散整数，体积用连续分箱)
close all;
mean_T = mean(T_list)
mean_dV = mean(deltaV_list)

% --- 计算变异系数 CV ---
cv_T = std(T_list) / mean_T;
cv_dV = std(deltaV_list) / mean_dV;

% --- 处理寿命 T (严格按离散整数时间统计) ---
% 找出寿命的最小和最大整数分钟
min_T = min(T_list);
max_T = max(T_list);
% 生成刚好包裹每个整数的边界 (例如 19.5 到 20.5 会把 20 统计进去)
edges_T_raw = (min_T - 0.5) : 1 : (max_T + 0.5);
centers_T_raw = min_T : max_T; % 真实的整数时间点
% 统计频次
counts_T = histcounts(T_list, edges_T_raw);
% 将横轴中心点归一化，使其能与理论/实验的无量纲坐标系对齐
centers_T_norm = centers_T_raw / mean_T;
% --- 处理增长体积 delta V (保留连续变量分箱) ---
% 体积是连续演化的物理量，必须使用均匀分箱
deltaV_norm = deltaV_list / mean_dV;
% 强制锁定分箱区间为 0.4 到 1.6，分成 25 个箱子
binnumber = 25; 
edges_dV = linspace(0.4, 1.6, binnumber + 1); 
centers_dV = edges_dV(1:end-1) + diff(edges_dV)/2; 
% 统计频次
counts_dV = histcounts(deltaV_norm, edges_dV);
%% 4. 画频次分布折线图
figure('Position', [100, 100, 900, 400]);
% 子图1：寿命的频次分布 (每个点精确对应一个整数时间帧)
subplot(1, 2, 1);
plot(centers_T_norm, counts_T, 'r-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$T / \bar{T}$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Frequency', 'Interpreter', 'tex', 'FontSize', 12);
title('Distribution of Lifespan', 'Interpreter', 'tex', 'FontSize', 13);
grid on;
xlim([0.4, 1.6]); % 锁定横坐标显示范围
ylim([0, 4500]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_T), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');

% 子图2：增长体积的频次分布 (连续分箱)
subplot(1, 2, 2);
plot(centers_dV, counts_dV, 'r-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$\Delta V / \overline{\Delta V}$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Frequency', 'Interpreter', 'tex', 'FontSize', 12);
title('Distribution of Added Volume', 'Interpreter', 'tex', 'FontSize', 13);
grid on;
xlim([0.4, 1.6]); % 锁定横坐标显示范围
ylim([0, 2200]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_dV), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');