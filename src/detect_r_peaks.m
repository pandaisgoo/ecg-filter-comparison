function P = detect_r_peaks(x, Fs, cfg)
%DETECT_R_PEAKS Fixed-threshold candidate peaks, not a clinical detector.
% Normalization is used ONLY for peak selection. Filter inputs remain raw.
    validateattributes(x, {'numeric'}, {'vector','real','finite','nonempty'});
    validateattributes(Fs, {'numeric'}, {'scalar','real','finite','positive'});
    x = double(x(:));
    z = x - mean(x);
    scale = max(abs(z));
    if scale == 0
        error('ECG:DegenerateSignal', 'Cannot normalize a constant signal.');
    end
    z = z / scale;
    separation = max(1, round(cfg.peakDistanceSeconds * Fs));
    [values, locations] = findpeaks(z, ...
        'MinPeakHeight', cfg.peakHeight, 'MinPeakDistance', separation);
    locations = locations(:);
    values = values(:);
    times = (locations-1) / Fs;
    rr = diff(locations) / Fs;
    used = rr > cfg.rrBoundsSeconds(1) & rr < cfg.rrBoundsSeconds(2);
    P.indices = locations;
    P.times = times;
    P.heights = values;
    P.rr = rr;
    P.usedRR = used;
    P.meanRR = NaN;
    P.heartRate = NaN;
    if any(used)
        P.meanRR = mean(rr(used));
        P.heartRate = 60 / P.meanRR;
    end
    P.peakTable = table(locations, times, values, 'VariableNames', ...
        {'SampleIndex','Time_s','NormalizedHeight'});
    P.rrTable = table(times(1:end-1), times(2:end), rr, used, ...
        'VariableNames', {'Start_s','End_s','RR_s','UsedForEstimate'});
end
