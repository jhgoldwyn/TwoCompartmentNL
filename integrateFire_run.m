% integrateFire_run.m

clear all
close all

%%% user select some parameters %%%%

 % length of simulation
 tEnd = 15;

% for sinusoidal input current:
I0 = 0;    % input mean 
I1 = 0.5; % input amplitude 

% for randomly fluctuating inputs
sig = 3; % st. dev of amplitude fluctuations, make = 0 for deterministic input

% subthreshold nonlinearity
p = 0;  % interpolate between: 0=linear, 1=nonlinear

% spike speed, exponential growth parameter 
q = 1; %(typically choose values between 1 and 5)

% piecewise nonlinearity: value of x at which dynamics switch from subthreshold to spike initiation
spikeInit = 1;

%%% run %%%%
[t,x,~] = IFfunction(I0,I1,p,q,sig,spikeInit,tEnd); 

%%% plot results %%%%
plot(t,x,'k','linewidth',2)
xlabel('t')
ylabel('x')

% function that defines Integrate-and-fire model dynamics and solves with Euler method
function [t,x,nSpike] = IFfunction(I0,I1,p,q,sig,spikeInit,tEnd)

    % some fixed parameters
    dt = 100e-6; % time step
    freq = 4000; % input frequency
    per = 1000/freq; % input period
    tau = .1; % IF time constant 
    spikeGen = 50; % maximum value of x, value at which spike is reset
    xReset = -5; % x value for reset after a spike
    x0  = 0 ; % initial value

    % time vector
    t = [0:dt:tEnd]; 
    nt = length(t);

    % function that defines subthreshold dynamics
    f = @(x,p) (1-p)*x + p*((x<=0).*x + (x>0).*(x./(1+x)));
    
    % function that defines sinusoidal input current
    I = @(t,I0,I1,fluc) I0 + (I1+fluc)*sin(2*pi*freq*t/1000);

    % for random fluctuations in input amplitude
    nCycle = floor(tEnd/(1000/freq));
    r = sig*rand(nCycle,1);
    
    % solve using euler method
    x(1) = x0;
    nSpike = 0; % spike counter
    for i=2:nt

        % random amplitude fluctuation amount
        if i==2; fluc = r(1); else; fluc = r(ceil(t(i-1)/per)); end
        
        % input current this time step
        Ii = I(t(i-1),I0,I1,fluc); 
        
        % update x
        if x(i-1)<spikeInit % subthreshold
            x(i) = x(i-1) + dt*(-f(x(i-1),p) + Ii)/tau;
        elseif x(i-1)<spikeGen  % start spike dynamics
            x(i) = x(i-1) + dt*( q*(x(i-1)-spikeInit) +  Ii)/tau;
%             x(i) = x(i-1) + dt*( q*(x(i-1)-spikeInit) +   I(t(i-1),I0,I1,fluc))/tau;
        else % spike complete
            x(i) = xReset;
            nSpike = nSpike+1;
        end
    
    end % end loop over time steps
    
end % end IF function
