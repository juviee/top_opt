function read_settings(s_filename):
    ini_st = ini2struct(s_filename);
    s = settings;
    addGroup(s, 'topoptSettings');
    addSetting(s.topoptSettings, '')
end