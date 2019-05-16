function blk_stream = pre_proc(fp, enc_lvl, r, c, do_dct)
%PRE_PROC Pre-processing of the to-be-transmitted image
%   read image from file, convert to grayscale, 
%   convert to double and normalize
%   quantize to 8 bits

% im2double normalizes output to [0,1]
img = imresize(rgb2gray(im2double(imread(fp))),[r,c]);
% blkproc applies dct2 to each 8x8 block in img
if do_dct 
    dct_img = blkproc(img, [8, 8], @dct2);
    fprintf("Performed dct\n");
%     rx_img1 = blkproc(dct_img, [8, 8], @idct2);
%     imshow([rx_img1 img]);
else
    dct_img = img;
end
% uencode quantizes as integers and encodes using 
% 2^3 level quantization
q_dct_img = uencode(dct_img,enc_lvl);
% reshapes image into a stream of 8x8 blocks 
blk_stream = reshape(q_dct_img,numel(q_dct_img),1);
end



