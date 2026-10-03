function [f, P, expectedPower] = windowed_psd(x, Fs, K)
%WINDOWED_PSD One-sided periodogram after demeaning and periodic Hann window.
% Units: input units squared per Hz. expectedPower is the independently
% evaluated window-weighted power used by the Parseval consistency check.
    validateattributes(x, {'numeric'}, {'vector','real','finite','nonempty'});
    validateattributes(Fs, {'numeric'}, {'scalar','real','finite','positive'});
    x = double(x(:));
    L = numel(x);
    if L < 2, error('ECG:ShortPSD', 'PSD requires at least two samples.'); end
    if nargin < 3, K = L; end
    validateattributes(K, {'numeric'}, {'scalar','finite','integer','>=',L});
    w = 0.5-0.5*cos(2*pi*(0:L-1)'/L);
    u = (x-mean(x)).*w;
    X = fft(u,K);
    q = floor(K/2)+1;
    P = abs(X(1:q)).^2/(Fs*sum(w.^2));
    if mod(K,2) == 0
        P(2:end-1) = 2*P(2:end-1);
    else
        P(2:end) = 2*P(2:end);
    end
    f = (0:q-1)'*Fs/K;
    expectedPower = sum(abs(u).^2)/sum(w.^2);
end
