% =========================================================================
%  MATLAB 脚本：合并 3 个 (1行2列) 的 .fig 文件，拼成 3行2列并直接显示
%  （只保留第一行标题，删除第二、三行标题及旧标号）
% =========================================================================
clear; clc; close all;

% 1. 填入你的 3 个 .fig 文件路径（从上到下对应第1行、第2行、第3行）
fig_files = {
    'fig1expsta.fig';   % 包含第 1 行的 (a) 和 (b) -> 保留标题
    'fig1simsta.fig';   % 包含第 2 行的 (c) 和 (d) -> 删除标题
    'fig4simsta.fig'    % 包含第 3 行的 (e) 和 (f) -> 删除标题
};

labels = {'(a)', '(b)', '(c)', '(d)', '(e)', '(f)'};

% 2. 创建总画布 (3 行 2 列)
main_fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100, 50, 1000, 900]);
t = tiledlayout(3, 2, 'Padding', 'compact', 'TileSpacing', 'compact');

tile_count = 1; % 标号计数器 (1 到 6)

for k = 1:length(fig_files)
    if exist(fig_files{k}, 'file')
        % 后台打开 .fig 文件
        temp_fig = openfig(fig_files{k}, 'invisible');
        
        % 提取该 .fig 中的所有坐标轴（自动排除 legend 和 colorbar）
        axes_list = findobj(temp_fig, 'Type', 'axes', '-not', 'Tag', 'legend', '-not', 'Tag', 'Colorbar');
        
        % --- 过滤并按横向 (X) 位置从左到右排序，确保先左后右 ---
        x_positions = zeros(length(axes_list), 1);
        for m = 1:length(axes_list)
            pos = get(axes_list(m), 'Position');
            x_positions(m) = pos(1);
        end
        [~, sort_idx] = sort(x_positions, 'ascend'); 
        axes_list = axes_list(sort_idx); % 排序后：1 为左图，2 为右图
        % -------------------------------------------------------------
        
        % 依次处理左、右两张图
        for j = 1:min(2, length(axes_list))
            temp_ax = axes_list(j);
            
            % 直接把整个 axes 复制到 tiledlayout 对应的 Tile 中
            ax_target = copyobj(temp_ax, t);
            ax_target.Layout.Tile = tile_count;
            
            % --- 清理原图自带的旧标号（如 (c), (d), c, d 等）---
            old_texts = findobj(ax_target, 'Type', 'text');
            for m = 1:length(old_texts)
                txt_str = strtrim(string(old_texts(m).String));
                if ~isempty(regexpi(txt_str, '^\(?[a-z]\)?$')) || ...
                   contains(txt_str, '(c)') || contains(txt_str, '(d)')
                    delete(old_texts(m));
                end
            end
            
            % --- 【关键修改】：如果不是第 1 个文件（第 2、3 行），清空标题 ---
            if k > 1
                title(ax_target, '');
            end
            % ---------------------------------------------------------
            
            % 添加全新的 (a)-(f) 标号
            text(ax_target, 0.03, 0.92, labels{tile_count}, 'Units', 'normalized', ...
                 'FontSize', 14, 'FontName', 'Arial');
            
            tile_count = tile_count + 1;
        end
        
        close(temp_fig); % 关闭后台临时文件
    else
        warning('未找到文件: %s', fig_files{k});
    end
end

% 3. 直接将拼图窗口前置显示
figure(main_fig);