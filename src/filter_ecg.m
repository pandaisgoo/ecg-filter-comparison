function Y = filter_ecg(x, F)
%FILTER_ECG Same causal, zero-state processing for both filter designs.
% Columns are raw input, FIR output, and full IIR-cascade output.
% No filtfilt, resampling, gain normalization, or time alignment is applied.
    validateattributes(x, {'numeric'}, {'vector','real','finite','nonempty'});
    x = double(x(:));
    yMA = filter(F.bMA,1,x);
    yIIR = x;
    for k = 1:size(F.bSections,1)
        yIIR = filter(F.bSections(k,:),F.aSections(k,:),yIIR);
    end
    Y = [x,yMA,yIIR];
end
