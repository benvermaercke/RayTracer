clear all
clc

addpath(genpath(fileparts(mfilename('fullpath'))))

%%

RT=RayTracer();

% ETL? 
RT.add_lens('radii',[-1000 -100],'spatial_location',[-50 -24],'angle',pi/2,'height',25.4*1.4,'thickness',4,'kappa',-3.5) % offset A
RT.add_lens('radii',[-100 100],'spatial_location',[-50 -19],'angle',pi/2,'height',25.4*1.4,'thickness',2,'kappa',-3.5) % offset B

RT.add_lens('radii',[40 -1000],'spatial_location',[-50 -30],'angle',pi/2,'height',25.4*1.4,'thickness',6,'kappa',-3.5) % ETL

RT.add_lens('radii',[50 -50],'spatial_location',[0 0],'height',25.4*1.4,'thickness',6,'kappa',-3.5) % scan lens
RT.add_lens('radii',[100 -100],'spatial_location',[150 0],'height',25.4*2,'thickness',6,'kappa',-3.5) % tube lens

RT.add_absorber('height',25,'spatial_location',[250 20])
RT.add_lens('radii',[1 -1]*60,'spatial_location',[250 0],'height',25.4,'thickness',6,'kappa',-3.5)
RT.add_absorber('height',25,'spatial_location',[250 -30])

RT.add_absorber('height',100,'spatial_location',[320 0])

RT.add_bundle('bundle_type',2,'nRays',9,'center_location',[-50 -50],'initial_direction',pi/2,'beam_spread',15)

switch 3% max range is .11
    case 1
        galvo_angle=pi/4*3-.06;
    case 2
        galvo_angle=pi/4*3-.03;
    case 3
        galvo_angle=pi/4*3;
    case 4
        galvo_angle=pi/4*3+.03;
    case 5
        galvo_angle=pi/4*3+.06;
end

RT.add_mirror('height',40,'spatial_location',[-50 0],'angle',galvo_angle)


%%
RT.x_range=[-75 350];
RT.draw_space()

%%
RT.run_simulation()

%%
RT.update_space()

%% expand Y axis
cur_range=get(gca,'yLim');
set(gca,'yLim',cur_range/3)
axis square


if 0
    %% print current layout
    fname=sprintf('export/LSM/LSM_sim_a_%.d.eps',round(galvo_angle/pi*180))
    core.savec(fname)
    print(gcf,'-depsc',fname) 
end

if 0
    %% print current layout
    fname=sprintf('export/LSM/LSM_sim_a_%.d.png',round(galvo_angle/pi*180))
    core.savec(fname)
    print(gcf,'-dpng',fname) 
end



