function initdata = initData(opts)
arguments
    opts.N1 = 10            % Number of points in X
    opts.N2 = 10            % Number of points in Y
    opts.L = 2              % Length of the box in X
    opts.W = 1              % Length of the box in Y
    opts.R = 0.025          % Radius of the balls
    opts.recoverTime = 22;  % Time to recover (heal)
    opts.vmax = 0.2         % Maximum initial velocity of balls
    opts.immobRatio = 0.5
end

N1 = opts.N1;
N2 = opts.N2;
L = opts.L;
W = opts.W;
R = opts.R;
recoverTime = opts.recoverTime;
vmax = opts.vmax;
immobRatio = opts.immobRatio;

infectedIdx = 1;

maxSpacingRatio = 2; % How many raduis by which initial posisiton can vary

N = N1*N2;
X = linspace(-L/2+R, L/2-R, N1+2);
Y = linspace(-W/2+R, W/2-R, N2+2);
X = X(2:end-1);
Y = Y(2:end-1);
x0 = 0.9*X' + maxSpacingRatio*R*getRand(N1,1);
y0 = 0.9*Y' + maxSpacingRatio*R*getRand(N2,1);
% X = x0';
% Y = y0';

pos0 = [reshape(repmat(X, N2, 1), [], 1) repmat(Y', N1, 1)];
v0 = vmax * getRand(N,2);

status0 = zeros(N,1);
status0(infectedIdx) = 1;

immobilized = get_immobilized(immobRatio, N, infectedIdx);
v0(immobilized, :) = 0;

initdata = struct('pos', pos0, 'v', v0, 'status', status0,...
    'parameters', struct('N', N, 'L', L, 'W', W, 'R', R, 'recoverTime', recoverTime));

function y = getRand(varargin)
% Generate a random number between -1 and 1
y = 2 * (rand(varargin{:}) - 0.5);
end

function immobilized = get_immobilized(immobRatio, N, infectedIdx)
immobNum = round(immobRatio * N);
notInfectedIdx = setdiff(1:N, infectedIdx);
randI = randperm(length(notInfectedIdx));
immobNum = min([immobNum length(randI)]);
notInfectedIdx = notInfectedIdx(randI(1:immobNum));
immobilized = false(N, 1);
immobilized(notInfectedIdx) = true;
end
end