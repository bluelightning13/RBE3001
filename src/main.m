%% Imports java files needed 
javaaddpath('../rbeadmin/git/RBE3001/lib/hid4java-0.5.1.jar');
import org.hid4java.*;
import org.hid4java.event.*;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.lang.*;

pp = PacketProcessor(7);
az = 10;
el = 10;

values = zeros(15, 1, 'single');
pause(1)
for i = 0:100
    %% Importing the Data
    % Init the array that will be filled with values
    
    values(1) = values(1)+13;%530;
    values(4) = values(4)+10;%550;
    values(7) = values(7)+13;%780; -5,53,-81


    % Read in Packets here
    returnValues = pp.command(37, values);
    %disp(returnValues')
    
    %% Calculating the kinematics
    % The position of the arm is returned as encoder tics (0->4095)
    % First the angle is found before Forward Kinematics is preformed
    PosNegEnc = [returnValues(1)/abs(returnValues(1)); returnValues(4)/abs(returnValues(4)); returnValues(7)/abs(returnValues(7))]
    
    Encoder_1 = mod(abs(returnValues(1)),4096)
    Encoder_2 = mod(abs(returnValues(4)),4096)
    Encoder_3 = mod(abs(returnValues(7)),4096)
    
    ratio = (4095-0)/(360-0);
    EncoderA_1 = ((Encoder_1/ratio))*(pi/180)*PosNegEnc(1);
    EncoderA_2 = ((Encoder_2/ratio))*(pi/180)*PosNegEnc(2);
    EncoderA_3 = ((Encoder_3/ratio))*(pi/180)*PosNegEnc(3);
    
    

    % Making the transform and rotation matricies
    T1 = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 25; 0, 0, 0, 1];
    T2 = [1, 0, 0, 20; 0, 1, 0, 0; 0, 0, 1, 0; 0, 0, 0, 1];
    T3 = [1, 0, 0, 0; 0, 1, 0, 0; 0, 0, 1, 20; 0, 0, 0, 1];
    
    R1 = [cos(EncoderA_1) -sin(EncoderA_1) 0 0; sin(EncoderA_1) cos(EncoderA_1) 0 0; 0 0 1 0; 0 0 0 1];
    R2 = [cos(EncoderA_2) 0 sin(EncoderA_2) 0; 0 1 0 0; -sin(EncoderA_2) 0 cos(EncoderA_2) 0; 0 0 0 1];
    R3 = [cos(EncoderA_3) 0 sin(EncoderA_3) 0; 0 1 0 0; -sin(EncoderA_3) 0 cos(EncoderA_3) 0; 0 0 0 1];

    Link_1 = T1*R1;
    Link_2 = T2*R2*Link_1;
    Link_3 = T3*R3*Link_2;

    Link_1 = Link_1(1:3, 4);
    Link_2 = Link_2(1:3, 4);
    Link_3 = Link_3(1:3, 4);


    X = [0, Link_1(1), Link_2(1), Link_3(1)];
    Y = [0, Link_1(2), Link_2(2), Link_3(2)];
    Z = [0, Link_1(3), Link_2(3), Link_3(3)];
    
    figure(1)
    drawnow;
    clf()
    hold on;
    grid on
    axis([-40 40 -40 40 -10 40])
  
    
    fmesh(@(x,y) 0*x, [-15 15 -15 15]);
    plot3(X,Y,Z, 'LineWidth',8, 'Color', 'k', 'Marker','.', 'MarkerSize', 50, 'MarkerEdgeColor', [0 0 0])
    view(az, el);
    title('RBE3001 Arm Axis');
    ylabel('Y');
    zlabel('Z');
    xlabel('X');
    
    hold off;
    %pause(1);
end 




