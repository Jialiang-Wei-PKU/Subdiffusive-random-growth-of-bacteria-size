% 1. 读取实验数据并统计有效的轨迹数量
lengt = MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
width = MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
valid_count = 0;
for i = 1:size(lengt, 2)
    length_i = lengt{i};
    width_i = width{i};
    % 使用与实验数据相同的过滤标准
    if size(length_i, 2) > 3 && ~any(isnan(width_i) | width_i == 0)
        valid_count = valid_count + 1;
    end
end

%% 2. 模拟数据生成 (使用真实物理时间种子 & 标量覆盖法)
% 【核心修改 1】：打乱随机数池。
% rng('shuffle') 会读取你电脑主板当前的高精度时间戳作为种子。
% 这引入了物理世界的不可预测性，使得每次运行生成的轨迹都完全不同。
rng('shuffle'); 

deltat = 0.05;
k_prime = sqrt(0.0014);
v = 1 + 0.12 * randn;
k = 0.026;
% 根据实验有效轨迹数预分配内存
T_list = zeros(1, valid_count);
deltaV_list = zeros(1, valid_count);

for num = 1:valid_count
    c = v; % 出生体积 V_b
    b = 1 + sqrt(3) * 0.12 * randn + c; % Adder模型：分裂阈值体积
    
    step_count = 0;
    
    % 初始化观测值（假设 t=0 拍下第一帧）
    v1 = c; 
    t1 = 0;
    
    % GBM 随机生长过程
    while v < b
        if mod(step_count, 20) == 0 
            t1 = step_count * 0.05; % 更新最后一次拍到的时间 (min)
            v1 = v;                 % 更新最后一次拍到的体积
        end 
        
        v = exp(log(v) + k * deltat + k_prime * sqrt(deltat) * randn);
        step_count = step_count + 1;
    end
    
    % 记录该世代的寿命和增长体积
    T_list(num) = t1;
    deltaV_list(num) = v1 - c; 
    
    v = b / 2; % 对半分裂，进入下一个细胞周期
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
plot(centers_T_norm, counts_T, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$T / \bar{T}$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Frequency', 'Interpreter', 'tex', 'FontSize', 12);
title('Distribution of Lifespan', 'Interpreter', 'tex', 'FontSize', 13);
grid on;
xlim([0.4, 1.6]); % 锁定横坐标显示范围
ylim([0, 4500]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_T), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');

% 子图2：增长体积的频次分布 (连续分箱)
subplot(1, 2, 2);
plot(centers_dV, counts_dV, 'b-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$\Delta V / \overline{\Delta V}$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Frequency', 'Interpreter', 'tex', 'FontSize', 12);
title('Distribution of Added Volume', 'Interpreter', 'tex', 'FontSize', 13);
grid on;
xlim([0.4, 1.6]); % 锁定横坐标显示范围
ylim([0, 2200]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_dV), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');ylim([0, 2200]);