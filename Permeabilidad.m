function permeabilidad_absoluta = Permeabilidad(fileName)
    
mu_agua           = 1.002*10^(-3); % Pa*s

% [um3*s-1, bar, um, um2] 
[Q, deltaP, L, A] = redHidraulica(fileName);

Q      = Q*10^(-12)        % paso de [um3/uPa] a [m3/Pa]
deltaP = deltaP*10.^(-6);  % paso de microPascales a pascales
L      = L.*10.^(-6);      % paso de micras a metros
A      = A.*10.^(-6);      % paso de micras a metros


permeabilidad_absoluta = (Q*mu_agua*L)/(deltaP*A); % m2

end