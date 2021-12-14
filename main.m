%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Hydrodynamic shape optimization          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialisation
clear all;
% prtcl_3d_shape will generate the shape data for a sphere

system('cd ./fortran_exec;./prtcl_3d_shape')

% Copy the initial data into the data folder
system('cp -R ./fortran_exec/shape_data.out ./data_files/shape_data.out');

figure(4);clf;
tiledlayout(1,2)

%% Iteration

i_end = 15;
for i=1:i_end
    
    disp(['Iteration ', num2str(i)])
    %solve stokes for shape gradient and laplace eq and copy the gradient
    tic
    system('cd ./fortran_exec;./run.sh')
    toc
    system('cp -R ./fortran_exec/shape_gradient.out ./data_files/shape_gradient.out');
    system('cp -R ./fortran_exec/theta.out ./data_files/theta.out');

    % Read the shape data
    shapedata = fopen("data_files/shape_data.out");

    N_elm = fscanf(shapedata,'%d',[1 1]); %number of elements
    N_pts = fscanf(shapedata,'%d',[1 1]); %number of nodes
    coord = fscanf(shapedata,'%f',3*N_elm); %elements coordinates
    coord_elm = [coord(1:3:end-2),coord(2:3:end-1),coord(3:3:end)];
    coord = fscanf(shapedata,'%f',3*N_pts); %points coordinates
    coord_pts = [coord(1:3:end-2),coord(2:3:end-1),coord(3:3:end)];
    mat_N = fscanf(shapedata,'%d',[6*N_elm 1]);
    mat_N = reshape(mat_N,[6,N_elm]);
    mat_NE = fscanf(shapedata,'%d',[7*N_pts 1]);
    mat_NE = reshape(mat_NE,[7,N_pts]);
    mat_NBE = fscanf(shapedata,'%d',[3*N_elm 1]);
    mat_NBE = reshape(mat_NBE,[3,N_elm]);

    fclose(shapedata);

    % Read the shape gradient
    grad_data = fopen("data_files/shape_gradient.out");

    coeff = fscanf(grad_data,'%f',[1 1]);
    grad = fscanf(grad_data,'%f',N_pts);

    fclose(grad_data);

    grad_elm=zeros(1,N_elm);
    for j = 1:N_elm
        grad_elm(j) = sum(grad(mat_N(1:3,j)))/3;
    end

    % read and normalize the descent direction
    theta_data = fopen("data_files/theta.out");
    theta = fscanf(theta_data,'%f',3*N_pts);
    fclose(theta_data);

    theta = [theta(1:3:end-2),theta(2:3:end-1),theta(3:3:end)];
    norm_theta = sqrt(max(theta(:,1).^2+theta(:,2).^2+theta(:,3).^2));
    theta = theta/norm_theta;

    % deform the shape
    tau = 5e-2; %descent step
    coord_pts_new = coord_pts + tau*theta;

    % plot the shape
    faces = mat_N(1:3,:)';

    nexttile(1);cla;
    colormap jet
    patch('Faces',faces,'Vertices',coord_pts,'CData',grad_elm,'FaceColor','flat','FaceAlpha',0.5)
    hold on
    axis equal
    v=[60,20];
    view(v)
    quiver3(coord_pts(:,1),coord_pts(:,2),coord_pts(:,3),theta(:,1),theta(:,2),theta(:,3),2,'k','LineWidth',1)
    hold off

    xlabel('x');ylabel('y');zlabel('z');

    nexttile(2);cla;
    colormap jet
    patch('Faces',faces,'Vertices',coord_pts_new,'FaceColor','blue','FaceAlpha',0.5)
    axis equal
    view(v)
    xlabel('x');ylabel('y');zlabel('z')

    drawnow

    %% Record the new shape data

    % calculate new midpoints of sides and element centroids
    coord_elm_new = zeros(size(coord_elm));
    for j = 1:N_elm
        coord_pts_new(mat_N(4,j),:)=(coord_pts_new(mat_N(1,j),:)+coord_pts_new(mat_N(2,j),:))/2;
        coord_pts_new(mat_N(5,j),:)=(coord_pts_new(mat_N(2,j),:)+coord_pts_new(mat_N(3,j),:))/2;
        coord_pts_new(mat_N(6,j),:)=(coord_pts_new(mat_N(1,j),:)+coord_pts_new(mat_N(3,j),:))/2;
        coord_elm_new(j,:)=(coord_pts_new(mat_N(1,j),:)+coord_pts_new(mat_N(2,j),:)+coord_pts_new(mat_N(3,j),:))/3;
    end

    shapedata_new = fopen("data_files/shape_data.out",'w');

    fprintf(shapedata_new,'%d\n',N_elm);
    fprintf(shapedata_new,'%d\n',N_pts);
    fprintf(shapedata_new,'%f %f %f\n',coord_elm_new');
    fprintf(shapedata_new,'%f %f %f\n',coord_pts_new');
    fprintf(shapedata_new,'%d\n',reshape(mat_N,6*N_elm,1));
    fprintf(shapedata_new,'%d\n',reshape(mat_NE,7*N_pts,1));
    fprintf(shapedata_new,'%d\n',reshape(mat_NBE,3*N_elm,1));

    fclose(shapedata_new);

    system('cp -R ./data_files/shape_data.out ./fortran_exec/shape_data.out');

end



















