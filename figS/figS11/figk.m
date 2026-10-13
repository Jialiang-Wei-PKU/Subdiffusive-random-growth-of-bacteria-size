clear;
%% 
close all; 
list  = [];
list2 = [];
list3 = [];
list4 = [];

deltat = 0.05;
binnumber = 25;
alpha_dist = 0.375;
tau_min = 0.001;
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
    
    % 1. 每条长轨迹单独取样专属的 tau (X)（整条轨迹固定）
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
        
        % 1. 每个 cell-cycle 重新单独 sample 一次 k
        k = 0.026 * (1 + 0.2 * randn);
        
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
        
        % 分裂：体积减半，s 保持连续传递到下一个 cycle
        v = b / 2;
        
        % 下采样与列表统计
        l = l(1:20:end);
        siz = size(l, 2);
        if siz <= 4
            continue;
        end
        
        list  = [list,  [1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1)); diff(log(l));                   1/(siz-1)+zeros(1,siz-1)]];
        list2 = [list2, [1/(siz-1):1/(siz-1):1-1/(siz-1);         log(l(3:end))-log(l(1:end-2)); 1/(siz-2)+zeros(1,siz-2)]];
        list3 = [list3, [1.5/(siz-1):1/(siz-1):1-1.5/(siz-1);     log(l(4:end))-log(l(1:end-3)); 1/(siz-3)+zeros(1,siz-3)]];
        list4 = [list4, [2/(siz-1):1/(siz-1):1-2/(siz-1);         log(l(5:end))-log(l(1:end-4)); 1/(siz-4)+zeros(1,siz-4)]];
    end
end
%% 
bin=zeros(1,binnumber-2);
timescale=list(1,:);
leng=list(2,:);
weight=list(3,:);
for n=1:binnumber-2
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    ave=sum(len.*wei)/sum(wei);
    bin(n)=sum(wei.*(len-ave).^2)/sum(wei);
end
bin2=zeros(1,binnumber-2);
timescale=list2(1,:);
leng=list2(2,:);
weight=list2(3,:);
for n=1:binnumber-2
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    ave=sum(len.*wei)/sum(wei);
    bin2(n)=sum(wei.*(len-ave).^2)/sum(wei);
end
bin3=zeros(1,binnumber-2);
timescale=list3(1,:);
leng=list3(2,:);
weight=list3(3,:);
for n=1:binnumber-2
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    ave=sum(len.*wei)/sum(wei);
    bin3(n)=sum(wei.*(len-ave).^2)/sum(wei);
end
bin4=zeros(1,binnumber-2);
timescale=list4(1,:);
leng=list4(2,:);
weight=list4(3,:);
for n=1:binnumber-2
    len=leng(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    wei=weight(timescale>=n/binnumber&timescale<=(n+1)/binnumber);
    ave=sum(len.*wei)/sum(wei);
    bin4(n)=sum(wei.*(len-ave).^2)/sum(wei);
end
%% 
close all
plot(3/(2*binnumber):1/binnumber:1-3/(2*binnumber),bin,"b-o",'MarkerSize',8,'LineWidth', 2)
hold on
plot(3/(2*binnumber):1/binnumber:1-3/(2*binnumber),bin2,"r-o",'MarkerSize',8,'LineWidth', 2)
hold on
plot(3/(2*binnumber):1/binnumber:1-3/(2*binnumber),bin3,"m-o",'MarkerSize',8,'LineWidth', 2)
hold on
plot(3/(2*binnumber):1/binnumber:1-3/(2*binnumber),bin4,"g-o",'MarkerSize',8,'LineWidth', 2)
set(gca,'FontSize',14);
xlabel('Relative Age','Interpreter','tex','FontSize',16)
ylabel('$\sigma^{2}(\Delta\ln(V))$','Interpreter','latex','FontSize',16)
legend('∆t=1min','∆t=2min','∆t=3min','∆t=4min','Interpreter','tex','FontSize',14,'Location','best')
title('Variance of Logarithmic Volume Change vs. Relative Age','Interpreter','tex','FontSize',16)
%% 
close all;
function [slope, slope_error] = getLogFitSlopeWithError(y_values)
    x = log([1 2 3 4])'; 
    y = log(y_values);
    mdl = fitlm(x, y, 'VarNames', {'Delta_t_log', 'Bin_log'});
    slope = mdl.Coefficients.Estimate(2);
    slope_error = mdl.Coefficients.SE(2);
end
slop=[];
slop_err=[];
for i=1:binnumber-2
    [k1,k2]=getLogFitSlopeWithError([bin(i),bin2(i),bin3(i),bin4(i)]);
    slop=[slop,k1];
    slop_err=[slop_err,k2];
end
x_shade = [0.2, 0.8, 0.8, 0.2];
y_limits = [0, 2]; 
y_shade = [y_limits(1), y_limits(1), y_limits(2), y_limits(2)];
fill(x_shade, y_shade, [0.9, 0.9, 0.9], 'EdgeColor', 'none', 'FaceAlpha', 1);
hold on
eb = errorbar(3/(2*binnumber):1/binnumber:1-3/(2*binnumber),slop,slop_err, '-o','Color', 'b', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'w');
hold on
x_coords = 3/(2*binnumber):1/binnumber:1-3/(2*binnumber);
mask = (x_coords >= 0.2 & x_coords <= 0.8);
mean_val = mean(slop(mask))
plot([0.2, 0.8], [mean_val, mean_val], 'k--', 'LineWidth', 2.5);
xlabel('Relative Age','Interpreter','tex','FontSize',16)
ylabel('Exponent','Interpreter','tex','FontSize',16)
ylim([0,1.1])
title('Diffusive Exponent vs. Relative Age','Interpreter','tex','FontSize',16)
%% 
close all;
q=[];
for i=4:4:20
    plot(log([1 2 3 4]),log([bin(i),bin2(i),bin3(i),bin4(i)])+i/10,'o','MarkerSize',8,'LineWidth', 2)
    p = polyfit(log([1 2 3 4]), log([bin(i),bin2(i),bin3(i),bin4(i)]), 1);
    slope = p(1);
    intercept = p(2);
    y_fit = polyval(p, log([1 2 3 4]));
    hold on
    q=[q;y_fit+i/10];
end
for i=4:4:20
    plot(log([1 2 3 4]),q(i/4,:),'-','Color', [0 0 0],'MarkerSize',8,'LineWidth', 2)
    hold on
end
xlabel('$\ln(\Delta t)$','Interpreter','latex','FontSize',16)
ylabel('$\ln(\sigma^{2}(\Delta\ln(V)))$','Interpreter','latex','FontSize',16)
legend('a=0.18','a=0.34','a=0.50','a=0.66','a=0.82','Interpreter','latex','FontSize',14,'Location','best')
xlim([-0.2,1.6])