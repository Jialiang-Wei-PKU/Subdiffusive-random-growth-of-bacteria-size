close all

% 1. 定义文件名
fileNames = {'expvstau.fig', 'expvsN.fig'}; 
% 标签
labels = {'(a)', '(b)'}; 

% 2. 创建主图窗口
% 宽度设为 1000，高度 400，适合 1x2 布局
mainFig = figure('Color', 'w', 'Position', [100, 100, 1000, 400]); 

% 3. 设置布局为 1行 2列
t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:length(fileNames)
    % 打开子图
    tempFig = openfig(fileNames{i}, 'invisible');
    ax = findobj(tempFig, 'Type', 'axes');
    
    if isempty(ax)
        close(tempFig); 
        continue; 
    end
    ax = ax(1); 
    
    % --- 布局分配 ---
    targetAx = nexttile(t); 
    
    % 拷贝内容
    copyobj(ax.Children, targetAx);
    
    % --- 坐标轴范围与样式 ---
    targetAx.XLim = ax.XLim;
    targetAx.YLim = ax.YLim; 
    
    targetAx.Box = 'on';
    targetAx.Title.String = ''; 
    targetAx.XLabel.String = ax.XLabel.String;
    
    % --- 【修改点 1】隐藏第二张图的 YLabel ---
    if i == 2
        targetAx.YLabel.String = ''; % 隐藏文字标签
        % 如果连Y轴的数字刻度也不想要，取消下面这行的注释：
        % targetAx.YTickLabel = []; 
    else
        targetAx.YLabel.String = ax.YLabel.String;
    end
    
    % 字体与解析器设置
    set(targetAx.XLabel, 'Interpreter', 'latex', 'FontSize', 14);
    if i == 1 % 只有第一张图需要设置 YLabel 字体，因为第二张图隐藏了
        set(targetAx.YLabel, 'Interpreter', 'latex', 'FontSize', 14);
    end
    set(targetAx, 'FontSize', 12); 
    
    allLines = findobj(targetAx, 'Type', 'line');
    if ~isempty(allLines)
        set(allLines, 'LineWidth', 1.0);
    end
    
    % --- 图例处理 ---
    oldLegend = findobj(tempFig, 'Type', 'Legend');
    if ~isempty(oldLegend)
        currentInterpreter = 'tex'; 
        newLeg = legend(targetAx, oldLegend.String, ...
            'Interpreter', currentInterpreter, ...
            'Location', 'best');
        newLeg.FontSize = 12; 
    end
    
    text(targetAx, 0.01, 0.98, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'FontName', 'Helvetica', ...
        'VerticalAlignment', 'top');
    
    close(tempFig);
end

% 强制刷新
drawnow;

% 导出 (取消注释以保存)
% exportgraphics(mainFig, 'Combined_1x2.pdf', 'ContentType', 'vector');