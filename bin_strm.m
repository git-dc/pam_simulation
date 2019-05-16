function bit_strm = bin_strm(N,data_strm,enc_lvl)
%CONVERT_TO_STREAM Converts quantized image to bit stream
%   Groups DCT image blocks into groups of size N,
%   returns a matrix with rows = bits of the 8-bit elements
%   and as many columns as there are elements

n = numel(data_strm);
% number of symbols per block
blk_n = int32(n/N);
% allocate space for the output stream
% the blocks will be flattened to length 
% blk_n and converted to binary
% data_strm = data_strm
if mod(n, N) ~= 0
    exc = MException("toolsetname:other_identifying_information","Stream size has to be divisible by number of blocks: mod(%d, %d) = %d",n,N, mod(n,N));
    throw(exc)
else
bit_strm = zeros(N, blk_n*enc_lvl);
for k = 1:N
    % splice the block out of the stream
    blk = data_strm((k-1)*blk_n+1:k*blk_n);
    bin_blk = de2bi(blk, 'left-msb')';
    bit_strm(k,:) = bin_blk(:);
end
end
end