close all

% 1. 定义文件名（顺序：从左到右依次为 1, 2）
fileNames = {'k0.1.fig', 'k0.2.fig'}; 
labels = {'(a)', '(b)'};

% 调整画布尺寸，1行2列适合中等宽度的比例 (比如宽1000，高400)
mainFig = figure('Color', 'w', 'Position', [100, 300, 1000, 400]); 

% 关键修改：直接使用 1 行 2 列的紧凑布局
t = tiledlayout(1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:length(fileNames)
    % 打开子图（隐藏模式）
    tempFig = openfig(fileNames{i}, 'invisible');
    ax = findobj(tempFig, 'Type', 'axes');
    
    % 直接按顺序往下放（从左往右）
    targetAx = nexttile(t);
    
    % 拷贝曲线内容
    copyobj(ax.Children, targetAx);
    
    % --- 属性同步 ---
    targetAx.XLim = ax.XLim;
    targetAx.YLim = ax.YLim;
    targetAx.Box = 'on';
    targetAx.Title.String = ''; % 隐藏原图名
    
    % --- 标签处理 ---
    targetAx.XLabel.String = ax.XLabel.String;
    targetAx.YLabel.String = ax.YLabel.String;
    
    set(targetAx.XLabel, 'Interpreter', 'tex', 'FontSize', 14);
    % Y轴标签：1行2列的排版，通常只在最左边（第1个图）显示 Y 标签避免拥挤
    if i == 1 
        ylabel(targetAx, ax.YLabel.String, 'Interpreter', 'tex', 'FontSize', 14);
    else              
        ylabel(targetAx, ''); % 隐藏第2个图的 y 标签
    end
    
    % --- 【关键修改】：解决线条粗细、点的大小以及虚线颜色问题 ---
    % 1. 针对普通的 plot 折线或点图
    allLines = findobj(targetAx, 'Type', 'line');
    for k = 1:length(allLines)
        ln = allLines(k);
        ln.LineWidth = 1.5;      % 统一线宽
        ln.MarkerSize = 2;       % 保持你设置的较小点尺寸
        
        % 如果是虚线，将其颜色设置为黑色 ('k')
        if strcmp(ln.LineStyle, '--')
            ln.Color = 'k';
        end
    end
    
    % 2. 针对 scatter 散点图
    allScatter = findobj(targetAx, 'Type', 'scatter');
    if ~isempty(allScatter)
        set(allScatter, 'SizeData', 10); % 默认大小是36，这里调小到了10
    end
    
    % --- 恢复图例 ---
    oldLegend = findobj(tempFig, 'Type', 'Legend');        
    if ~isempty(oldLegend)  
        newLeg = legend(targetAx, oldLegend.String, 'Interpreter', 'latex', ...
            'Location', 'best');
        newLeg.FontSize = 14;
    end
    
    % 在每个子图内部的左上角添加文本 (a) (b)
    text(targetAx, 0.02, 0.98, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'VerticalAlignment', 'top');
        
    close(tempFig);
end

% 导出前强制刷新
drawnow;