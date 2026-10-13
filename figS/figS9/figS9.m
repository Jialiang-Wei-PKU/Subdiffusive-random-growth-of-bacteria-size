close all;
% 1. 定义文件名和子图标签
fileNames = {'figS9pow.fig', 'figS9lin.fig', 'figS9exp.fig'};
labels = {'(a)', '(b)', '(c)'};
% 2. 创建 1 行 3 列的主画布
mainFig = figure('Color', 'w', 'Position', [100, 300, 1500, 400]); 
t = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');
for i = 1:length(fileNames)
    % 打开源 .fig 文件（隐藏模式）
    tempFig = openfig(fileNames{i}, 'invisible');
    
    % 找到主 Axes (排除图例对象)
    ax = findobj(tempFig, 'Type', 'axes', '-not', 'Tag', 'legend');
    if isempty(ax)
        ax = gca;
    else
        ax = ax(1); % 确保取到主坐标轴
    end
    
    % 在 1x3 布局中创建目标坐标轴
    targetAx = nexttile(t);
    
    % 拷贝原图中的所有图形对象（线条、散点等）
    copyobj(ax.Children, targetAx);
    
    % --- 属性同步 ---
    targetAx.XLim = ax.XLim;
    targetAx.YLim = ax.YLim;
    targetAx.XScale = ax.XScale;
    targetAx.YScale = ax.YScale;
    targetAx.Box = 'on';
    targetAx.Title.String = ''; % 隐藏原图名
    
    % 还原 X 轴、Y 轴标签及字体大小
    targetAx.XLabel.String = ax.XLabel.String;
    targetAx.XLabel.Interpreter = ax.XLabel.Interpreter;
    targetAx.XLabel.FontSize = 14;
    
    targetAx.YLabel.String = ax.YLabel.String;
    targetAx.YLabel.Interpreter = ax.YLabel.Interpreter;
    targetAx.YLabel.FontSize = 14;
    
    % =======================================================
    % --- 【线条与线宽处理逻辑】 ---
    % =======================================================
    % 1. 针对所有的线对象，根据不同子图设置线宽
    allLines = findobj(targetAx, 'Type', 'line');
    if strcmp(labels{i}, '(c)')
        set(allLines, 'LineWidth', 1.5); % 将 (c) 图所有线条的线宽设为 1.5
    else
        set(allLines, 'LineWidth', 1.0); % (a) 和 (b) 保持 1.0
    end
    
    % 2. 精准还原 (b) 图里的拟合直线
    if strcmp(labels{i}, '(b)')
        % 拟合直线的典型特征是没有数据点标记 (Marker 为 'none')
        fittedLines = findobj(targetAx, 'Type', 'line', 'Marker', 'none');
        if ~isempty(fittedLines)
            set(fittedLines, 'Color', 'k');      % 强行还原为黑色
            set(fittedLines, 'LineWidth', 1.5);  % 稍微加粗，与数据点区分开
            set(fittedLines, 'LineStyle', '-');  % 确保是实线
        end
    end
    % =======================================================
    
    % =======================================================
    % --- 【完美处理图例并修改列数】 ---
    % =======================================================
    oldLegend = findobj(tempFig, 'Type', 'Legend');
    if ~isempty(oldLegend)
        % 直接用 oldLegend.String 重新匹配
        newLeg = legend(targetAx, oldLegend.String, 'Interpreter', 'latex', 'Location', 'best');
        newLeg.FontSize = 12;
        
        % 修改列数：a 图 2 列，b 图 3 列
        if strcmp(labels{i}, '(a)')
            newLeg.NumColumns = 2;
        elseif strcmp(labels{i}, '(b)')
            newLeg.NumColumns = 3;
        end
    end
    
    % --- 在每个子图内部左上角添加 (a), (b), (c) 标签 ---
    text(targetAx, 0.02, 0.98, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'VerticalAlignment', 'top');
        
    % 关闭临时打开的原图
    close(tempFig);
end