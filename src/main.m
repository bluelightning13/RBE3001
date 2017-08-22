%% Imports java files needed 
javaaddpath('../rbeadmin/git/RBE3001/lib/hid4java-0.5.1.jar');
import org.hid4java.*;
import org.hid4java.event.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.lang.*;
pp = PacketProcessor(7);
az = 20;
el = 20;

for i = 0:100
    %% Importing the Data
    % Init the array that will be filled with values
    values = zeros(15, 1, 'single');

    % Read in Packets here
    returnValues = pp.command(37, values);
    disp(returnValues')
    
    %% Calculating the kinematics
    % The position of the arm is returned as encoder tics (0->4095)
    % First the angle is found before Forward Kinematics is preformed

    Encoder_1 = returnValues(1)
    Encoder_2 = returnValues(4)
    Encoder_3 = returnValues(7)

    ratio = (4095-0)/(360-0);
    Encoder_1 = 360-0;%(Encoder_1/ratio)*(pi/180);
    Encoder_2 = 360-(Encoder_2/ratio)*(pi/180);
    Encoder_3 = 360-(Encoder_3/ratio)*(pi/180);


    % Making the transform and rotation matricies

    T1 = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 25; 0, 0, 0, 1];
    T2 = [1, 0, 0, 15; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
    T3 = [1, 0, 0, 15; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
    R1 = [cos(Encoder_1) -sin(Encoder_1) 0 0; sin(Encoder_1) cos(Encoder_1) 0 0; 0 0 1 0; 0 0 0 1];
    R2 = [cos(Encoder_2) 0 sin(Encoder_2) 0; 0 1 0 0; -sin(Encoder_2) 0 cos(Encoder_2) 0; 0 0 0 1];
    R3 = [cos(Encoder_3) 0 sin(Encoder_3) 0; 0 1 0 0; -sin(Encoder_3) 0 cos(Encoder_3) 0; 0 0 0 1];

    Link_1 = T1*R1;
    Link_2 = T2*R2*Link_1;
    Link_3 = T3*R3*Link_2;

    Link_1 = Link_1(1:3, 4);
    Link_2 = Link_2(1:3, 4);
    Link_3 = Link_3(1:3, 4);


    X = [0, Link_1(1), Link_2(1), Link_3(1)];
    Y = [0, Link_1(2), Link_2(2), Link_3(2)];
    Z = [0, Link_1(3), Link_2(3), Link_3(3)];
    figure(1) % creates figure window
    drawnow; % forces matlab to draw each iteration. Otherwise matlab waits until all other processing is done to render.
    clf() % clears all graphics from the plot
    hold on; % puts all plots onto this figure
    grid on % turns on the grid
    axis([-40 40 -40 40 -10 40]) % sets the axis limits - xmin xmax ymin ymax zmin zmax
    
    fmesh(@(x,y) 0, [-15 15 -15 15]) % makes the ground plane in the plot
    plot3(X,Y,Z, 'LineWidth',8, 'Color', 'k', 'Marker','.', 'MarkerSize', 50, 'MarkerEdgeColor', [0 0 0]) % plots the arm
    view(az, el); % sets the 3D view. 
    
    title('RBE3001 Arm Axis')
    ylabel('Y')
    zlabel('Z')
    xlabel('X')
    
    hold off;
    %pause(1); %this can be used to slow readings down - units are seconds
end 




