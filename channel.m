function out_strm = channel(stream, h, sigma)
%CHANNE Channel model
%   filter with the given below impulse response 
%   that models echoing of signal
%   also applies gaussian noise as a physical channel would
%   h[n] = h(nT ) = δ[n] + 1/2 δ[n − 1] + 3/4 δ[n − 2] − 2/7 δ[n − 3],    
%   h - impulse response of channel

% freqz(h);
% plot(fft(h));
echoed = filter(h,1,stream);
% add gaussian noise with power sigma
out_strm = echoed + sigma*randn(size(echoed));
end

