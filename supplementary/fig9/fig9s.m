close all

% 1. 定义文件名（顺序已经是：第一行左右，第二行左右，第三行左右）
fileNames = {'0301.fig', '0208.fig', '0115.fig', '0125.fig', '0110.fig', '0304.fig'};
labels = {'(a)', '(d)', '(b)', '(e)', '(c)', '(f)'};

mainFig = figure('Color', 'w', 'Position', [100, 100, 1200, 800]); % 宽屏布局

% 设为纯 3 行 2 列的紧凑布局
t = tiledlayout(3, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

for i = 1:length(fileNames)
    % 打开子图（隐藏模式）
    tempFig = openfig(fileNames{i}, 'invisible');
    ax = findobj(tempFig, 'Type', 'axes');
    
    % 直接按顺序跳转到下一个格子
    targetAx = nexttile(t);
    
    % 拷贝曲线内容
    copyobj(ax.Children, targetAx);
    
    % --- 属性同步 ---
    targetAx.XLim = ax.XLim;
    targetAx.YLim = ax.YLim;
    targetAx.Box = 'on';
    targetAx.Title.String = ''; % 隐藏原图名
    
    % --- 关键：标签处理 ---
    % 默认先清空当前子图的标签
    xlabel(targetAx, '');
    ylabel(targetAx, '');
    
    % 仅保留 (c) 和 (f) 图的 xlabel，并统一使用 tex 编译器
    if ismember(labels{i}, {'(c)', '(f)'})
        xlabel(targetAx, ax.XLabel.String, 'Interpreter', 'tex', 'FontSize', 14);
    end
    
    % 仅保留 (a), (b), (c) 图的 ylabel，并统一使用 tex 编译器
    if ismember(labels{i}, {'(a)', '(b)', '(c)'})
        ylabel(targetAx, ax.YLabel.String, 'Interpreter', 'tex', 'FontSize', 14);
    end
    
    % ==========================================================
    % --- 【关键修改】：同步你的代码中的线宽和点大小 ---
    % ==========================================================
    targetSolidLineWidth = 2.0;  % 实线和误差棒线宽 (对应你代码里的 2)
    targetDashedLineWidth = 1.5; % 虚线线宽 (对应你代码里 plot 的 2.5)
    targetMarkerSize = 8;        % 点的大小 (对应你代码里的 8)
    
    % 1. 处理普通的线
    allLines = findobj(targetAx, 'Type', 'line');
    for k = 1:length(allLines)
        ln = allLines(k);
        
        if strcmp(ln.LineStyle, '--')
            ln.Color = 'k'; % 虚线变黑
            ln.LineWidth = targetDashedLineWidth; % 虚线应用 2.5 线宽
        else
            ln.Color = 'r'; % 实线变红
            ln.LineWidth = targetSolidLineWidth;  % 实线应用 2.0 线宽
        end
        
        if ~strcmp(ln.Marker, 'none')
            ln.MarkerSize = targetMarkerSize;     % 强制点大小为 8
            ln.MarkerEdgeColor = 'r';      
            ln.MarkerFaceColor = 'w';      
        end
    end
    
    % 2. 处理带有误差棒的线 (Errorbar 对象)
    allErrorbars = findobj(targetAx, 'Type', 'errorbar');
    for k = 1:length(allErrorbars)
        eb = allErrorbars(k);
        eb.Color = 'r'; 
        eb.LineWidth = targetSolidLineWidth;      % 误差棒线宽统一为 2.0
        
        if ~strcmp(eb.Marker, 'none')
            eb.MarkerSize = targetMarkerSize;     % 强制点大小为 8
            eb.MarkerEdgeColor = 'r';      
            eb.MarkerFaceColor = 'w';      
        end
    end
    
    % 3. 兼容处理 Scatter (纯散点)
    allScatters = findobj(targetAx, 'Type', 'scatter');
    if ~isempty(allScatters)
        % Scatter 的大小属性是面积，通常是 MarkerSize 的平方
        set(allScatters, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'w', 'SizeData', targetMarkerSize^2); 
    end
    
    % --- 恢复图例 ---
    if ismember(i, [1,2,3,4])
        oldLegend = findobj(tempFig, 'Type', 'Legend');        
        if ~isempty(oldLegend)  
            % 获取图例项的总数
            numItems = length(oldLegend.String);
            
            % 想要 2 行，反推需要的列数（向上取整）
            cols = ceil(numItems / 2); 
            
            % 设置 NumColumns 为算出的列数，图例也统一换成 tex 编译器
            newLeg = legend(targetAx, oldLegend.String, 'Interpreter', 'tex', ...
                'Location', 'best', 'NumColumns', cols);
            newLeg.FontSize = 10;
        end
    end
    
    % 在每个子图内部的左上角添加文本
    text(targetAx, 0.02, 0.98, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'VerticalAlignment', 'top');
        
    close(tempFig);
end

% 导出前强制刷新
drawnow;