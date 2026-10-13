% =========================================================================
%  MATLAB 脚本：合并 1张(1行2列) + 2张(1行1列) 的 .fig 文件，拼成 2行2列
%  （清空所有子图标题，添加 (a)-(d) 标号，c 图 Y 轴设为 MSD，Legend 设为 2 列，
%   并且统一所有子图的 Label、坐标轴刻度及前两图 CV 文本的字号与 c 图 xlabel 对齐）
% =========================================================================
clear; clc; close all;
% 1. 填入你的 .fig 文件路径
fig_1x2 = 'fig13sta.fig';  % 包含 (a) 和 (b) 的 1x2 图
fig_c   = 'fig13pow.fig';        % 第 3 张图 (1x1，将标为 c)
fig_d   = 'fig13exp.fig';        % 第 4 张图 (1x1，将标为 d)
labels = {'(a)', '(b)', '(c)', '(d)'};
ax_all = cell(1, 4); % 存储 4 个子图的句柄，方便后续统一修改字号
target_fontsize = 12; % 默认备用字号
% 2. 创建总画布 (2 行 2 列)
main_fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 100, 900, 750]);
t = tiledlayout(2, 2, 'Padding', 'compact', 'TileSpacing', 'compact');
% -------------------------------------------------------------------------
% 处理第 1 个文件：1x2 图（拆分为 Tile 1 和 Tile 2）
% -------------------------------------------------------------------------
if exist(fig_1x2, 'file')
    temp_fig = openfig(fig_1x2, 'invisible');
    axes_list = findobj(temp_fig, 'Type', 'axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
    
    % 按 X 位置自左向右排序，确保先左后右
    x_pos = arrayfun(@(ax) ax.Position(1), axes_list);
    [~, sort_idx] = sort(x_pos, 'ascend');
    axes_list = axes_list(sort_idx);
    
    for j = 1:min(2, length(axes_list))
        ax_target = copyobj(axes_list(j), t);
        ax_target.Layout.Tile = j; % 放到第 1 和 第 2 个 Tile
        ax_all{j} = ax_target;     % 保存句柄
        
        title(ax_target, ''); % 【清空标题】
        clean_old_labels(ax_target); % 清除原图可能残留的单字母标号
        
        % 添加 (a) / (b) 标号
        text(ax_target, 0.04, 0.94, labels{j}, 'Units', 'normalized', ...
             'FontSize', 14, 'FontName', 'Arial');
    end
    close(temp_fig);
else
    warning('未找到文件: %s', fig_1x2);
end
% -------------------------------------------------------------------------
% 处理第 2 个文件：1x1 图（对应 c 图，Tile 3）
% -------------------------------------------------------------------------
if exist(fig_c, 'file')
    temp_fig = openfig(fig_c, 'invisible');
    axes_list = findobj(temp_fig, 'Type', 'axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
    
    if ~isempty(axes_list)
        % 在关闭 temp_fig 之前读取原图的 legend 对象
        leg_orig = findobj(temp_fig, 'Type', 'legend');
        
        ax_target = copyobj(axes_list(1), t);
        ax_target.Layout.Tile = 3; % 放到第 3 个 Tile
        ax_all{3} = ax_target;     % 保存句柄
        
        % 【关键】：自动获取 c 图原本 xlabel 的 FontSize 作为基准
        if ~isempty(ax_target.XLabel.FontSize) && ax_target.XLabel.FontSize > 0
            target_fontsize = ax_target.XLabel.FontSize;
        end
        
        title(ax_target, ''); % 【清空标题】
        clean_old_labels(ax_target);
        
        % 将 c 图的 ylabel 设置为 TeX 格式的 MSD
        ylabel(ax_target, 'MSD', 'Interpreter', 'tex');
        
        % 【将 c 图的 Legend 设为 2 列显示】
        if ~isempty(leg_orig)
            legend(ax_target, leg_orig.String, ...
                   'Location', leg_orig.Location, ...
                   'Interpreter', leg_orig.Interpreter, ...
                   'FontSize', 14, ...
                   'NumColumns', 2);
        end
        
        % 添加 (c) 标号
        text(ax_target, 0.04, 0.94, labels{3}, 'Units', 'normalized', ...
             'FontSize', 14, 'FontName', 'Arial');
    end
    close(temp_fig);
else
    warning('未找到文件: %s', fig_c);
end
% -------------------------------------------------------------------------
% 处理第 3 个文件：1x1 图（对应 d 图，Tile 4）
% -------------------------------------------------------------------------
if exist(fig_d, 'file')
    temp_fig = openfig(fig_d, 'invisible');
    axes_list = findobj(temp_fig, 'Type', 'axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
    if ~isempty(axes_list)
        ax_target = copyobj(axes_list(1), t);
        ax_target.Layout.Tile = 4; % 放到第 4 个 Tile
        ax_all{4} = ax_target;     % 保存句柄
        
        title(ax_target, ''); % 【清空标题】
        clean_old_labels(ax_target);
        
        % 将 d 图的所有线条线宽设为 1.5
        all_lines_d = findobj(ax_target, 'Type', 'line');
        if ~isempty(all_lines_d)
            set(all_lines_d, 'LineWidth', 1.5);
        end
        
        % 添加 (d) 标号
        text(ax_target, 0.04, 0.94, labels{4}, 'Units', 'normalized', ...
             'FontSize', 14, 'FontName', 'Arial');
    end
    close(temp_fig);
else
    warning('未找到文件: %s', fig_d);
end
% -------------------------------------------------------------------------
% 【核心修改】：统一所有子图的 坐标轴刻度字体 + XLabel + YLabel + CV标注 的 FontSize
% -------------------------------------------------------------------------
for k = 1:4
    if ~isempty(ax_all{k})
        ax_all{k}.FontSize = target_fontsize;       % 坐标轴刻度数字字体大小
        ax_all{k}.XLabel.FontSize = 16;             % X轴标签字体大小
        ax_all{k}.YLabel.FontSize = 16;             % Y轴标签字体大小
        
        % 自动检索并放大包含 "CV" 的文本标注
        txt_objs = findobj(ax_all{k}, 'Type', 'text');
        for m = 1:length(txt_objs)
            if contains(string(txt_objs(m).String), 'CV')
                txt_objs(m).FontSize = 14;
            end
        end
    end
end
% 3. 前置显示画布
figure(main_fig);
% =========================================================================
% 辅助函数：自动清理坐标轴中原有的 (a)-(z) 类旧文本标签
% =========================================================================
function clean_old_labels(ax)
    old_texts = findobj(ax, 'Type', 'text');
    for m = 1:length(old_texts)
        txt_str = strtrim(string(old_texts(m).String));
        if ~isempty(regexpi(txt_str, '^\(?[a-z]\)?$'))
            delete(old_texts(m));
        end
    end
end