function [energy, umax] = top_comp(vfc_fiber, E_fiber, E_mx, mu_fiber, mu_mx, angle, force, generic_filename)
    [~, ~, ~] = mkdir('apdl_const');
    [~, ~, ~] = mkdir('maps_const');
    [~, ~, ~] = mkdir('pics_const');
    [~, ~, ~] = mkdir('gifs_const');

    % Load Settings
    st_global = settings;
    st_solver = st_global.topOptSettings.solver_settings;
    st_constr = st_global.topOptSettings.construction_properties;
    st_mater = st_global.topOptSettings.material_properties;
    st_draw = st_global.topOptSettings.drawer_properties;
    
    % Init vals
    size_x = str2double(st_constr.size_x.ActiveValue);
    size_y = str2double(st_constr.size_y.ActiveValue);
    zero_dens_x = str2double(st_constr.zero_dens_x.ActiveValue);
    zero_dens_y = str2double(st_constr.zero_dens_y.ActiveValue);
    sym_laying = str2num(st_constr.sym_laying.ActiveValue);

    nel_x = str2num(st_solver.nel_x.ActiveValue);
    nel_y = str2num(st_solver.nel_y.ActiveValue);
    rmin_size = str2double(st_solver.r_min.ActiveValue);
    penal = str2double(st_solver.penalty_degree.ActiveValue);
    volfrac = str2double(st_solver.volfrac.ActiveValue);
    max_change = str2double(st_solver.max_change.ActiveValue);
    max_loop = str2double(st_solver.max_loop.ActiveValue);

    scale = str2double(st_draw.scale.ActiveValue);
    fea_plot_size_x = str2double(st_draw.fea_plot_size_x.ActiveValue);
    vft = str2double(st_draw.activation_threshold.ActiveValue);
    save_plots = str2num(st_draw.save_plots.ActiveValue);

    if(~sym_laying)
        nel_x = nel_x * 2;
        size_x = size_x * 2;
        fea_plot_size_x = fea_plot_size_x * 2;
    end

    x(1:nel_y,1:nel_x) = volfrac; 
    loop = 0; 
    change = 1.;
    
    % Setting area of zero density
    if(sym_laying)
        el_size = size_y / nel_y;
        rmin = rmin_size / el_size;
        zero_nel_x = round( (size_x - zero_dens_x) / el_size );
        zero_nel_y = round( (size_y - zero_dens_y) / el_size );
        passive(1:nel_y, 1:nel_x) = 0;
        for ely = zero_nel_y:nel_y
            for elx = zero_nel_x:nel_x
                passive(ely,elx) = 1;
                x(ely,elx) = 0.001;
            end
        end
    else
        el_size = size_y / nel_y;
        rmin = rmin_size / el_size;
        zero_nel_x = round( (size_x - zero_dens_x) / el_size );
        zero_nel_y = round( (size_y - zero_dens_y) / el_size );
        passive(1:nel_y, 1:nel_x) = 0;
        for ely = zero_nel_y:nel_y
            for elx = zero_nel_x:nel_x
                passive(ely,elx) = 1;
                x(ely,elx) = 0.001;
            end
        end
        ely = 0;

        for ely = zero_nel_y:nel_y
            for elx = 1:round(zero_dens_x / el_size )
                passive(ely,elx) = 1;
                x(ely,elx) = 0.001;
            end
        end
    end
    

    % Stiffness matrix
    [KE] = lk(size_x / nel_x, size_y / nel_y, ...
              angle, vfc_fiber, E_fiber, E_mx, ...
              mu_fiber, mu_mx);
    first = 0;
    % Iteration
    while (change > max_change) && (loop < max_loop)
        loop = loop + 1;
        xold = x;
        % Get displacement
        [U,fixed_dofs]=FE(nel_x,nel_y,x,penal,KE,force);         
        % OBJECTIVE FUNCTION AND SENSITIVITY ANALYSIS
        c = 0.;
        for ely = 1:nel_y
            for elx = 1:nel_x
                n1 = (nel_y+1)*(elx-1)+ely; 
                n2 = (nel_y+1)* elx   +ely;
                Ue = U([2*n1-1;2*n1; 2*n2-1;2*n2; 2*n2+1;2*n2+2; 2*n1+1;2*n1+2],1);
                c = c + x(ely,elx)^penal*Ue'*KE*Ue;
                dc(ely,elx) = -penal*x(ely,elx)^(penal-1)*Ue'*KE*Ue;
            end
        end
        % FILTERING OF SENSITIVITIES
        [dc]   = check(nel_x,nel_y,rmin,x,dc);    
        % DESIGN UPDATE BY THE OPTIMALITY CRITERIA METHOD
        [x]    = OC(nel_x,nel_y,x,volfrac,dc,passive); 
        % PRINT RESULTS
        change = max(max(abs(x-xold)));
        disp([' It.: ' sprintf('%4i',loop) ' Obj.: ' sprintf('%10.4f',c) ...
              ' Vol.: ' sprintf('%6.3f',sum(sum(x))/(nel_x*nel_y)) ...
              ' ch.: ' sprintf('%6.3f',change )])
        % PLOT DENSITIES 
        if(save_plots)
            colormap(gray); imagesc(-x); axis equal; axis tight; axis off;pause(1e-6);
            if first == 0
                gif(convertStringsToChars("gifs_const\\GIF_"+generic_filename+".gif")); 
            else
                gif;
            end
            first = 1;
        end
    end
    energy = c;
    % Get max displacement
    u_full(1:size(U, 1)/2)=0;
    for i = 1:size(U, 1)/2
        u_full(i) = sqrt(U(2*i - 1, 1)^2 + U(2*i, 1)^2);
    end
    umax = max(u_full)
    % Save img
    if(save_plots)
        colormap(gray);
        imFinal = 1-x;
        imFinal = imresize(imFinal, scale, 'nearest');
        imwrite(imFinal, 'pics_const\\TOP_'+generic_filename+'.png',"png");
        axis equal; axis tight; axis off;
        % Save APDL file
        [E1, E2, mu12, mu21, g12] = composite_const(E_fiber, E_mx, mu_fiber, mu_mx, vfc_fiber);
        %fixed_dofs = union([1:2:2*(nel_y+1)],[2*(nel_x+1)*(nel_y+1)]);
        plane_save_apdl(E1, E2, mu12, mu21, mu12, g12, g12, size_x/nel_x, size_y/nel_y, ...
                        1, nel_x, nel_y, force, fixed_dofs, x, angle, vft, ...
                        'apdl_const\\APDL_'+generic_filename+'.ans')
        d_mx = plain_d_matrix(E1, E2, mu12, mu21, g12, angle);
        fea_maps(nel_x, nel_y, U, el_size, el_size, d_mx, x, fea_plot_size_x/nel_x,...
                 vft, '_MAP_'+generic_filename+'.png')
    close all
    end
end

%%%%%%%%%% OPTIMALITY CRITERIA UPDATE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xnew]=OC(nelx,nely,x,volfrac,dc,passive)  
    l1 = 0; l2 = 100000; move = 0.2;
    while (l2-l1 > 1e-4)
      lmid = 0.5*(l2+l1);
      xnew = max(0.001,max(x-move,min(1.,min(x+move,x.*sqrt(-dc./lmid)))));
      xnew(find(passive)) = 0.001;
      if sum(sum(xnew)) - volfrac*nelx*nely > 0
        l1 = lmid;
      else
        l2 = lmid;
      end
    end
end

%%%%%%%%%% MESH-INDEPENDENCY FILTER %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dcn]=check(nelx,nely,rmin,x,dc)
    dcn=zeros(nely,nelx);
    for i = 1:nelx
      for j = 1:nely
        sum=0.0; 
        for k = max(i-floor(rmin),1):min(i+floor(rmin),nelx)
          for l = max(j-floor(rmin),1):min(j+floor(rmin),nely)
            fac = rmin-sqrt((i-k)^2+(j-l)^2);
            sum = sum+max(0,fac);
            dcn(j,i) = dcn(j,i) + max(0,fac)*x(l,k)*dc(l,k);
          end
        end
        dcn(j,i) = dcn(j,i)/(x(j,i)*sum);
      end
    end
end

%%%%%%%%%% FE-ANALYSIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [U, fixeddofs]=FE(nelx,nely,x,penal,KE,force)
    %[KE] = lk; 
    K = sparse(2*(nelx+1)*(nely+1), 2*(nelx+1)*(nely+1));
    F = sparse(2*(nely+1)*(nelx+1),1); U = zeros(2*(nely+1)*(nelx+1),1);
    for elx = 1:nelx
      for ely = 1:nely
        n1 = (nely+1)*(elx-1)+ely; 
        n2 = (nely+1)* elx   +ely;
        edof = [2*n1-1; 2*n1; 2*n2-1; 2*n2; 2*n2+1; 2*n2+2; 2*n1+1; 2*n1+2];
        K(edof,edof) = K(edof,edof) + x(ely,elx)^penal*KE;
      end
    end
    % DEFINE LOADS AND SUPPORTS (HALF MBB-BEAM)
    st_global = settings;
    st_constr = st_global.topOptSettings.construction_properties;
    sym_laying = str2num(st_constr.sym_laying.ActiveValue);
    if(sym_laying)
        F(2,1) = force;
        fixeddofs   = union([1:2:2*(nely+1)],[2*(nelx+1)*(nely+1)-nely]);
    else
        F((nelx+1)*(nely+1)+1,1)=force;
        fixeddofs = union([2*(0+1)*(nely+1)-nely],[2*(nelx+1)*(nely+1)-nely]);
    end
    alldofs     = [1:2*(nely+1)*(nelx+1)];
    freedofs    = setdiff(alldofs,fixeddofs);
    % SOLVING
    U(freedofs,:) = K(freedofs,freedofs) \ F(freedofs,:);      
    U(fixeddofs,:)= 0;
end

%%%%%%%%%% ELEMENT STIFFNESS MATRIX %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [KE]=lk(size_x_e, size_y_e, angle, vfc, E_fiber, E_mx, mu_fiber, mu_mx)
    [E1, E2, mu12, mu21, g12] = composite_const(E_fiber, E_mx, mu_fiber, mu_mx, vfc);
    d_matrix = plain_d_matrix(E1, E2, mu12, mu21, g12, angle );
    KE = matrix_k_quad_elem(size_x_e, size_y_e, d_matrix);
    writematrix(KE, "new_matrix.txt")
end
