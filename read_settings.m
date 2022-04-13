function read_settings(s_filename)
    ini_st = ini2struct(s_filename);
    s = settings;
    try
        removeGroup(s, 'topOptSettings');
    catch
    end
    addGroup(s, "topOptSettings");
    fn_lvl1 = fieldnames(ini_st);
    for i=1:numel(fn_lvl1)
        lvl1_name_tmp = string(fn_lvl1(i));
        lvl1_field_tmp = ini_st.(string(lvl1_name_tmp));
        fn_lvl2 = fieldnames(lvl1_field_tmp);
        addGroup(s.topOptSettings, lvl1_name_tmp);
        for i=1:numel(fn_lvl2)
            lvl2_name_tmp = string(fn_lvl2(i));
            lvl2_field_tmp = lvl1_field_tmp.(string(lvl2_name_tmp));
            addSetting(s.topOptSettings.(lvl1_name_tmp),lvl2_name_tmp);
            s.topOptSettings.(lvl1_name_tmp).(lvl2_name_tmp).PersonalValue = lvl2_field_tmp;
            fprintf("%s.%s.%s\n",lvl1_name_tmp, lvl2_name_tmp, lvl2_field_tmp);
            fprintf('%s.\n', s.topOptSettings.(lvl1_name_tmp).(lvl2_name_tmp).ActiveValue)
        end
    end
end