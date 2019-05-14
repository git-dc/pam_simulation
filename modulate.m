function [mod_data] = modulate(data, fn, bd)
%MODULATE Modulate data stream with half-sine 
% and square-root raised-cosine waves
% close all;
A1 = 1;
A2 = 1;
alpha = 0.5; % rolloff factor
K = 4; % between 2 and 6
x = @(t) t;


            
T = 1/bd;   % Period = 1/bit duration
% data = data(1:10);  % Test data sample
nbits = numel(data);
data = imresize(data, [1 int32(nbits/bd)], 'nearest');
n = numel(data);
t = linspace(1, n, n);

if fn == 1
    g = @(t,bits) A1 * sin(pi*t/T) .* (2*bits - 1);
else 
    g = @(t) A2 * x(t) .* bits;
end

% handle = figure;
% subplot(2,1,1);
% stem(g(t,data), "r", "fill", "MarkerSize",1); hold on;
% plot(sin(pi*t/T)); hold off;
% legend("Data","Waveform");
% subplot(2,1,2);
% stem(freqz(g(t,data)), 'k', 'fill', "MarkerSize", 1);
% legend("FT of Waveform");
% saveas(handle,"10bits.png");
mod_data = g(t,data);
end

