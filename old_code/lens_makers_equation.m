clear all
clc

IOR_air=1.00029;
IOR_water=1.3333;
IOR_glass=1.517;

R=[50 -50];

% thin lens
switch 2
    case 1
        %P_lens=
        P_lens=(IOR_glass-1)*( 1/R(1) - 1/R(2) );
    case 2
        P_lens=((IOR_glass-IOR_air)/IOR_air) * (1/R(1) - (1/R(2)));
end

Focal_length=1/P_lens;

[P_lens Focal_length]