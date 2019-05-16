function [matched_bit_strm] = match(mod_bit_strm, pulse)
%MATCH Summary of this function goes here
%   Detailed explanation goes here

pusle=pulse(end:-1:1);
pusle=[pusle'];
matched_bit_strm=filter(pusle,1,mod_bit_strm);

end

