function eq_bit_strm = equalizer(matched_bit_strm, eq_type, h, sigma, N)
%EQUALIZER Summary of this function goes here
%   Detailed explanation goes here



switch eq_type
    case "zf"
        % Zero-Forcing equalization:
        eq_bit_strm = zeros(size(matched_bit_strm));
        for k = 1:N
            chunk = matched_bit_strm(k,:);
            eq_bit_strm(k,:) = filter(1,h,chunk);
        end
    case "mmse"
        % Minimum mean square error equalization:
        eq_bit_strm = zeros(size(matched_bit_strm));
        H = fft(h);
        Hm = conj(H)./(abs(H).^2 + sigma^2);
        for k = 1:N
            chunk = matched_bit_strm(k,:);
            eq_bit_strm(k,:) = sum(ifft(Hm'.*chunk));
        end
end
end

