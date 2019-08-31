function setByCurrents(Ix,Iy,Iz)
% clearvars objComPort
% delete(instrfind)
% load obj
%zero inclination (H=100, dec=30)
% Ix=0.3249;Iy=0.0490;Iz=0.0309
%pol: +,+,-
%30 deg:
% Ix=0.1758;Iy=0.0240;Iz=0.2579
%pol: +,-,+

limValue=7;

i=1;
objComPort(i) = tdkLambda_openPort(10,1);
tdkLambda_setCurrent(objComPort(i), 0); 
tdkLambda_setVoltage(objComPort(i), limValue);
tdkLambda_setOutput(objComPort(i), 1);
tdkLambda_setCurrent(objComPort(i), Ix)

i=2;
objComPort(i) = tdkLambda_openPort(5,2);
tdkLambda_setCurrent(objComPort(i), 0); 
tdkLambda_setVoltage(objComPort(i), limValue);
tdkLambda_setOutput(objComPort(i), 1);
tdkLambda_setCurrent(objComPort(i), Iy)

i=3;
objComPort(i) = tdkLambda_openPort(9,3);
tdkLambda_setCurrent(objComPort(i), 0); 
tdkLambda_setVoltage(objComPort(i), limValue);
tdkLambda_setOutput(objComPort(i), 1);
tdkLambda_setCurrent(objComPort(i), Iz)
end