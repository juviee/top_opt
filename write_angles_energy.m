function write_angle_energy
    fname = "angle_energy.xls";
    try
        delete fname
    catch
    end
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
    
    u_c_global = [];
    force = full_force/size_z;
    for i=0:1:180
        angle = double(i * pi / 180);
        generic_filename = "unnamed";
        [energy, umax] = top_comp(vfc_fiber, E_fiber, E_mx, mu_mx, mu_mx, ...
                                  angle, force, generic_filename);
        u_c_global = [u_c_global; [angle, energy, umax]];
    end
    writematrix(u_c_global, fname)
end