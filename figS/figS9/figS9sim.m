close all;
%% 1. 数据对齐与提取 (更新了横坐标生成逻辑)
lengt=MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time=MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width=MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
list=[];
list2=[];
list3=[];
list4=[];
binnumber=32;

for i=1:size(lengt,2)
    length_i=lengt{i};
    time_i=time{i};
    width_i=width{i};
    if size(length_i,2) <= 3
        continue
    end
    if any(isnan(width_i) | width_i == 0)
        continue
    end
    volume_i=(lengt{i}.*((width{i}/2).^2)-(2/3)*((width{i}/2).^3))*pi;
    siz=size(volume_i,2);
    
    % 更新后的带有半整数偏移的坐标逻辑
    list=[list,[1/2:siz-3/2;diff(log(volume_i))]];
    list2=[list2,[1:siz-2;log(volume_i(3:end))-log(volume_i(1:end-2))]];
    list3=[list3,[3/2:siz-5/2;log(volume_i(4:end))-log(volume_i(1:end-3))]];
    list4=[list4,[2:siz-3;log(volume_i(5:end))-log(volume_i(1:end-4))]];
end

%% 2. 方差计算 (更新为区间判断：>= n 并 < n+1)
bin=zeros(1,binnumber-2);
timescale=list(1,:);
leng=list(2,:);
for n=1:binnumber-2
    len=leng(timescale>=n & timescale<n+1);
    bin(n)=var(len);
end

bin2=zeros(1,binnumber-2);
timescale=list2(1,:);
leng=list2(2,:);
for n=1:binnumber-2
    len=leng(timescale>=n & timescale<n+1);
    bin2(n)=var(len);
end

bin3=zeros(1,binnumber-2);
timescale=list3(1,:);
leng=list3(2,:);
for n=1:binnumber-2
    len=leng(timescale>=n & timescale<n+1);
    bin3(n)=var(len);
end

bin4=zeros(1,binnumber-2);
timescale=list4(1,:);
leng=list4(2,:);
for n=1:binnumber-2
    len=leng(timescale>=n & timescale<n+1);
    bin4(n)=var(len);
end

%% 3. 画图: Variance of Logarithmic Volume Change vs. Elapsed Time
close all
figure;

% 定义要绘制的横坐标索引: 4, 9, 14, 19, 24, 29
idx = 4:5:binnumber-2; 

% 画图时，横纵坐标都只取 idx 对应的值
plot(idx, bin(idx), "b-o", 'MarkerSize', 8, 'LineWidth', 2)
hold on
plot(idx, bin2(idx), "r-o", 'MarkerSize', 8, 'LineWidth', 2)
plot(idx, bin3(idx), "m-o", 'MarkerSize', 8, 'LineWidth', 2)
plot(idx, bin4(idx), "g-o", 'MarkerSize', 8, 'LineWidth', 2)

set(gca, 'FontSize', 14);
xlabel('Elapsed Time', 'Interpreter', 'tex', 'FontSize', 16)
ylabel('MSD', 'Interpreter', 'tex', 'FontSize', 16)
legend('$\Delta t$=1 min', '$\Delta t$=2 min', '$\Delta t$=3 min', '$\Delta t$=4 min', ...
       'Interpreter', 'latex', 'FontSize', 14, 'Location', 'best', 'NumColumns', 2)
xlim([0, 32])

%% 4. 指数拟合与画图 (基于最新的剔除规则：i=14 全部参与拟合)
slop = NaN(1, binnumber-2);
slop_err = NaN(1, binnumber-2);

for i = 1:binnumber-2
    % 基于物理区间偏移的新规则 (i=14 恢复为全部拟合)
    if i == 15
        x_vals = [3, 4];
        y_vals = [bin3(i), bin4(i)];
    elseif i == 16
        x_vals = [2, 3, 4];
        y_vals = [bin2(i), bin3(i), bin4(i)];
    elseif i == 17
        x_vals = [1, 4];
        y_vals = [bin(i), bin4(i)];
    elseif i == 18
        x_vals = [1, 2, 3];
        y_vals = [bin(i), bin2(i), bin3(i)];
    else
        x_vals = [1, 2, 3, 4];
        y_vals = [bin(i), bin2(i), bin3(i), bin4(i)];
    end
    
    [k1, k2] = getLogFitSlopeWithError(x_vals, y_vals);
    slop(i) = k1;
    slop_err(i) = k2;
end

figure;
hold on;

% 只绘制 4, 9, 14, 19, 24, 29 的点
idx = 4:5:binnumber-2; 

% 绘制 Errorbar (i=14 现在拥有 4 个点拟合，因此可以正常算出 Errorbar)
eb = errorbar(idx, slop(idx), slop_err(idx), '-o', ...
    'Color', 'r', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'w');

% 计算均值（只计算画出来的这 6 个点的均值）
slop_plotted = slop(idx);
mask = ~isnan(slop_plotted); 
mean_val = mean(slop_plotted(mask));

% 绘制均值虚线
plot([idx(1), idx(end)], [mean_val, mean_val], 'k--', 'LineWidth', 1.5);

set(gca, 'FontSize', 14);
xlabel('Elapsed Time', 'Interpreter', 'tex', 'FontSize', 16)
ylabel('Exponent', 'Interpreter', 'tex', 'FontSize', 16)
ylim([0, 1])
xlim([0, 32])

close all;
figure;

% 定义 t 的列表
t_list = [4, 9, 14, 19, 24, 29]; % 即原代码 4:5:binnumber-2

q = []; % 用于保存拟合线的 Y 值矩阵

% --- 第 1 个循环：画数据散点 + 计算拟合线 ---
for i = t_list
    x_vals = [1, 2, 3, 4];
    y_vals = [bin(i), bin2(i), bin3(i), bin4(i)];
    
    x_log = log(x_vals);
    y_log = log(y_vals);
    offset = i / 10; % 垂直偏移量
    
    % 1. 画散点
    plot(x_log, y_log + offset, 'o', 'MarkerSize', 8, 'LineWidth', 2);
    hold on;
    
    % 2. 拟合计算
    p = polyfit(x_log, y_log, 1);
    y_fit = polyval(p, x_log);
    
    % 3. 像第一段代码那样，按行存入矩阵 q
    q = [q; y_fit + offset];
end

% --- 第 2 个循环：画黑色拟合直线（像第一段代码那样直接画，不加 HandleVisibility）---
row_idx = 1;
for i = t_list
    x_log = log([1, 2, 3, 4]);
    plot(x_log, q(row_idx, :), '-', 'Color', [0 0 0], 'LineWidth', 2);
    hold on;
    row_idx = row_idx + 1;
end

% --- 坐标轴与图例设置（完全对标第一段代码的格式）---
xlabel('$\Delta t$ (log)', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('log(MSD)', 'Interpreter', 'tex', 'FontSize', 16);

% 图例直接列出各条线对应的名称
legend('$t=4$ min', '$t=9$ min', '$t=14$ min', '$t=19$ min', '$t=24$ min', '$t=29$ min', ...
       'Interpreter', 'latex', 'FontSize', 12, 'Location', 'best', 'NumColumns', 3);

xlim([-0.2, 1.6]);
ylim([-6.5, -1.5]);
set(gca, 'FontSize', 14, 'Box', 'on');
%% 局部函数
function [slope, slope_error] = getLogFitSlopeWithError(x_vals, y_values)
    x = log(x_vals)'; 
    y = log(y_values)';
    mdl = fitlm(x, y, 'VarNames', {'Delta_t_log', 'Bin_log'});
    slope = mdl.Coefficients.Estimate(2);
    slope_error = mdl.Coefficients.SE(2);
end