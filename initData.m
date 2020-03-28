N1 = 10;    % Number of points in X
N2 = 5;     % Number of points in Y

L = 2;      % Length of the box in X
W = 1;      % Length of the box in Y

R = 0.05;   % Radius of the balls
maxSpacingRatio = 0.3; % How many raduis by which initial posisiton can vary
Vmax = 0.3; % Maximum initial velocity of balls


serverTime = 22; % Time to heal

N = N1*N2;
X = linspace(-L/2,L/2,N1);
Y = linspace(-W/2,W/2,N2);


clear x0 v0
cnt = 0;
for i = 1:N1
    for j = 1:N2
        cnt = cnt+1;
        x0(cnt,:) = [ 0.9*X(i)+maxSpacingRatio*R*getRand 0.9*Y(j)+maxSpacingRatio*R*getRand];
        v0(cnt,:) = [getRand*Vmax getRand*Vmax ]; %#ok<SAGROW>
    end
end

% %For debugging
% x0 = [linspace(-0.8, 0.8, N)' zeros(N,1)]

stateVector = Simulink.Signal;
stateVector.Dimensions = N;
stateVector.DataType = 'double'; 
stateVector.Complexity = 'real';

state0id = 5;
% patient0 = randi(N)
state0 = zeros(N,1);
state0(state0id) = 1;