clearvars
clc

fname=mfilename('fullpath');
addpath(genpath(core.up1(fileparts(fname))))

RT=RayTracer();

RT.add_absorber('height',300,'spatial_location',[200 0])

kappa_val=-3.5;
focal_length=50;

RT.x_range=[-200 300];
RT.y_range=[-300 300];

% draw lightpath

% projector
RT.add_bundle('bundle_type',1,'nRays',11,'center_location',[-50 0],'initial_direction',0,'angle_spread',60/180/pi,'color',[0 0 1])

% condensor
RT.add_lens('radii',[1 -1]*25,'spatial_location',[0 0],'height',25.4*1,'thickness',8,'kappa',1)

% 45 deg elliptical mirror
RT.add_mirror('height',40,'spatial_location',[25 0],'angle',pi/4)

% fisheye
RT.add_lens('radii',[1 -1]*20,'spatial_location',[25 -25],'height',25.4*1,'thickness',10,'kappa',1,'angle',-pi/2)

RT.draw_space()

%%
RT.run_simulation()

%%
RT.update_space()

plot([focal_length focal_length],[-300 300],'m-')

%% expand Y axis
switch 0
    case 0
        axis equal
    case 1
        cur_range=get(gca,'yLim');
        set(gca,'yLim',cur_range/3)
        axis square
end






