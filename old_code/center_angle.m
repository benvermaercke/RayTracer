function angle=center_angle(angle)

block_size=pi;
offset=round(angle/block_size);
angle=angle-offset*block_size;


