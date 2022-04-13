function plot_diff_angles
    % Size of construction
    read_settings("settings.ini"); % init settings

    st_global = settings;
    st_mater = st_global.topOptSettings.material_properties;
    st_constr = st_global.topOptSettings.construction_properties;

    size_x = str2double(st_constr.size_x.ActiveValue);
    size_y = str2double(st_constr.size_y.ActiveValue);
    size_z = str2double(st_constr.size_z.ActiveValue);
    full_force = str2double(st_constr.full_force.ActiveValue);

    E_fiber = str2double(st_mater.e_fiber.ActiveValue);
    E_mx = str2double(st_mater.e_mx.ActiveValue);
    mu_fiber = str2double(st_mater.mu_fiber.ActiveValue);
    mu_mx = str2double(st_mater.mu_mx.ActiveValue);
    vfc_fiber = str2double(st_mater.vfc.ActiveValue);
    
    force = full_force/size_z;
    file_id = fopen("u_matlab.txt", "A");

    generic_filename = "isotropic_sol";
    u_alpha_iso = top_comp(vfc_fiber, (E_fiber + E_mx)/2, (E_fiber + E_mx)/2, ...
                           mu_mx, mu_mx, 0, force, generic_filename)
    fprintf(file_id, "u isotropic = %g\n", u_alpha_iso);

    generic_filename = sprintf("angle_%3d vfc_fib_%0.2f x_%.0f y_%.0f", ...
                               int8(0), vfc_fiber, size_x, size_y);
    u_alpha_0 = top_comp(vfc_fiber, E_fiber, E_mx, mu_mx, mu_mx, ...
                         0, force, generic_filename)
    fprintf(file_id, "u 0 = %g\n", u_alpha_0);

    generic_filename = sprintf("angle_22_5 vfc_fib_%0.2f x_%.0f y_%.0f", ...
                               vfc_fiber, size_x, size_y);
    u_alpha_225 = top_comp(vfc_fiber, E_fiber, E_mx, mu_mx, mu_mx, ...
                           pi/8, force, generic_filename)
    fprintf(file_id, "u 22.5 = %g\n", u_alpha_225);

    generic_filename = sprintf("angle_%3d vfc_fib_%0.2f x_%.0f y_%.0f", ...
                               int8(45), vfc_fiber, size_x, size_y);
    u_alpha_45 = top_comp(vfc_fiber, E_fiber, E_mx, mu_mx, mu_mx, ...
                          pi/4, force, generic_filename)
    fprintf(file_id, "u 45 = %g\n", u_alpha_45);

    generic_filename = sprintf("angle_%3d vfc_fib_%0.2f x_%.0f y_%.0f", ...
                               int8(90), vfc_fiber, size_x, size_y);
    u_alpha_90 = top_comp(vfc_fiber, E_fiber, E_mx, mu_mx, mu_mx, ...
                          pi/2, force, generic_filename)
    fprintf(file_id, "u 90 = %g\n", u_alpha_90);

    fclose('all');
end