function fea_maps(nelx, nely, U, x_size, y_size, d_mx, active_passive, plot_el_size, vft, filename)
    us_func = @(u_local) [sqrt(u_local(1)^2+u_local(2)^2), sqrt(u_local(3)^2+u_local(4)^2), sqrt(u_local(5)^2+u_local(6)^2), sqrt(u_local(7)^2+u_local(8)^2)];
    plot_map("U_{sum}", nelx, nely, U, us_func, x_size, y_size, active_passive, 1, plot_el_size, vft, 'u_s_'+filename);

    ux_func = @(u_local) [u_local(1), u_local(3), u_local(5), u_local(7)];
    plot_map("U_{x}", nelx, nely, U, ux_func, x_size, y_size, active_passive, 1, plot_el_size, vft, 'u_x_'+filename);

    uy_func = @(u_local) [u_local(2), u_local(4), u_local(6), u_local(8)];
    plot_map("U_{y}", nelx, nely, U, uy_func, x_size, y_size, active_passive, 1, plot_el_size, vft, 'u_y_'+filename);

    b_mx = matrix_b(x_size, y_size); % !!! might broke for non-regular mesh
    
    s_m_func = s_mises_closure(d_mx, b_mx);
    plot_map("S_{mizes}", nelx, nely, U, s_m_func, x_size, y_size, active_passive, 1, plot_el_size, vft, 's_m_'+filename);
    
    sx_func = s_x_func_closure(d_mx, b_mx);
    sy_func = s_y_func_closure(d_mx, b_mx);
    sxy_func = s_xy_func_closure(d_mx, b_mx);

    plot_map("S_{x}", nelx, nely, U, sx_func, x_size, y_size, active_passive, 1, plot_el_size, vft, 's_x_'+filename);
    plot_map("S_{y}", nelx, nely, U, sy_func, x_size, y_size, active_passive, 1, plot_el_size, vft, 's_y_'+filename);
    plot_map("S_{xy}", nelx, nely, U, sxy_func, x_size, y_size, active_passive, 1, plot_el_size, vft, 'sxy_'+filename);
end

function s_full = s_full_func_closure(d_mx, b_mx)
    syms xx yy
    s_cord = @(u_local, x_local, y_local) double(subs(d_mx * b_mx * u_local, {xx, yy}, {x_local,y_local} ));
    s_full = @(u_local) table([s_cord(u_local, -1, 1), s_cord(u_local, 1, 1),...
                               s_cord(u_local, 1, -1), s_cord(u_local, -1, -1)]);
end
% TODO: von mises stresses
% sqrt(s11^2 + s22^2 - s11 s22 + 3 s12^2)
function s_m = s_mises_closure(d_mx, b_mx)
    s_full = s_full_func_closure(d_mx, b_mx);
    s_m = @(u_local)sqrt([s_full(u_local).Var1(1,:).^2+...
                          s_full(u_local).Var1(2,:).^2-...
                          s_full(u_local).Var1(1,:).*s_full(u_local).Var1(2,:)+...
                          3*s_full(u_local).Var1(3,:).^2]);
end
function s_x_func = s_x_func_closure(d_mx, b_mx)
    s_full = s_full_func_closure(d_mx, b_mx);
    s_x_func = @(u_local) [s_full(u_local).Var1(1,:)];
end

function s_y_func = s_y_func_closure(d_mx, b_mx)
    s_full = s_full_func_closure(d_mx, b_mx);
    s_y_func = @(u_local) [s_full(u_local).Var1(2,:)];
end

function s_xy_func = s_xy_func_closure(d_mx, b_mx)
    s_full = s_full_func_closure(d_mx, b_mx);
    s_xy_func = @(u_local) [s_full(u_local).Var1(3,:)];
end

function plot_map(val_name, nelx, nely, U, map_function, x_size, y_size, active_passive, num, plot_el_size, vft, filename)
% U -- map of translations
% map_function -- function that maps 8x1 to 4x1 vec
% active_passive -- no. of elements to be shown
    figure('Renderer', 'painters', 'Position', [10 10 nelx*plot_el_size nely*plot_el_size]);
    clf;
    annotation('textbox', [0, 1, 0, 0], 'string', val_name);
    hx=x_size;
    hy=y_size;

    minval=1e6;
    maxval=-1e6;
    for i = 1:nelx
        x = (i-1)*hx;
        for j = 1:nely
            y = nely*hy - (j-1)*hy;
            if active_passive(j,i) > vft
                vertx = [x; x+hx; x+hx; x];
                verty = [y; y; y-hy; y-hy];
                n1 = (nely+1)*(i-1)+j; 
                n2 = (nely+1)* i   +j;
                u_local = U( [2*n1-1;2*n1; 2*n2-1;2*n2; 2*n2+1;2*n2+2; 2*n1+1;2*n1+2], 1 );
                color = map_function( u_local );
                patch(vertx,verty,color);
                if min(color) < minval
                    minval = min(color);
                end
                if max(color) > maxval
                    maxval = max(color);
                end            
                hold on;
            end
        end
    end
    colormap(jet(32));
    colorbar;
    caxis([minval maxval]);

    fchnm=convertStringsToChars(filename);
    file_id = fopen("maps_const\\MaxMin_"+fchnm(6:end-4)+".txt", "A");
    fprintf(file_id,'%s: [%f,%f]\n', val_name, minval, maxval);
    fclose(file_id);

    f=gcf;
    exportgraphics(f,"maps_const\\"+filename,'Resolution',300)
end