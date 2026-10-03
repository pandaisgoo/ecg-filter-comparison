function [H, gd] = cascade_response(bs, as, f, Fs)
%CASCADE_RESPONSE Product response and additive group delay of IIR sections.
    if size(bs,1)~=size(as,1) || isempty(bs) || isempty(as)
        error('ECG:InvalidCascade', 'Numerator/denominator section counts differ.');
    end
    H = ones(numel(f),1);
    gd = zeros(numel(f),1);
    for k = 1:size(bs,1)
        [hk,gk] = frequency_response_delay(bs(k,:),as(k,:),f,Fs);
        H = H.*hk;
        gd = gd+gk;
    end
end
