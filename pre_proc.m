function blk_stream = pre_proc(fp, enc_lvl)
%PRE_PROC Pre-processing of the to-be-transmitted image
%   read image from file, convert to grayscale, 
%   convert to double and normalize
%   quantize to 8 bits

% im2double normalizes output to [0,1]
img = im2double(rgb2gray(imread(fp)));
% blkproc applies dct2 to each 8x8 block in img
dct_img = blkproc(img, [8, 8], @dct2);
% uencode quantizes as integers and encodes using 
% 2^3 level quantization
q_dct_img = uencode(dct_img,enc_lvl);
% reshapes image into a stream of 8x8 blocks 
len = numel(q_dct_img)/64;
blk_stream = reshape(q_dct_img,8,8,len);
end



