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
        
        v = exp(log(v) + k * deltat + (1 / sqrt(v)) * k_prime * sqrt(deltat) * randn);
        step_count = step_count + 1;
    end
    
    % 记录该世代的寿命和增长体积
    T_list(num) = t1;
    deltaV_list(num) = v1 - c; 
    
    v = b / 2; % 对半分裂，进入下一个细胞周期
end

%% 3. 数据统计与处理 (时间用离散整数，体积用连续分箱)
close all;
mean_T = mean(T_list);
mean_dV = mean(deltaV_list);

% --- 计算变异系数 CV ---
cv_T = std(T_list) / mean_T;
cv_dV = std(deltaV_list) / mean_dV;

% --- 处理寿命 T (严格按离散整数时间统计) ---
min_T = min(T_list);
max_T = max(T_list);
edges_T_raw = (min_T - 0.5) : 1 : (max_T + 0.5);
centers_T_raw = min_T : max_T; % 真实的整数时间点
counts_T = histcounts(T_list, edges_T_raw);
centers_T_norm = centers_T_raw / mean_T;

% --- 处理增长体积 delta V (保留连续变量分箱) ---
deltaV_norm = deltaV_list / mean_dV;
binnumber = 25; 
edges_dV = linspace(0.4, 1.6, binnumber + 1); 
centers_dV = edges_dV(1:end-1) + diff(edges_dV)/2; 
counts_dV = histcounts(deltaV_norm, edges_dV);

%% 4. 画频次分布折线图
figure('Position', [100, 100, 900, 400]);

% 子图1：寿命的频次分布
subplot(1, 2, 1);
plot(centers_T_norm, counts_T, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$T / \bar{T}$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Frequency', 'Interpreter', 'tex', 'FontSize', 12);
title('Distribution of Lifespan', 'Interpreter', 'tex', 'FontSize', 13);
grid on;
xlim([0.4, 1.6]);
ylim([0, 4500]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_T), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');
% 添加 (a) 标号
text(0.04, 0.92, '(a)', 'Units', 'normalized', 'FontSize', 12);

% 子图2：增长体积的频次分布 (不绘制 ylabel)
subplot(1, 2, 2);
plot(centers_dV, counts_dV, 'b-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$\Delta V / \overline{\Delta V}$', 'Interpreter', 'latex', 'FontSize', 12);
% (已移除 ylabel)
title('Distribution of Added Volume', 'Interpreter', 'tex', 'FontSize', 13);
grid on;
xlim([0.4, 1.6]);
ylim([0, 2200]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_dV), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');
% 添加 (b) 标号
text(0.04, 0.92, '(b)', 'Units', 'normalized', 'FontSize', 12);