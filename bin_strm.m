function bin_strm = bin_strm(N,data_strm,enc_lvl)
%CONVERT_TO_STREAM Converts quantized image to bit stream
%   Groups DCT image blocks into groups of size N,
%   returns a matrix with rows = bits of the 8-bit elements
%   and as many columns as there are elements

% data stream comes in as n slices of dim 8x8 
n = size(data_strm, 3);
% number of blocks of N slices, 8x8 each 
% slice, in the output stream
n_blks = int32(n/N);
% allocate space for the output stream
% the blocks will be flattened to length 
% Nx8x8 and converted to binary
bin_strm = zeros(N*8*8, enc_lvl, n_blks);
for k = 1:n_blks-1
    % the last block may not be full:
    blk_size = min(N, n-k*N);
    % splice the block out of the stream
    blk = data_strm(:, :, k*N:k*N+blk_size-1);
    % calculate if the block is smaller than
    % Nx8x8 and pad - mainly for the last block
    resid = double(N - blk_size);
    padded = padarray(blk, [0, 0, resid], 0, 'post');
    % flatten the block then convert to binary
    len = numel(padded);
    dec_blk = reshape(padded, 1, len);
    bin_strm(:, :, k) = de2bi(dec_blk);
end
end