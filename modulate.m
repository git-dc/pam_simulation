function [mod_data, pulse] = modulate(data, fn, bd)
%MODULATE Modulate data stream with half-sine 
% and square-root raised-cosine waves
% close all;
A1 = 1;
A2 = 1;
alpha = 0.9; % rolloff factor
K = 4; % between 2 and 6

            
T = 1/bd;   % Period = 1/bit duration
data = double(reshape(data,[],1));
switch fn
    case 'halfsine'
        pulse = 1/sqrt(sum(sin(pi*(0:1/31:1)).^2)).*sin(pi*(0:1/31:1));
        data = data*pulse + (data-1)*pulse;
    case 'srrc'
        pulse = rcosdesign(alpha, K, T);
        data =  (2*data.*ones(1,T) - 1)';
        data = data(:);
        data = filter(pulse,1,data);
end
data = data';
mod_data = data(:);
end

