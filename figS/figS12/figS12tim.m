close all;
list  = [];
list1 = [];
list2 = [];

deltat = 0.05;
k = 0.026;
alpha_dist = 0.375;
tau_min = 0.01;
N = round(1000 * (100 * tau_min)^(-alpha_dist));
dt = 0.001;
exponent = -1 / alpha_dist;

% 构建长轨迹结构：388条包含47个cycle + 6条包含48个cycle (共394条轨迹，18524个cycle)
traj_lengths = [47 * ones(1, 388), 48 * ones(1, 6)];
total_trajectories = length(traj_lengths);

total_sim_cycles = sum(traj_lengths); % 18524
num_count = 0; % 记录当前模拟的总 cycle 进度

% --- 外层循环：遍历 394 条长轨迹 ---
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
    
    % --- 内层循环：连续模拟当前长轨迹内的所有 cell cycles ---
    for c_idx = 1:cycles_in_this_traj
        num_count = num_count + 1;
        
        % 打印进度提示
        if mod(num_count, 1000) == 0 || num_count == total_sim_cycles
            fprintf('Progress: Cycle %d / %d (Trajectory %d / %d)\n', ...
                num_count, total_sim_cycles, traj_idx, total_trajectories);
        end
        
        l = [];
        c = v;
        b = 1 + sqrt(3) * 0.12 * randn + c;
        
        % 当前周期的初始 r（直接继承上一周期/预热后的 s）
        r = sum(s) / (N * alpha_dist * (tau_min^alpha_dist));
        
        % 模拟单个 cell cycle 的生长
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
        
        % 下采样处理
        l0 = l(1:20:end);
        l1 = l(1:10:end);
        l2 = l(1:40:end);
        
        % 计算 list1 (基于 l0)
        siz = size(l0, 2);
        if siz > 1
            list1 = [list1, [0.5:siz-1.5; diff(log(l0))]];
        end
        
        % 计算 list (基于 l1)
        siz = size(l1, 2);
        if siz > 1
            list = [list, [(0.5:siz-1.5) * 0.5; diff(log(l1)) * 2]];
        end
        
        % 计算 list2 (基于 l2)
        siz = size(l2, 2);
        if siz > 1
            list2 = [list2, [(0.5:siz-1.5) * 2; diff(log(l2)) / 2]];
        end
        
        % 对半分裂，继承 s 状态进入下一个 cycle
        v = b / 2;
    end
end
%%
close all;
binnumber = 16; % 统一使用 2 min bin，32/2 = 16 个 bin

% 1. 处理 list (\Delta t = 0.5 min)
bin = zeros(1, binnumber);
timescale = list(1, :);
leng = list(2, :);
for n = 1:2:31
    len = leng(timescale >= (n-1) & timescale < (n+1));
    bin((n+1)/2) = mean(len);
end
plot(1:2:31, bin, "-o")
hold on

xlabel('Elapsed Time (min)', 'Interpreter', 'tex')
ylabel('Growth Rate', 'Interpreter', 'tex')
title('Simulated Growth Rate vs. Elapsed Time', 'Interpreter', 'tex')
ylim([0, 0.08])
xlim([0, 32])
%% 

% 2. 处理 list1 (\Delta t = 1 min)
bin = zeros(1, binnumber);
timescale = list1(1, :);
leng = list1(2, :);
for n = 1:2:31
    len = leng(timescale >= (n-1) & timescale < (n+1));
    bin((n+1)/2) = mean(len);
end
plot(1:2:31, bin, "-o")
hold on
%% 

% 3. 处理 list2 (\Delta t = 2 min)
bin = zeros(1, binnumber);
timescale = list2(1, :);
leng = list2(2, :);
for n = 1:2:31
    len = leng(timescale >= (n-1) & timescale < (n+1));
    bin((n+1)/2) = mean(len);
end
plot(1:2:31, bin, "-o")

%% 
legend('$\Delta t$=0.5 min', '$\Delta t$=1 min', '$\Delta t$=2 min', 'Interpreter', 'latex')