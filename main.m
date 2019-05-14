close all;
clear all;


N = 16;     % block size
T = 32;     % sine wave half period
bd = 1/T;   % bit duration, i.e. repeat same bit T times
sigma = 0.001;  % noise power
ns = 20;    % number of bits in test sample
enc_lvl = 8;


h = [1 zeros(1,31) 2/3 zeros(1,31) 3/4 zeros(1,31) -2/7 zeros(1,31)];
% h = [1 zeros(1,127) ];

quantized_img = pre_proc("dc.jpg", enc_lvl);


bit_strm = bin_strm(N, quantized_img, enc_lvl);
% rx_img = post_proc(bit_strm);
% imshow(rx_img);

mod_bit_strm = zeros(N*8*8*enc_lvl*T, size(bit_strm,3));
for k = 1:size(bit_strm,3)
    hunk = bit_strm(:,:,k);
    chunk = reshape(hunk, 1, numel(hunk));
    mod_bit_strm(:,k) = modulate(chunk,1,bd);
end
T=1;
t = 0:1/31:1;
pulsesine = sin(pi*t/T); 
Amp=sqrt(sum(pulsesine.^2));
Amp = 1/Amp;
pulse = Amp.*pulsesine;

dataN = mod_bit_strm;
%% Matched Filter
% MF=dataN(end:-1:1);
MF=pulse(end:-1:1);
MF=[MF'];
dataM=filter(MF,1,dataN);
subplot(2,1,1);plot(dataN(1:640));
subplot(2,1,2);plot(dataM(1:640));
% eyediagram(dataM(1:3200), 64);
% dataMa=dataM(16:end);
eyediagram(dataM(1:3200), 64);
% dataM=dataMa;
%% channel impairment compensation 
% ZF Equalizer inverse of B(z)/A(z)

dataCC=filter(1,h,dataM);

%% minimum mean square error (MMSE)
var =  sqrt(sigma);
Hc=fft(h);
Hm=conj(Hc)./(abs(Hc).^2+var.^2);
dataME=ifft(Hm.*dataN);

dataM=dataME;


%%
% Demodulation
demod=dataCC(32:32:end);

%% Detection

Rx=demod>0;   %threshold detection


%% decoding
RxDC=Rx(1:size(data,1));
rawR=RxDC;
error=sum(raw~=rawR)/size(data,1)          % percentage of errorrness bit
RxDC=reshape(RxDC,[b row*col]); 
RxDC=RxDC';
[r c]=size(RxDC);
 
RxDC = reshape(char(RxDC + '0'),r,c);
dataR=bin2dec(RxDC(:,:));
dataR=reshape(dataR,[row col]);
dataR=uint8(dataR);
dataR = udecode(dataR,b);
imshow(dataR) 

