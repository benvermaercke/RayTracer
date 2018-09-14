clearvars
clc

addpath(genpath(core.up1(fileparts(mfilename('fullpath')))))


RT=RayTracer();

F1=60;
F2=100;
kappa_val=.3;

nRays=3;
spread=.3;
source_offset=0;

RT.x_range=[-100 350];

% lens 1
switch 2
    case 1
        % symmetric lens
        RT.add_lens('radii',[1000 -F1/2],'spatial_location',[0 0],'height',25.4*2,'thickness',15,'kappa',kappa_val)
    case 2
        % curved side to projector
        RT.add_lens('radii',[F1/2 -1000],'spatial_location',[0 0],'height',25.4*2,'thickness',20,'kappa',kappa_val)
        source_offset=-15;
    case 3
        % curved side away from projector - current situation
        RT.add_lens('radii',[1000 -F1/2],'spatial_location',[0 0],'height',25.4*2,'thickness',20,'kappa',kappa_val)
        source_offset=18;
end
% lens 2
%RT.add_lens('radii',[F2 -F2],'spatial_location',[F1+F2 0],'height',25.4*2,'thickness',8,'kappa',kappa_val)
RT.add_lens('radii',[F2/2 -1000],'spatial_location',[F1+F2 0],'height',25.4*2,'thickness',8,'kappa',kappa_val)
%RT.add_lens('radii',[1000 -F2/2],'spatial_location',[F1+F2 0],'height',25.4*2,'thickness',8,'kappa',kappa_val)

RT.add_absorber('height',10,'spatial_location',[-F1+source_offset-5 -1],'thickness',3)
RT.add_absorber('height',200,'spatial_location',[F1+F2*2+50 0])


switch 1
    case 1
        
        RT.add_bundle('bundle_type',1,'nRays',nRays,'center_location',[-F1+source_offset 0],'initial_direction',0,'angle_spread',spread)
        RT.add_bundle('bundle_type',1,'nRays',nRays,'center_location',[-F1+source_offset 5],'initial_direction',0,'angle_spread',spread,'color',[0 0 1])
        RT.add_bundle('bundle_type',1,'nRays',nRays,'center_location',[-F1+source_offset -5],'initial_direction',0,'angle_spread',spread,'color',[0 1 1])
        %RT.add_bundle('bundle_type',2,'nRays',9,'center_location',[-F1 0],'initial_direction',0,'beam_spread',15,'color',[0 0 0])
    case 2
        %RT.add_bundle('bundle_type',2,'nRays',3,'center_location',[0 0],'initial_direction',0,'beam_spread',1)
        RT.add_bundle('bundle_type',2,'nRays',9,'center_location',[-F1 0],'initial_direction',0,'beam_spread',15)
        
end


RT.draw_space()

%%
RT.run_simulation()

%%
RT.update_space()

%% expand Y axis
cur_range=get(gca,'yLim');
set(gca,'yLim',cur_range/5)
axis square

plot([F1 F1]+source_offset,[-100 100],'k:')
% reveal some aberrations in the focal plane curvature






