close all
% 1. 定义文件名（顺序：1-3为第一行，4-6为第二行，7-9为第三行）
fileNames = {'fig2simpow.fig', 'fig2exppow.fig', 'fig40.001pow.fig', ...
             'fig2simlin.fig', 'fig2explin.fig', 'fig40.001lin.fig', ...
             'fig2simexp.fig', 'fig2expexp.fig', 'fig40.001exp.fig'};
             
% 对应的标签，按行优先顺序排列
labels = {'(a)', '(d)', '(g)', ...
          '(b)', '(e)', '(h)', ...
          '(c)', '(f)', '(i)'};

mainFig = figure('Color', 'w', 'Position', [100, 100, 1200, 800]); % 宽屏布局
t = tiledlayout(25, 3, 'TileSpacing', 'compact', 'Padding', 'compact'); 

savedLegends = cell(30, 1); 

for i = 1:length(fileNames)
    % 打开子图（隐藏模式）
    tempFig = openfig(fileNames{i}, 'invisible');
    ax = findobj(tempFig, 'Type', 'axes');
    
    % 计算在 3 列网格下的行起点和列
    rowStart = 2 + floor((i-1)/3) * 8; 
    col = mod(i-1, 3) + 1;
    tileIndex = (rowStart-1)*3 + col;
    
    targetAx = nexttile(t, tileIndex, [8, 1]);
    
    % 拷贝曲线内容
    copyobj(ax.Children, targetAx);
    
    % --- 属性同步 ---
    targetAx.XLim = ax.XLim;
    targetAx.YLim = ax.YLim;
    
    % --- 调整特定子图的 Y 轴上限 ---
    if strcmp(labels{i}, '(a)')
        targetAx.YLim(2) = 7e-3;
    elseif strcmp(labels{i}, '(g)')
        targetAx.YLim(2) = 2.4e-3;
    elseif strcmp(labels{i}, '(h)')
        targetAx.YLim(2) = -3.5;
    end
    
    targetAx.Box = 'on';
    targetAx.Title.String = ''; % 隐藏原图名
    
    % --- 标签处理 ---
    targetAx.XLabel.String = ax.XLabel.String;
    targetAx.YLabel.String = ax.YLabel.String;
    
    % 修改特定的 X 轴标签
    if strcmp(labels{i}, '(h)')
        targetAx.XLabel.String = '$\Delta t$ (log)';
    end
    
    % 第二行图片 (b, e, h) 的 X轴标签使用 latex
    if ismember(labels{i}, {'(b)', '(e)', '(h)'})
        set(targetAx.XLabel, 'Interpreter', 'latex', 'FontSize', 14);
    else
        set(targetAx.XLabel, 'Interpreter', 'tex', 'FontSize', 14);
    end
    
    % Y轴标签逻辑（只有第一列保留 YLabel，其他列隐藏）
    if col == 1 
        if strcmp(labels{i}, '(c)')
            ylabel(targetAx, ax.YLabel.String, 'Interpreter', 'tex', 'FontSize', 14);
        elseif ismember(labels{i}, {'(a)'})
            ylabel(targetAx, 'MSD', 'Interpreter', 'tex', 'FontSize', 14); 
        elseif ismember(labels{i}, {'(b)'})
            ylabel(targetAx, 'log(MSD)', 'Interpreter', 'tex', 'FontSize', 14); 
        end
    else
        ylabel(targetAx, ''); % 隐藏第 2、3 列的 ylabel
    end
    
    % ==========================================
    % --- 【修改区】：线宽设置逻辑 ---
    % c, f, i (即第三行) 设为 1.5，其余子图设为 1.0
    % ==========================================
    allLines = findobj(targetAx, 'Type', 'line');
    if ismember(labels{i}, {'(c)', '(f)', '(i)'})
        set(allLines, 'LineWidth', 1.5);
    else
        set(allLines, 'LineWidth', 1.0);
    end
    
    if strcmp(labels{i}, '(i)')
        dashedLines = findobj(targetAx, 'Type', 'line', 'LineStyle', '--');
        if ~isempty(dashedLines)
            set(dashedLines, 'Color', 'k'); 
        end
    end
    
    % ==========================================
    % --- 图例处理逻辑 ---
    % ==========================================
    oldLegend = findobj(tempFig, 'Type', 'Legend');
    
    if col == 1
        if ~isempty(oldLegend)
            savedLegends{rowStart} = oldLegend.String;
        end
    end
    
    if ismember(i, [1,2,3,4,5,6])
        currentLegStr = {};
        
        if col == 1 || col == 2
            if ~isempty(oldLegend)
                currentLegStr = oldLegend.String;
            end
        elseif col == 3
            if ~isempty(savedLegends{rowStart})
                currentLegStr = savedLegends{rowStart};
            end
        end
        
        if ~isempty(currentLegStr)
            numItems = length(currentLegStr);
            cols = ceil(numItems / 2); % 保持两行排版
            newLeg = legend(targetAx, currentLegStr, 'Interpreter', 'latex', ...
                'Location', 'best', 'NumColumns', cols);
            newLeg.FontSize = 10;
        end
    end
    % ==========================================
    
    % 左上角子图编号标签
    text(targetAx, 0.02, 0.98, labels{i}, ...
        'Units', 'normalized', ...
        'FontSize', 14, ...
        'VerticalAlignment', 'top');
    close(tempFig);
end

% --- 动态添加三列的顶部标题 ---
drawnow; 
ax1 = nexttile(t, 4);
ax2 = nexttile(t, 5);
ax3 = nexttile(t, 6);

pos1 = ax1.Position;
pos2 = ax2.Position;
pos3 = ax3.Position;

annotation('textbox', [pos1(1), 0.94, pos1(3), 0.04], ... 
    'String', 'Null model', ...
    'FontSize', 16, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

annotation('textbox', [pos2(1), 0.94, pos2(3), 0.04], ... 
    'String', 'Experiment', ...
    'FontSize', 16, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');

annotation('textbox', [pos3(1), 0.94, pos3(3), 0.04], ... 
    'String', 'Viscoelastic model', ...
    'FontSize', 16, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'middle');