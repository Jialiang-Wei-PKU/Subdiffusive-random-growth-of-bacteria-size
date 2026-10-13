% 1. 定义数据
tau_min_values = [0.01, 0.005, 0.002, 0.001];
alpha_values = [0.341207, 0.320113, 0.305437, 0.29445];

% 2. 计算 x 轴数据 (1/tau_min)
x = 1 ./ tau_min_values;

% 3. 创建图形
figure;
% 绘制 alpha vs 1/tau_min 的红色实线带圆点
plot(x, alpha_values, 'o-', 'LineWidth', 2, 'MarkerSize', 8);
hold on;

% 4. 添加 alpha = 0.3 的渐近线 (蓝色虚线)
yline(0.25, '--', 'LineWidth', 2);

% 5. 图形修饰
xlabel('$1/\tau_{0} \ (\mathrm{min}^{-1})$', 'FontSize', 16, 'Interpreter', 'latex');
ylabel('$\alpha$', 'FontSize', 16, 'Interpreter', 'latex');

% 调整坐标轴范围，使渐近线和趋势更明显
xlim([0, 1100]);
ylim([0.23, 0.35]);

% 添加图例
legend('simulation', 'theory', 'Location', 'best','Interpreter', 'tex', 'FontSize', 16);