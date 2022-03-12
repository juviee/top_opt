function [E1, E2, mu12, mu21, g12] = composite_const(E_fiber, E_mx, mu_fiber, mu_mx, vfc)
    % Из опыта растяжения без учета mu
    E1 = E_fiber*vfc + E_mx*(1-vfc);
    E2 = E_fiber*E_mx / (vfc*E_mx + (1-vfc)*E_fiber);
    
    g_fiber = linear_g(E_fiber, mu_fiber);
    g_mx = linear_g(E_mx, mu_mx);
    g12 = g_fiber*g_mx / (vfc*g_mx + (1-vfc)*g_fiber);

    mu12 = mu_fiber*vfc + mu_mx*(1-vfc);
    mu21 = mu12*E2/E1;
end

function g_el = linear_g( E, mu )
    g_el = E / 2 / ( 1 + mu );
end