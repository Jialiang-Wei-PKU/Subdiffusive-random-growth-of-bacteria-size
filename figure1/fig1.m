close all
% 1. 定义 4 张图的文件名列表
fileNames = {'fig1exp.fig', 'fig1sim.fig', 'fig1expsta.fig', 'fig1simsta.fig'};

% 2. 创建主画布（因为有左右并排的子图，宽度调大到 850，高度 1200 保持修长）
mainFig = figure('Color', 'w', 'Position', [100, 100, 850, 1200]);

% 3. 创建 4行2列 的排版布局
t = tiledlayout(4, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% 全局子图字母标签计数器 (a, b, c, d...)
label_idx = 1;
labels = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)', '(g)', '(h)', '(i)'};

% 【新增】：创建一个细胞数组，用来安全地保存所有子图的句柄，防止后续调用报错
allAxes = cell(1, 8); 

% 4. 循环遍历提取并排版
for i = 1:length(fileNames)
    % 打开对应的子图（后台不可见模式）
    tempFig = openfig(fileNames{i}, 'invisible');
    
    % 精准抓取该 .fig 文件中的所有主绘图坐标轴
    axList = findobj(tempFig, 'Type', 'axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
    
    % 将倒序的数组翻转，确保子图严格按照"从左到右"的原始顺序排列
    axList = flipud(axList); 
    numAxes = length(axList); % 获取当前 .fig 文件里到底有几个子图
    
    if numAxes == 2
        % 如果是双子图，分别放入当前行的第 1 和第 2 格
        for k = 1:2
            ax = axList(k);
            ax.Parent = t; 
            
            tileNum = (i-1)*2 + k; % 自动计算对应的格子编号
            ax.Layout.Tile = tileNum; 
            
            % 【关键新增】：保存当前坐标轴到对应位置
            allAxes{tileNum} = ax; 
            
            % 统一属性定制
            customize_axes(ax, labels{label_idx});
            label_idx = label_idx + 1;
        end
        
    elseif numAxes == 1
        % 如果是单张图，让它横跨两列，占满当前整行
        ax = axList(1);
        ax.Parent = t;
        
        tileNum = (i-1)*2 + 1;
        ax.Layout.Tile = tileNum;
        ax.Layout.TileSpan = [1, 2]; % 横跨 1 行，2 列
        
        % 【关键新增】：保存当前坐标轴到对应位置
        allAxes{tileNum} = ax; 
        
        % 统一属性定制
        customize_axes(ax, labels{label_idx});
        label_idx = label_idx + 1;
    end
    
    % 关闭临时空壳图
    close(tempFig);
end

% ========================================================
% --- 【新增】：动态获取坐标并添加顶部文字说明 ---
% ========================================================
drawnow; % 强制渲染图形，以便获取准确的 Position 数据

% --- 第一行 (fig1exp.fig) 顶部添加 Experiment ---
ax1 = allAxes{1};
ax2 = allAxes{2};

% 增加防空保护：判断第一行是单图还是双图
if isempty(ax2)
    width1 = ax1.Position(3); % 单图横跨的情况，直接用 ax1 的宽度
else
    width1 = (ax2.Position(1) + ax2.Position(3)) - ax1.Position(1); % 双图的情况
end

annotation('textbox', [ax1.Position(1), ax1.Position(2) + ax1.Position(4), width1, 0.04], ... 
    'String', 'Experiment', ...
    'FontSize', 16, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom');

% --- 第二行 (fig1sim.fig) 顶部添加 Simulation ---
ax3 = allAxes{3};
ax4 = allAxes{4};

% 同样的防空保护：判断第二行是单图还是双图
if isempty(ax4)
    width2 = ax3.Position(3);
else
    width2 = (ax4.Position(1) + ax4.Position(3)) - ax3.Position(1);
end

annotation('textbox', [ax3.Position(1), ax3.Position(2) + ax3.Position(4), width2, 0.04], ... 
    'String', 'Simulation', ...
    'FontSize', 16, ...
    'EdgeColor', 'none', ...
    'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom');
% ========================================================


%% 🛠️ 统一调整坐标轴格式的辅助函数
function customize_axes(ax, labelStr)
    
    % 解除原图尺寸锁定，强制坐标轴铺满网格
    ax.PositionMode = 'auto';
    ax.PlotBoxAspectRatioMode = 'auto';
    ax.DataAspectRatioMode = 'auto';
    
    % 常规美化
    ax.Box = 'on';          % 加上四周边框
    ax.Title.String = '';   % 清空原有图名
    
    % 放大坐标轴标签字体，并将默认解释器设置为 tex
    ax.XLabel.FontSize = 13;
    ax.XLabel.Interpreter = 'tex'; 
    ax.YLabel.FontSize = 13;
    ax.YLabel.Interpreter = 'tex';
    
    % 除 e 和 f 的 xlabel 外都用 tex（即 e 和 f 保留 latex）
    if strcmp(labelStr, '(e)') || strcmp(labelStr, '(f)')
        ax.XLabel.Interpreter = 'latex'; 
    end
    
    % 去掉 (a), (c) 和 (d) 的 X 轴标签
    if strcmp(labelStr, '(a)') || strcmp(labelStr, '(c)') || strcmp(labelStr, '(d)')
        ax.XLabel.String = '';
        ax.XTickLabel = []; % 同时建议清空数字刻度标签，让纵向排列更紧凑美观
    end
    
    % 原有修改：去掉 (d) 和 (f) 的 Y 轴标签
    if strcmp(labelStr, '(d)') || strcmp(labelStr, '(f)')
        ax.YLabel.String = '';
    end
    
    % 恢复并美化原本的图例（如果有的话）
    oldLegend = findobj(ax.Parent, 'Type', 'Legend');        
    if ~isempty(oldLegend)               
        oldLegend.Interpreter = 'tex'; % 为了保持整体画风一致，图例也统一改成了 tex
        oldLegend.FontSize = 10;
    end
    
    % 重新在各个子图左上角打上标准的标签
    text(ax, 0.02, 0.95, labelStr, ...
        'Units', 'normalized', ...
        'FontSize', 15, ...
        'VerticalAlignment', 'top');
end