% 1. 定义数据
N = [2371, 4743, 11857, 23714];
alpha_values = [0.29445, 0.294402, 0.289703, 0.292291];

% 2. 计算 x 轴数据 (1/tau_min)
x = N;

% 3. 创建图形
figure;
% 绘制 alpha vs 1/tau_min 的红色实线带圆点
plot(x, alpha_values, 'o-', 'LineWidth', 2, 'MarkerSize', 8);

% 5. 图形修饰
xlabel('$N$', 'FontSize', 16, 'Interpreter', 'latex');
ylabel('$\alpha$', 'FontSize', 16, 'Interpreter', 'latex');

% 调整坐标轴范围，使渐近线和趋势更明显
xlim([0, 25000]);
ylim([0.23, 0.35]);
