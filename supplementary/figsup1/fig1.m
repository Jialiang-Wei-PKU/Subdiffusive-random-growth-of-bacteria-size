close all

% 1. 定义文件名列表
fileNames = {'fig1simrelt.fig', 'fig1simlnv.fig', 'fig1simtim.fig', 'fig1exprelt.fig', 'fig1explnv.fig', 'fig1exptim.fig'};

% 画板尺寸调整，适合 2x3 的紧凑排版
mainFig = figure('Color', 'w', 'Position', [100, 100, 1000, 600]); 

% 直接使用简单的 2行 3列 布局
t = tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

% 更新标签
labels = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};

for i = 1:length(fileNames)
    % 打开子图
    tempFig = openfig(fileNames{i}, 'invisible');
    ax = findobj(tempFig, 'Type', 'axes');
    if isempty(ax), close(tempFig); continue; end
    ax = ax(1);
    
    % 顺序分配 2x3 网格中的位置
    targetAx = nexttile(t); 
    
    % 内容拷贝
    copyobj(ax.Children, targetAx);
    
    % --- 统一属性同步 ---
    targetAx.XLim = ax.XLim;
    targetAx.YLim = ax.YLim;
    targetAx.Box = 'on'; 
    targetAx.Title.String = ''; % 所有图都不显示图名
    
    % --- 前3张图画 y=0.026 的虚线 ---
    if i <= 3
        hold(targetAx, 'on');
        plot(targetAx, targetAx.XLim, [0.026, 0.026], 'k--', 'LineWidth', 1.5, 'HandleVisibility', 'off');
        hold(targetAx, 'off');
    end
    
    % --- 将后三张图 (Experiment) 画成红色的点和线 ---
    if i >= 4
        allLines = findobj(targetAx, 'Type', 'line');
        if ~isempty(allLines)
            % 设置为红色线，红色圆圈，白色填充（空心圆效果）
            set(allLines, 'Color', 'r', 'Marker', 'o', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'w', 'LineStyle', '-');
        end
        % 如果原始图像使用了 scatter 函数而不是 plot，同步修改 scatter 属性
        allScatters = findobj(targetAx, 'Type', 'scatter');
        if ~isempty(allScatters)
            set(allScatters, 'MarkerEdgeColor', 'r', 'MarkerFaceColor', 'w');
        end
    end
    
    % --- 处理 xlabel ---
    % 第 1, 2, 3 张不显示 xlabel
    if i <= 3
        targetAx.XLabel.String = '';
    else
        targetAx.XLabel.String = ax.XLabel.String;
        targetAx.XLabel.FontSize = 14;
        if i == 5
            targetAx.XLabel.Interpreter = 'latex';
        end
    end
    
    % --- 处理 ylabel ---
    % 只有第一列 (i=1, 4) 保留 ylabel，其余不显示
    if ismember(i, [2, 3, 5, 6])
        targetAx.YLabel.String = '';
    else
        targetAx.YLabel.String = ax.YLabel.String;
        targetAx.YLabel.FontSize = 14;
    end
    
    % --- 添加 (a)-(f) 标识 ---
    text(targetAx, 0.02, 0.95, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'VerticalAlignment', 'top');
    
    % --- 恢复第一排的图例 ---
    if i <= 3
        oldLegend = findobj(tempFig, 'Type', 'Legend');        
        if ~isempty(oldLegend)               
            newLeg = legend(targetAx, oldLegend.String, 'Interpreter', 'latex');
            newLeg.FontSize = 12;
        end
    end
    
    close(tempFig);
end

% 导出前强制刷新
drawnow;
% exportgraphics(mainFig, 'fig1.pdf', 'ContentType', 'vector');