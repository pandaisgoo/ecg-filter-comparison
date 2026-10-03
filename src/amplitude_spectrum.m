function [f, A] = amplitude_spectrum(x, Fs, K)
%AMPLITUDE_SPECTRUM Correctly scaled single-sided spectrum for real data.
% Scale by ORIGINAL sample count, not padded FFT length. Double only bins
% that have a distinct negative-frequency partner (even/odd K handled).
    validateattributes(x, {'numeric'}, {'vector','real','finite','nonempty'});
    validateattributes(Fs, {'numeric'}, {'scalar','real','finite','positive'});
    x = double(x(:));
    L = numel(x);
    if nargin < 3, K = L; end
    validateattributes(K, {'numeric'}, {'scalar','finite','integer','>=',L});
    X = fft(x,K);
    q = floor(K/2)+1;
    A = abs(X(1:q))/L;
    if mod(K,2) == 0
        A(2:end-1) = 2*A(2:end-1);
    else
        A(2:end) = 2*A(2:end);
    end
    f = (0:q-1)'*Fs/K;
end
