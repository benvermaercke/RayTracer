function distances=calc_dist_matrix(point,M)

x0 = point(1);
y0 = point(2);
distances = sqrt((M(:,1)-x0).^2 + (M(:,2)-y0).^2);