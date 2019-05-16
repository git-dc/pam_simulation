function [new_img] = post_proc(rx_strm, r, c, enc_lvl, do_dct)
%POST_PROC Post-processing of the transmitted image
%   read image from file, convert to grayscale, 
%   convert to double and normalize
%   quantize to 8 bits

% reshape mold the stream into k bit chunks
rx_strm = rx_strm';
rx_strm = rx_strm(:);
rx_strm = reshape(rx_strm,enc_lvl,[])';
rx_img = bi2de(rx_strm, 'left-msb');
rx_img = reshape(rx_img, c, r);
rx_img = uint8(rx_img);
rx_img = udecode(rx_img,enc_lvl);
if do_dct
    % blkproc applies idct2 to each 8x8 block in dct_img
    rx_img = blkproc(rx_img, [8, 8], @idct2);
    fprintf("Performed idct\n");
end

new_img = rx_img;
end

