function KronigPenney_Final_Dashboard
    % Kronig-Penney Final Integrated Simulator
    % Combines:
    % 1. Interactive dashboard interface (Fig 1 & Fig 2)
    % 2. Clean 3D Fermi surface rendering (Fig 3 using Isosurface)
    
    clear; clc; close all;

    %% 1. Initialize parameters
    p_params.P = 10;           % Potential barrier strength
    p_params.Range = 4;        % Display range of the 1D plots (n*pi)
    p_params.Fill = 0.45;      % Fermi surface filling factor (0.02 - 0.98)
    
    % 3D grid settings (moderate resolution to keep interaction smooth)
    grid_N = 35;
    k_vec = linspace(-pi, pi, grid_N);
    [KX, KY, KZ] = meshgrid(k_vec, k_vec, k_vec);
    
    %% 2. Create figure window and layout
    hFig = figure('Name', 'Kronig-Penney Physics Simulator (Final Version)', ...
                  'Color', 'w', 'Position', [50, 50, 1200, 900], ...
                  'NumberTitle', 'off');

    % Top half: 1D analysis
    ax1 = subplot(2, 2, 1, 'Parent', hFig); % Top-left: graphical solution
    ax2 = subplot(2, 2, 2, 'Parent', hFig); % Top-right: E-k diagram
    
    % Bottom half: 3D analysis
    ax3 = subplot(2, 2, [3, 4], 'Parent', hFig); % Bottom: 3D Fermi surface

    % Adjust axes positions
    set(ax1, 'Position', [0.08, 0.58, 0.40, 0.35]); 
    set(ax2, 'Position', [0.56, 0.58, 0.40, 0.35]);
    set(ax3, 'Position', [0.20, 0.15, 0.60, 0.38]); % Bottom, centered

    %% 3. UI controls (bottom panel)
    
    % --- Control 1: P' (Barrier Strength) ---
    uicontrol('Style', 'text', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.05, 0.08, 0.25, 0.02], 'String', 'Barrier Strength (P'')', ...
              'FontWeight', 'bold', 'BackgroundColor', 'w', 'FontSize', 10);
    txt_P = uicontrol('Style', 'text', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.31, 0.08, 0.05, 0.02], 'String', num2str(p_params.P), ...
              'ForegroundColor', 'b', 'BackgroundColor', 'w', 'FontSize', 10);
    uicontrol('Style', 'slider', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.05, 0.05, 0.30, 0.03], ...
              'Min', 0.1, 'Max', 20, 'Value', p_params.P, ...
              'Callback', @update_P);

    % --- Control 2: Range (1D Zoom) ---
    uicontrol('Style', 'text', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.40, 0.08, 0.20, 0.02], 'String', '1D Plot Range (n*\pi)', ...
              'FontWeight', 'bold', 'BackgroundColor', 'w', 'FontSize', 10);
    txt_Range = uicontrol('Style', 'text', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.61, 0.08, 0.05, 0.02], 'String', [num2str(p_params.Range) '\pi'], ...
              'ForegroundColor', [0 0.5 0], 'BackgroundColor', 'w', 'FontSize', 10);
    uicontrol('Style', 'slider', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.40, 0.05, 0.25, 0.03], ...
              'Min', 1.5, 'Max', 6, 'Value', p_params.Range, ...
              'Callback', @update_Range);

    % --- Control 3: Fermi Level (3D Filling) ---
    uicontrol('Style', 'text', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.70, 0.08, 0.20, 0.02], 'String', 'Fermi Filling Factor', ...
              'FontWeight', 'bold', 'BackgroundColor', 'w', 'FontSize', 10);
    txt_Fill = uicontrol('Style', 'text', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.91, 0.08, 0.05, 0.02], 'String', num2str(p_params.Fill), ...
              'ForegroundColor', 'r', 'BackgroundColor', 'w', 'FontSize', 10);
    uicontrol('Style', 'slider', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.70, 0.05, 0.25, 0.03], ...
              'Min', 0.02, 'Max', 0.98, 'Value', p_params.Fill, ...
              'Callback', @update_Fill);
    
    % Footer caption
    uicontrol('Style', 'text', 'Parent', hFig, 'Units', 'normalized', ...
              'Position', [0.2, 0.01, 0.6, 0.03], ...
              'String', 'Top: 1D Kronig-Penney Analysis | Bottom: 3D Fermi Surface (Simple Cubic)', ...
              'ForegroundColor', [0.5 0.5 0.5], 'BackgroundColor', 'w');

    %% 4. Initial plot
    updateAllPlots();

    %% 5. Callbacks
    function update_P(src, ~)
        p_params.P = get(src, 'Value');
        set(txt_P, 'String', sprintf('%.1f', p_params.P));
        updateAllPlots();
    end

    function update_Range(src, ~)
        p_params.Range = get(src, 'Value');
        set(txt_Range, 'String', sprintf('%.1f\\pi', p_params.Range));
        plot1D_Graphical();
        plot1D_Ek();
    end

    function update_Fill(src, ~)
        p_params.Fill = get(src, 'Value');
        set(txt_Fill, 'String', sprintf('%.2f', p_params.Fill));
        plot3D_Fermi(); % Only the 3D plot needs to be updated
    end

    %% 6. Core plotting routines
    function updateAllPlots()
        plot1D_Graphical();
        plot1D_Ek();
        plot3D_Fermi();
    end

    % --- Plot 1: Graphical solution (Top Left) ---
    function plot1D_Graphical()
        cla(ax1); hold(ax1, 'on');
        resolution = 0.01;
        alpha_a = -p_params.Range*pi : resolution : p_params.Range*pi;
        
        term1 = p_params.P * sin(alpha_a) ./ alpha_a;
        term1(isnan(term1)) = p_params.P; 
        f_total = term1 + cos(alpha_a);
        
        % Shade the allowed bands (strictly where -1 <= f <= 1)
        in_band = false; start_x = 0;
        for i = 1:length(alpha_a)-1
            is_allowed = abs(f_total(i)) <= 1.0001;
            if is_allowed && ~in_band
                start_x = alpha_a(i); in_band = true;
            elseif ~is_allowed && in_band
                patch(ax1, [start_x alpha_a(i) alpha_a(i) start_x], [-1 -1 1 1], ...
                      [0.8 0.9 1], 'EdgeColor', 'none');
                in_band = false;
            end
        end
        if in_band
            patch(ax1, [start_x alpha_a(end) alpha_a(end) start_x], [-1 -1 1 1], ...
                  [0.8 0.9 1], 'EdgeColor', 'none');
        end
        
        plot(ax1, [min(alpha_a), max(alpha_a)], [1, 1], 'r--');
        plot(ax1, [min(alpha_a), max(alpha_a)], [-1, -1], 'r--');
        plot(ax1, alpha_a, f_total, 'b', 'LineWidth', 1.5);
        
        grid(ax1, 'on'); box(ax1, 'on');
        title(ax1, 'Fig 1: Graphical Solution', 'FontSize', 11);
        xlabel(ax1, '\alpha a'); ylabel(ax1, 'f(\alpha a)');
        ylim(ax1, [-3, max(4, p_params.P+2)]);
        xlim(ax1, [-p_params.Range*pi, p_params.Range*pi]);
        
        % X-Ticks
        ticks = -ceil(p_params.Range)*pi : pi : ceil(p_params.Range)*pi;
        set(ax1, 'XTick', ticks, 'XTickLabel', []); 
    end

    % --- Plot 2: E-k band diagram (Top Right) ---
    function plot1D_Ek()
        cla(ax2); hold(ax2, 'on');
        alpha_pos = 0 : 0.01 : p_params.Range*pi;
        f_pos = p_params.P * sin(alpha_pos) ./ alpha_pos + cos(alpha_pos);
        f_pos(1) = p_params.P + 1;
        
        k_all = []; E_all = [];
        
        for i = 1:length(alpha_pos)
            val = f_pos(i);
            if abs(val) <= 1.0001
                k_red = acos(val); if ~isreal(k_red), k_red=0; end
                n = ceil(alpha_pos(i)/pi); if n==0, n=1; end
                
                if mod(n, 2) == 1, k_fin = (n-1)*pi + k_red;
                else, k_fin = n*pi - k_red; end
                
                E_val = alpha_pos(i)^2;
                k_all = [k_all, k_fin, -k_fin]; %#ok<AGROW>
                E_all = [E_all, E_val, E_val]; %#ok<AGROW>
            end
        end
        
        plot(ax2, k_all, E_all, 'b.', 'MarkerSize', 2);
        
        % Labels
        text(ax2, 0, pi^2 + p_params.P, 'Forbidden', 'Color', 'r', 'HorizontalAlignment', 'center');
        text(ax2, pi/2, (pi/2)^2, 'Allowed', 'Color', 'b', 'HorizontalAlignment', 'center');
        
        grid(ax2, 'on'); box(ax2, 'on');
        title(ax2, 'Fig 2: E-k Diagram', 'FontSize', 11);
        xlabel(ax2, 'ka'); ylabel(ax2, 'E \propto (\alpha a)^2');
        xlim(ax2, [-p_params.Range*pi, p_params.Range*pi]);
        ylim(ax2, [0, (p_params.Range*pi)^2]);
    end

    % --- Plot 3: 3D Fermi surface (Bottom) - rendered with isosurface ---
    function plot3D_Fermi()
        cla(ax3); hold(ax3, 'on');
        
        % 1. Build the 1D lookup table (covers the first band)
        alpha_res = 0.01;
        alpha_lookup = 0 : alpha_res : 1.5*pi; % Wide enough to cover the first band
        f_lookup = p_params.P * sin(alpha_lookup)./alpha_lookup + cos(alpha_lookup);
        f_lookup(1) = p_params.P + 1;
        
        k_list = []; E_list = [];
        for i = 1:length(alpha_lookup)
            val = f_lookup(i);
            if abs(val) <= 1.0001
                k_c = acos(val); 
                if isreal(k_c) && k_c <= pi
                    k_list = [k_list, k_c]; %#ok<AGROW>
                    E_list = [E_list, alpha_lookup(i)^2]; %#ok<AGROW>
                end
            end
        end
        
        % Build the full (symmetric) lookup table
        [k_list, sI] = sort(k_list); E_list = E_list(sI);
        k_full = [-flip(k_list), k_list];
        E_full = [flip(E_list), E_list];
        [k_full, uI] = unique(k_full); E_full = E_full(uI);
        
        % 2. Compute the 3D energy field (separable: E = Ex + Ey + Ez)
        Ex = interp1(k_full, E_full, KX, 'linear', 'extrap');
        Ey = interp1(k_full, E_full, KY, 'linear', 'extrap');
        Ez = interp1(k_full, E_full, KZ, 'linear', 'extrap');
        E_vol = Ex + Ey + Ez;
        
        % 3. Draw the Fermi surface as an isosurface
        min_E = min(E_vol(:)); max_E = max(E_vol(:));
        E_Fermi = min_E + p_params.Fill * (max_E - min_E);
        
        fv = isosurface(KX, KY, KZ, E_vol, E_Fermi);
        p = patch(ax3, fv);
        
        % *** Key appearance settings ***
        set(p, 'FaceColor', [0.1 0.5 0.9], ... % Bright blue
               'EdgeColor', 'none', ...
               'FaceAlpha', 0.8);
        
        isonormals(KX, KY, KZ, E_vol, p);
        lighting(ax3, 'gouraud'); 
        camlight(ax3, 'headlight'); 
        camlight(ax3, 'right');
        material(ax3, 'dull');
        
        % Brillouin zone box (simple wireframe)
        L = pi;
        line(ax3, [-L L L -L -L], [-L -L L L -L], [-L -L -L -L -L], 'Color', 'k', 'LineStyle', '--');
        line(ax3, [-L L L -L -L], [-L -L L L -L], [L L L L L], 'Color', 'k', 'LineStyle', '--');
        for c = [-L, L], for d = [-L, L]
            line(ax3, [c c], [d d], [-L L], 'Color', 'k', 'LineStyle', '--');
        end, end

        title(ax3, ['Fig 3: 3D Fermi Surface (Filling = ' sprintf('%.2f', p_params.Fill) ')'], 'FontSize', 11);
        xlabel(ax3, 'kx a'); ylabel(ax3, 'ky a'); zlabel(ax3, 'kz a');
        axis(ax3, 'tight'); axis(ax3, 'equal');
        view(ax3, 3); rotate3d(ax3, 'on');
        
        xlim(ax3, [-pi pi]); ylim(ax3, [-pi pi]); zlim(ax3, [-pi pi]);
        ticks = [-pi 0 pi]; tLabs = {'-\pi','0','\pi'};
        set(ax3, 'XTick', ticks, 'XTickLabel', tLabs);
        set(ax3, 'YTick', ticks, 'YTickLabel', tLabs);
        set(ax3, 'ZTick', ticks, 'ZTickLabel', tLabs);
        grid(ax3, 'on');
    end
end
