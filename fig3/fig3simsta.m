%% 2. 使用全新的分数阶/叠加 O-U 噪声模型进行模拟（按长轨迹组织）
deltat = 0.05;
k = 0.026;
alpha_dist = 0.375;
tau_min = 0.001;
dt = 0.001;
exponent = -1 / alpha_dist;

% 计算所需的独立成分数量 N
N = round(1000 * (100 * tau_min)^(-alpha_dist));

% 构建轨迹结构：388条47个cycle + 6条48个cycle，共计 18524 个 cycles
traj_lengths = [47 * ones(1, 388), 48 * ones(1, 6)];
total_trajectories = length(traj_lengths);

% 根据实际模拟的世代总数分配内存
total_sim_cycles = sum(traj_lengths);
T_list = zeros(1, total_sim_cycles);
deltaV_list = zeros(1, total_sim_cycles);

disp('开始进行高精度长轨迹模拟，请耐心等待...');
tic; % 开始计时

num_count = 0; % 记录当前模拟到的总 cycle 数 (1 到 18524)

% --- 外层循环：遍历 394 条长轨迹 ---
for traj_idx = 1:total_trajectories
    cycles_in_this_traj = traj_lengths(traj_idx);
    
    % 1. 每条长轨迹单独取样专属的 tau (X)
    U = rand(1, N);
    X = tau_min * (U.^exponent);
    
    % 2. 仅在长轨迹开头初始化噪声状态 s，并预热 10 分钟 (10000 步)
    s = zeros(1, N);
    for i = 1:10000
        dW = randn * sqrt(dt) / 140; 
        s = s .* (1 - dt ./ X) + dW;
    end
    
    % 3. 初始化当前轨迹第一代细胞的出生体积
    v = 1 + 0.12 * randn;
    
    % --- 内层循环：连续模拟当前长轨迹内的所有 cell cycles ---
    for c_idx = 1:cycles_in_this_traj
        num_count = num_count + 1; % 累加总世代数
        
        c = v; % 出生体积 V_b
        b = 1 + sqrt(3) * 0.12 * randn + c; % Adder模型：分裂阈值体积
        
        % 当前周期的初始 r（基于继承或预热后的 s 状态）
        r = sum(s) / (N * alpha_dist * (tau_min^alpha_dist));
        
        step_count = 0;
        v1 = c; 
        t1 = 0;
        
        % --- 细胞生长循环 ---
        while v < b
            if mod(step_count, 20) == 0 
                t1 = step_count * 0.05; % 更新最后一次拍到的时间 (min)
                v1 = v;                 % 更新最后一次拍到的体积
            end 
            
            % 前进 50 * 0.001 = 0.05 的时间步
            for i = 1:50
                dW = randn * sqrt(dt) / 140; 
                s = s .* (1 - dt ./ X) + dW;
            end
            
            w = sum(s) / (N * alpha_dist * (tau_min^alpha_dist));
            h = w - r;
            r = w;
            
            % 更新体积
            v = exp(log(v) + k * deltat + h);
            step_count = step_count + 1;
        end
        
        % 记录该世代的寿命和增长体积
        T_list(num_count) = t1;
        deltaV_list(num_count) = v1 - c; 
        
        % 对半分裂，进入下一个细胞周期（s 保持连续传递，不重置）
        v = b / 2;
        
        % 打印进度提示
        if mod(num_count, 1000) == 0 || num_count == total_sim_cycles
            disp(['已完成: ', num2str(num_count), ' / ', num2str(total_sim_cycles), ...
                  ' 个世代 (轨迹 ', num2str(traj_idx), ' / ', num2str(total_trajectories), ')']);
        end
    end
end

toc; % 结束计时
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
%% 4. 画频次分布折线图 (含 Panel c/d 标识)
figure('Position', [100, 100, 900, 400]);

% --- 子图 (c)：寿命的频次分布 ---
subplot(1, 2, 1);
plot(centers_T_norm, counts_T, 'b-o', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$T / \bar{T}$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Frequency', 'Interpreter', 'tex', 'FontSize', 12);
grid on;
xlim([0.4, 1.6]); % 锁定横坐标显示范围
ylim([0, 4500]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_T), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');

% 添加 Panel (c) 标识
text(0.03, 0.92, '(c)', 'Units', 'normalized', 'FontSize', 14, 'Interpreter', 'tex');


% --- 子图 (d)：增长体积的频次分布 ---
subplot(1, 2, 2);
plot(centers_dV, counts_dV, 'b-s', 'LineWidth', 1.5, 'MarkerFaceColor', 'w');
xlabel('$\Delta V / \overline{\Delta V}$', 'Interpreter', 'latex', 'FontSize', 12);
ylabel('Frequency', 'Interpreter', 'tex', 'FontSize', 12);
grid on;
xlim([0.4, 1.6]); % 锁定横坐标显示范围
ylim([0, 2200]);
text(0.70, 0.88, sprintf('CV = %.3f', cv_dV), 'Units', 'normalized', 'FontSize', 11, 'Interpreter', 'tex');

% 添加 Panel (d) 标识
text(0.03, 0.92, '(d)', 'Units', 'normalized', 'FontSize', 14, 'Interpreter', 'tex');