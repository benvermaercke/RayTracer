function angle_out=constrain_angle(angle_in)

angle_out=mod(angle_in+pi/2,pi)-pi/2;


if 0
    %%
    X=linspace(-2*pi,2*pi,200);
    
    Y=constrain_angle(X)
    
    plot(X,Y)
    
    
end