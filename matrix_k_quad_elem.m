function k_matrix = matrix_k_quad_elem( size_x, size_y, d_matrix )
    syms xx yy
    b_matrix = matrix_b( size_x, size_y );
    k_matrix = arrayfun(@(x) size_x * size_y * double(x)/ 4, int( int( transpose(b_matrix) * d_matrix * b_matrix, xx, -1, 1 ), yy, -1, 1 ) );
end

