%% define input object: 
sessionI = daq.createSession('ni');
dur=0.1; %duration
sessionI.DurationInSeconds = dur;
% sessionI.Rate = 2000; %sample rate
%add analog input channels
addAnalogInputChannel(sessionI, 'cDAQ1Mod1', 'ai1', 'Voltage');
addAnalogInputChannel(sessionI, 'cDAQ1Mod1', 'ai2', 'Voltage');
addAnalogInputChannel(sessionI, 'cDAQ1Mod1', 'ai3', 'Voltage');
ocp=tdkLambda_openPort(3,4)
tdkLambda_setCurrent(ocp,0)
tdkLambda_setVoltage(ocp,10)
tdkLambda_setOutput(ocp,1)
%% negative connection 
D=zeros(1,3);

ncur=[0:0.05:1.5];
for i=ncur
        tdkLambda_setCurrent(ocp,i);%pause(0.3);
        data = startForeground(sessionI);
        D=[D;data];
end  
tdkLambda_setCurrent(ocp,0)
D(1,:)=[];
d=reshape(D,[161,size(D,1)/161,3]);
bzn=mean(d(:,:,3));

%% positive connection
D=zeros(1,3);
pcur=[0:0.05:1];
for i=pcur
        tdkLambda_setCurrent(ocp,i);%pause(0.3);
        data = startForeground(sessionI);
        D=[D;data];
end  
tdkLambda_setCurrent(ocp,0)
D(1,:)=[];
d=reshape(D,[161,size(D,1)/161,3]);
bzp=mean(d(:,:,3));


plot([0:-0.05:-1.5 0:0.05:1],[bzn bzp]*10,'.')
xlabel('Current (A)');ylabel('B_z (\muT)')