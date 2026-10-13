close all;
lengt=MOPS_glucose_12AA_37C_DChamb_20140212.L_v_T;
time=MOPS_glucose_12AA_37C_DChamb_20140212.T_v_T;
width=MOPS_glucose_12AA_37C_DChamb_20140212.W_v_T;
list=[];
list2=[];
list3=[];
list4=[];
binnumber=25;
for i=1:size(lengt,2)
    length_i=lengt{i};
    time_i=time{i};
    width_i=width{i};
    if size(length_i,2) <= 4
        continue
    end
    if any(isnan(width_i) | width_i == 0)
        continue
    end
    volume_i=(lengt{i}.*((width{i}/2).^2)-(2/3)*((width{i}/2).^3))*pi;
    %volume_i=lengt{i};
    %volume_i=lengt{i}*pi.*width{i};
    siz=size(volume_i,2);
    list=[list,[1/(2*(siz-1)):1/(siz-1):1-1/(2*(siz-1));diff(log(volume_i));1/(siz-1)+zeros(1,siz-1)]];
    list2=[list2,[1/(siz-1):1/(siz-1):1-1/(siz-1);log(volume_i(3:end))-log(volume_i(1:end-2));1/(siz-2)+zeros(1,siz-2)]];
    list3=[list3,[1.5/(siz-1):1/(siz-1):1-1.5/(siz-1);log(volume_i(4:end))-log(volume_i(1:end-3));1/(siz-3)+zeros(1,siz-3)]];
    list4=[list4,[2/(siz-1):1/(siz-1):1-2/(siz-1);log(volume_i(5:end))-log(volume_i(1:end-4));1/(siz-4)+zeros(1,siz-4)]];
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
ylabel('Variance of Logarithmic Volume Change','Interpreter','tex','FontSize',16)
legend('$\Delta t$=1 min','$\Delta t$=2 min','$\Delta t$=3 min','$\Delta t$=4 min','Interpreter','latex','FontSize',14,'Location','best', 'NumColumns', 2)
title('Variance of Logarithmic Volume Change vs. Relative Age','Interpreter','tex','FontSize',16)
% 1. 定义 x 轴数据 (Relative Age)
x = (3/(2*binnumber)) : (1/binnumber) : (1 - 3/(2*binnumber));

% 2. 筛选出 0.2 到 0.8 范围内的逻辑索引
idx = (x >= 0.2) & (x <= 0.8);

% 3. 计算 bin 在该区间的平均值
mean_bin_range = mean(bin(idx));

% 打印结果
fprintf('bin 在 Relative Age (0.2 - 0.8) 区间的平均值为: %.6f\n', mean_bin_range);
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
eb = errorbar(3/(2*binnumber):1/binnumber:1-3/(2*binnumber),slop,slop_err, '-o','Color', 'r', 'LineWidth', 2, 'MarkerSize', 8, 'MarkerFaceColor', 'w');
hold on
x_coords = 3/(2*binnumber):1/binnumber:1-3/(2*binnumber);
mask = (x_coords >= 0.2 & x_coords <= 0.8);
mean_val = mean(slop(mask));
plot([0.2, 0.8], [mean_val, mean_val], 'k--', 'LineWidth', 2.5);
xlabel('Relative Age','Interpreter','tex','FontSize',16)
ylabel('Exponent','Interpreter','tex','FontSize',16)
ylim([0,1])
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
xlabel('$\Delta t$ (log)','Interpreter','latex','FontSize',16)
ylabel('Variance of Logarithmic Volume Change (log)','Interpreter','tex','FontSize',16)
legend('$a=0.18$','$a=0.34$','$a=0.50$','$a=0.66$','$a=0.82$','Interpreter','latex','FontSize',14,'Location','best', 'NumColumns', 2)
xlim([-0.2,1.6]);
ylim([-6.5,-3.5]); 