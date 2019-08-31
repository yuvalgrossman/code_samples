function [polarities,Iout]=setMagneticField(req_field,accuracy,norFac,chinfo,coupling,limValue)
%Adjust req_field to be the Magnetic Field in Helmholtz coil, with read and
%out cycle using Bartingtone Mag-03 magnetometer located in the coil. 
%Input parameters: 
%   -req_field: required field, in uT
%   -accuracy: accuracy of field set, in uT
%   -norFac: normalization factor of the magnetometer (volts to uT)
%   -chinfo: channels information: [power supply type, COM PORT, ADDRESS, polarity]
%                 power supply type:    1 - 'Circuit Specialist 3646A'
%                                       2 - 'TDK Lambda Z+'
%                 polarities:           1 - Normal
%                                       0 - Reverse
% coupling='vc';
% coupling='cc';
%% equipment parameters: 

R = [8.9 7.9 6.7]; % coil resistance (Ohm)
ApuT = 0.3/100; %Ampers per microTesla (3 mA per uT)
% col = get(gca,'ColorOrder');
cs = [find(chinfo(:,1)==1)]' %Circuit Specialist
tl = [find(chinfo(:,1)==2)]' %TDK Lambda
pnswitch=chinfo(:,4)';
for i=1:3 
    if pnswitch(i)
        polarities{i}='Normal';
    else
        polarities{i}='Reverse';
    end
end

%% output using 364x power supplies: 

addpath('..\Circuit Specialists, 364x\MATLAB functions')
for i=cs
    cmd82(chinfo(i,2), chinfo(i,3), 1, 1)
    cmd80(chinfo(i,2), chinfo(i,3), 2, 18, 36, 0)
end

%% output using TDK-Lambda Z+
addpath('..\TDK-Lambda, Z160-5\MATLAB functions')
% open the port
for i=1:length(tl)
    objComPort(i) = tdkLambda_openPort(chinfo(tl(i),2),chinfo(tl(i),3));
    % set the output mode
    tdkLambda_setOutput(objComPort(i), 1);
    switch coupling
        case 'Voltage'
            tdkLambda_setVoltage(objComPort(i), 0);
            tdkLambda_setCurrent(objComPort(i), limValue); %maximum current
        case 'Current'
            tdkLambda_setCurrent(objComPort(i), 0); 
            tdkLambda_setVoltage(objComPort(i), limValue); %maximum voltage
    end     
end
save('Matlab functions\obj.mat','objComPort');

%% define input object: 
sessionI = daq.createSession('ni');
dur=0.01; %duration
sessionI.DurationInSeconds = dur;
% sessionI.Rate = 2000; %sample rate
%add analog input channels
addAnalogInputChannel(sessionI, 'cDAQ1Mod1', 'ai1', 'Voltage');
addAnalogInputChannel(sessionI, 'cDAQ1Mod1', 'ai2', 'Voltage');
addAnalogInputChannel(sessionI, 'cDAQ1Mod1', 'ai3', 'Voltage');

%% read input: 
data = startForeground(sessionI);
measured_field=mean(data).*norFac;
Iout=zeros(1,3); Vout=zeros(1,3);
it=0; %iteration number

%% set and read loop: 
while sum(abs(measured_field-req_field)>accuracy)>0
    it=it+1
    if it==20
        uiwait(msgbox('The field required can not be set in the specified accuracy!'))
        return
    end
    %set current and voltage according to the difference in fields:
    Iout = Iout - (measured_field-req_field).*ApuT  
    Vout = Iout.*R
    
    %check if voltage negative:
    pnflag=(Vout>0); %possitive/negative flag - denotes if the connection should be normal (1) or reversed (0)
    if find(~(pnflag==pnswitch))
        uiwait(msgbox(['Switch +/- connection of channel/s:' num2str(find(~(pnflag==pnswitch)))]))
        pnswitch(find(~(pnflag==pnswitch)))=~pnswitch(find(~(pnflag==pnswitch)));
    end
    
    %apply the voltage:
    for i=cs
        cmd80(chinfo(i,2), chinfo(i,3), 1, 10, 10, abs(Vout(i)))
    end
    
switch coupling
    case 'Voltage'      % VOLTAGE COUPLED
        for i=1:length(tl)
          if abs(Vout(tl(i)))<7
            tdkLambda_setVoltage(objComPort(i), abs(Vout(tl(i))))
          else
            tdkLambda_setVoltage(objComPort(i), 7)
          end
        end
    case 'Current'    % CURRENT COUPLED
        for i=1:length(tl)
          if abs(Iout(tl(i)))<1.5
            tdkLambda_setCurrent(objComPort(i), abs(Iout(tl(i))))
          else
            tdkLambda_setCurrent(objComPort(i), 1.5)
          end
        end
end
    %measure magnetic field: 
    data = startForeground(sessionI);
    measured_field = mean(data).*norFac;
    
for i=1:3 
    if pnswitch(i)
        polarities{i}='Normal';
    else
        polarities{i}='Reverse';
    end
end
end

end
