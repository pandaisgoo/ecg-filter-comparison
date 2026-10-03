function [H, gd] = frequency_response_delay(b, a, f, Fs)
%FREQUENCY_RESPONSE_DELAY H and analytic group delay in samples.
% gd = -imag(B'/B - A'/A), where primes differentiate w.r.t. rad/sample.
% Values at response zeros are undefined and returned as NaN.
    validateattributes(b, {'numeric'}, {'vector','finite','nonempty'});
    validateattributes(a, {'numeric'}, {'vector','finite','nonempty'});
    validateattributes(f, {'numeric'}, {'vector','real','finite','nonempty'});
    validateattributes(Fs, {'numeric'}, {'scalar','real','finite','positive'});
    b = double(b(:)); a = double(a(:));
    if a(1)==0, error('ECG:InvalidDenominator', 'a(1) must be nonzero.'); end
    omega = 2*pi*double(f(:))/Fs;
    kb = (0:numel(b)-1)'; ka = (0:numel(a)-1)';
    Eb = exp(-1i*omega*kb.'); Ea = exp(-1i*omega*ka.');
    B = Eb*b; A = Ea*a;
    Bp = Eb*((-1i*kb).*b); Ap = Ea*((-1i*ka).*a);
    H = B./A;
    gd = NaN(size(H));
    ok = abs(B)>1e-10 & abs(A)>1e-10;
    gd(ok) = -imag(Bp(ok)./B(ok)-Ap(ok)./A(ok));
end
