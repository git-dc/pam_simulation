function [new_img] = post_proc(rx_strm)
%POST_PROC Post-processing of the transmitted image
%   read image from file, convert to grayscale, 
%   convert to double and normalize
%   quantize to 8 bits

% reshape mold the stream into 3 bit chunks
size(rx_strm)
bit_strm = reshape(rx_strm,1024*156,8);
size(bit_strm)
dct_img = bi2de(bit_strm);
size(dct_img)
dct_img = reshape(dct_img,8,8,2496);
% blkproc applies dct2 to each 8x8 block in dct_img
% new_img = 
blkproc(dct_img, [8, 8], @dct2);

end

