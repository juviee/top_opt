function B_matrix = matrix_b( size_x, size_y )
    J_matrix = [size_x/2, 0;...
                0, size_y/2];
    J_inv_matrix = inv(J_matrix);
    syms xx yy;
    %xx, yy -- локальные нормализованные координаты
    % левый верхний > правый верхний > правый нижний > левый нижний
    Ndiff2 = J_inv_matrix * [(1+yy)/4; (1+xx)/4];
    Ndiff1 = J_inv_matrix * [-(1+yy)/4; (1-xx)/4];
    Ndiff4 = J_inv_matrix * [-(1-yy)/4; -(1-xx)/4];
    Ndiff3 = J_inv_matrix * [(1-yy)/4; -(1+xx)/4];

    B_1_mx = [Ndiff1(1),         0;
              0        , Ndiff1(2);
              Ndiff1(2), Ndiff1(1)];
    B_2_mx = [Ndiff2(1),         0;
              0        , Ndiff2(2);
              Ndiff2(2), Ndiff2(1)];
    B_3_mx = [Ndiff3(1),         0;
              0        , Ndiff3(2);
              Ndiff3(2), Ndiff3(1)];
    B_4_mx = [Ndiff4(1),         0;
              0        , Ndiff4(2);
              Ndiff4(2), Ndiff4(1)];

    B_matrix = [B_1_mx, B_2_mx, B_3_mx, B_4_mx];

end