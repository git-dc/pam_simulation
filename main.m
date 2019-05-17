close ALL;
clearvars;

% Hyperparameters
fn = 'srrc';            % modulation pulse function
do_dct = 0;                 % perform dct
eq = 'mmse';                  % equalizer
sigma = 0.25;              % noise power
% h = [1 zeros(1,127) ];     % dummy channel impulse response
% h = [1 zeros(1,31) 0.5 zeros(1,31) 0.75 zeros(1,31) -2/7 zeros(1,31)]; % testing channel
% h = [ 1/2 zeros(1,31) 1 zeros(1,63) 0.63 zeros(1,159) 0.25 zeros(1,127) 0.16 zeros(1,511) 0.1]; % outdoor channel
h = [1 0.4365 0.1905 0.0832 zeros(1,63) 0.0158 zeros(1,63) 0.003];  % indoor channel
gain = sum(h.^2);

plots = 0;
sbc = 6;                    % number of subplots
i = 1;                      % subplot index
sb = 100;                     % starting bit for viz
dur = 50;                   % number of bits to viz
padding = zeros(16,10);

N = 16;                     % block size
T = 32;                     % sample period
bd = 1/T;                   % bit duration, i.e. repeat same bit T times
enc_lvl = 8;                % encoding level
row = 64;                   % height of image
col = row;                  % width of image
fp = "dc_64.jpg";           % file pointer
img = imresize(rgb2gray(im2double(imread(fp))),[row,col]); % transmitted image


% Pre-processing and encoding
q_img = pre_proc(fp, enc_lvl, row, col, do_dct);
bit_strm = bin_strm(N, q_img, enc_lvl);
if fn == "srrc"
    bit_strm = [bit_strm padding];
end
% Modulation:
mod_bit_strm = zeros(N, size(bit_strm,2)*T);
for k = 1:N
    chunk = bit_strm(k,:);
    [mod_bit_strm(k,:),pulse] = modulate(chunk,fn,bd);
end

% Channel:
channeled_bit_strm = zeros(size(mod_bit_strm));
for k = 1:N
    chunk = mod_bit_strm(k,:);
    channeled_bit_strm(k,:) = channel(chunk,h,sigma);
end

% Matching:
matched_bit_strm = zeros(size(channeled_bit_strm));
for k = 1:N
    chunk = channeled_bit_strm(k,:);
    matched_bit_strm(k,:) = match(chunk, pulse);
end

% Equalization: 'zf' for zero forcing, 'mmse' for mmse
eq_bit_strm = equalizer(matched_bit_strm, eq, h, sigma, N);

% Demodulation and sampling:
demod_bit_strm = zeros(N,size(eq_bit_strm,2)/T);
for k = 1:N
    chunk = eq_bit_strm(k,:);
    demod_bit_strm(k,:) = chunk(32:32:end);
end

% Rectifying:
rx_strm = demod_bit_strm>0;

% Decoding:
if fn == "srrc"
rx_strm = rx_strm(:,5:end-6);
end

rx_img = post_proc(rx_strm, row, col, enc_lvl, do_dct);
error = 0;
for k = 1:N
    error = error + sum(rx_img(:)~=img(:)) / size(img(:),1);          % percentage of errorrness bit
end

% Received image:
figure;imshow([rx_img img]);

snr = 20* log10 (sum(eq_bit_strm(:).^2)/(sigma*numel(eq_bit_strm(:))));

fprintf('RMS Error: %.2g\n\n',sqrt(error));
fprintf('SNR: %.2g\n\n',SNR);
fprintf('Channel Gain: %.2g\n\n',gain);

% Plots:
if plots
figure;
subplot(sbc,1,i);stem(bit_strm(1,sb+1:sb+dur));
ylabel("raw");
xlim([0.5,dur+0.5]);
i=i+1;

subplot(sbc,1,i);plot(mod_bit_strm(1,T*sb:T*(sb+dur)));
ylabel("modulated");
xlim([1,T*dur]);
i=i+1;

subplot(sbc,1,i);plot(channeled_bit_strm(1,T*sb:T*(sb+dur)));
ylabel("channeled");
xlim([1,T*dur]);
i=i+1;

subplot(sbc,1,i);plot(matched_bit_strm(1,T*sb:T*(sb+dur)));
ylabel("matched");
xlim([1,T*dur]);
i=i+1;

subplot(sbc,1,i);plot(eq_bit_strm(1,T*sb:T*(sb+dur)));
ylabel("zf");
xlim([1,T*dur]);
i=i+1;

subplot(sbc,1,i);stem(rx_strm(1,sb+1:sb+dur));
ylabel("rx_strm");
xlim([0.5,dur+0.5]);
i=i+1;
end