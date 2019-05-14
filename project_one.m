close all
clear all

%% adjustable parameters
row= 256;               % image reshape dimension
col = 256;
b=8;                    %number of bit for quantization
noisepower = .005;
noisepower = .05;
% noisepower = .25;
modfun = 'halfsine';         % pulse shaping function {'halfsine', 'SRRC'}
K = 6;                       % truncation length for SRRC pulse                
alpha = 0.5;                  % roll-off factor for SRRC pulse



%% image preparation
I=imread('Sample_Image.jpg');
I=im2double(I);
I=rgb2gray(I);
I = imresize(I, [row col]);
I = uencode(I,b);                   % intensity between [0,2^8] integer uencode(I,b)
%%
%encoding
data=I(:);   % converting into column vector, we need data=reshape(data,[row col]) at Rx end
data=dec2bin(data);   %bin2dec
data=data';  %transpose for reshape
data=data(:); %converting into column vector,  we need data=reshape(data,[row*col b]) at Rx end
data=regexprep(data',' ','');
data = data-'0';
data=data';

%% Modulation
%Half-sine or SRRC waveform 

T=1;
t = 0:1/31:1; 
pulsesine = sin(pi*t/T); 
Amp=sqrt(sum(pulsesine.^2));
Amp = 1/Amp;

switch modfun
    case 'halfsine'
            pulse=Amp.*pulsesine;
end


figure
plot(pulse);
title(' pulse waveform')
xlabel('Time')
ylabel('Value')


mod=data*pulse + (data-1)*pulse;
mod=mod';
mod=mod(:);
raw=data;
eyediagram(mod(1:3200), 64);

%% channel
hc = [1; zeros(31,1); 0.5 ;zeros(31,1) ;0.75 ;zeros(31,1) ; (-2/7)];
% hc=[1];                  % model for ideal channel
N=size(hc,1);
t = (0:N);
f = (-N/2:N/2-1)/N;
hc=hc';
% dataC=conv(mod, hc);
dataC=filter(hc,1,mod); 
% plot(f,log10(abs(fftshift(fft(hc)))));
%% Noise

var =  sqrt(noisepower);
noise = var .* rand(size(dataC));
dataN=dataC+noise;
eyediagram(dataN(1:3200), 64);

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

dataCC=filter(1,hc,dataM);

%% minimum mean square error (MMSE)

Hc=fft(hc);
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


