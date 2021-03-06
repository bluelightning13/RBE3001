
classdef PacketProcessor
    properties
        hidDevice;
        hidService;
    end
    methods
        function  shutdown(packet)
            packet.hidDevice.close();
            packet.hidService.shutdown();

        end
        function packet = PacketProcessor(deviceID)
            javaaddpath('../lib/hid4java-0.5.1.jar');
            
            import org.hid4java.*;
            import org.hid4java.event.*;
            import java.nio.ByteBuffer;
            import java.nio.ByteOrder;
            import java.lang.*;
            import org.apache.commons.lang.ArrayUtils.*;
            
            if nargin > 0
                packet.hidService = HidManager.getHidServices();
                packet.hidService.start();
                hidDevices = packet.hidService.getAttachedHidDevices();
                dev=hidDevices.toArray;
                
                for k=1:(dev.length)
                    if dev(k).getProductId() == deviceID
                        packet.hidDevice = dev(k);
                        packet.hidDevice.open();

                    end
                end
            end
        end
        function threshVal = mythreshhold(~,incoming)
            if incoming<0
                threshVal=uint8(incoming+256);
            else
                 threshVal=uint8(incoming);
            end
        end
        function com = command(packet, idOfCommand, values)
            packetSize = 64;
            numFloats = (packetSize / 4) - 1;
            %tic
            objMessage = javaArray('java.lang.Byte', packetSize);
            tempArray = packet.single2bytes(idOfCommand, values);
            
            for i=1:size(tempArray)
                objMessage(i) = java.lang.Byte(tempArray(i));
            end
            message = javaMethod('toPrimitive', 'org.apache.commons.lang.ArrayUtils', objMessage);
            returnValues = zeros(numFloats, 1);
            
            if packet.hidDevice.isOpen()

                val = packet.hidDevice.write(message, packetSize, 0);

                if val > 0
                    ret = packet.hidDevice.read(int32(packetSize), int32(1000));
                    disp('Read from hardware');
                    toc
                    disp('Convert to bytes');
                    byteArray = arrayfun(@(x)  x.byteValue(), ret);
                    toc
                    disp('Reshape');
                    sm = reshape(arrayfun(@(x)  mythreshhold(packet,x), byteArray),[4,16]);
                    toc;
                    disp('parse');
                    if ~isempty(ret)
                           for i=1:length(returnValues)
                               subMatrix = sm(:,i+1);
                               returnValues(i)=typecast(subMatrix,'single');
                           end
                           
                    else
                        disp("Read failed")
                    end
                else
                    disp("Writing failed")
                end
            else
                disp('Device closed!')
            end
            com = returnValues;
        end
        function thing = single2bytes(~, code, val)
            returnArray=uint8(zeros((length(val)+1)*4));
            tmp1 = typecast(int32(code), 'uint8');
            for j=1:4
                 returnArray(j)=tmp1(j);
            end
            %disp('Code: ')

            %disp(code)
            %disp(tmp1)
            for i=1:length(val)
                tmp = typecast(single(val(i)), 'uint8');
                for j=1:4
                    returnArray((i*4)+j)=tmp(j);
                end
            end
            thing = returnArray;
        end
    end
end
