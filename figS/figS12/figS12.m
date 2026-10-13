close all
% 1. 定义文件名（顺序：从左到右依次为 1, 2, 3）
fileNames = {'figS12relt.fig', 'figS12lnv.fig', 'figS12tim.fig'}; % <--- 替换为你实际的 3 个文件名
labels = {'(a)', '(b)', '(c)'};
% 调整画布尺寸，1行3列适合宽且扁的比例 (比如宽1500，高400)
mainFig = figure('Color', 'w', 'Position', [100, 300, 1500, 400]); 
% 关键修改：直接使用 1 行 3 列的紧凑布局
t = tiledlayout(1, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

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
    
    % =======================================================
    % 关键新增：为每张子图画一条 y = 0.026 的黑色虚线
    % =======================================================
    hold(targetAx, 'on');
    plot(targetAx, targetAx.XLim, [0.026, 0.026], 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
    hold(targetAx, 'off');
    
    % --- 标签处理 ---
    targetAx.XLabel.String = ax.XLabel.String;
    targetAx.YLabel.String = ax.YLabel.String;
    
    % X轴标签：第二张图用 latex，其他用 tex
    if i == 2
        set(targetAx.XLabel, 'Interpreter', 'latex', 'FontSize', 14);
    else
        set(targetAx.XLabel, 'Interpreter', 'tex', 'FontSize', 14);
    end
    
    % Y轴标签：1行3列的排版，通常只在最左边（第1个图）显示 Y 标签避免拥挤
    if i == 1 
        ylabel(targetAx, ax.YLabel.String, 'Interpreter', 'tex', 'FontSize', 14);
    else              
        ylabel(targetAx, ''); % 隐藏第2、3个图的 y 标签
    end
    % （注意：如果你的3张图Y轴代表的物理量完全不一样，请把上面的 if-else 删掉，直接统一保留 ylabel）
    
    % --- 解决线条粗细和点的大小问题 ---
    % 1. 针对普通的 plot 折线或点图
    allLines = findobj(targetAx, 'Type', 'line');
    % 过滤掉刚画的黑色虚线，避免修改它的 LineWidth
    for j = 1:length(allLines)
        if ~(strcmp(allLines(j).LineStyle, '--') && isequal(allLines(j).Color, [0 0 0]))
            set(allLines(j), 'LineWidth', 1.0);
            set(allLines(j), 'MarkerSize', 2); % 默认大小是6，这里调小到了2
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
    
    % 在每个子图内部的左上角添加文本 (a) (b) (c)
    text(targetAx, 0.02, 0.98, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'VerticalAlignment', 'top');
        
    close(tempFig);
end