close all
% 1. 定义文件名（顺序：1-2是第一行，3-4是第二行，5-6是第三行）
fileNames = {'fig10simrelt.fig', 'fig10ksimrelt.fig', 'fig10simlnv.fig', 'fig10ksimlnv.fig', 'fig10simtim.fig', 'fig10ksimtim.fig'};
labels = {'(a)', '(d)', '(b)', '(e)', '(c)', '(f)'};
% 调整画布尺寸，3行2列适合稍微高一点的比例 (比如宽1000，高1200)
mainFig = figure('Color', 'w', 'Position', [100, 100, 1000, 1200]); 
% 关键修改：直接使用 3 行 2 列的紧凑布局
t = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:length(fileNames)
    % 打开子图（隐藏模式）
    tempFig = openfig(fileNames{i}, 'invisible');
    ax = findobj(tempFig, 'Type', 'axes');
    
    % 关键修改：不需要复杂的计算了，直接按顺序往下放
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
    
    if ismember(labels{i}, {'(b)', '(e)'})
        set(targetAx.XLabel, 'Interpreter', 'latex', 'FontSize', 14);
    else
        set(targetAx.XLabel, 'Interpreter', 'tex', 'FontSize', 14);
    end
    
    if mod(i, 2) ~= 0 % 左边的一列 (a, b, c) 保留 y 标签
        ylabel(targetAx, ax.YLabel.String, 'Interpreter', 'tex', 'FontSize', 14);
    else              % 右边的一列 (d, e, f) 隐藏 y 标签
        ylabel(targetAx, ''); 
    end
    
    % --- 解决线条粗细和点的大小问题 ---
    % 1. 针对普通的 plot 折线或点图
    allLines = findobj(targetAx, 'Type', 'line');
    % 注意：避免修改刚画的虚线，筛选掉 LineStyle 为 '--' 且颜色为黑色的线
    % 但更简单的办法是因为前面设置了 HandleVisibility='off'，只要 findobj 找不到它就不会被修改，或者干脆直接全改再重新设置，这里直接用简单的方式
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
    
    % 在每个子图内部的左上角添加文本
    % [0.02, 0.98] 适合标准比例的子图
    text(targetAx, 0.02, 0.98, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'VerticalAlignment', 'top');
        
    close(tempFig);
end

% 导出前强制刷新
drawnow;