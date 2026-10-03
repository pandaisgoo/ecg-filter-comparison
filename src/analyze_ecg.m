function R = analyze_ecg(D, cfg)
%ANALYZE_ECG Numerical pipeline; no plotting and no filesystem writes.
    if nargin < 2, cfg = ecg_config; end
    x = D.x(:); Fs = D.Fs; t = D.t(:);
    if t(end)<cfg.minimumDurationSeconds
        error('ECG:ShortRecord', 'This workflow requires at least 2.5 seconds.');
    end
    R.config = cfg;
    R.data = D;
    R.filters = design_ecg_filters(Fs,cfg.targetsHz,cfg.poleRadius);
    R.peaks = detect_r_peaks(x,Fs,cfg);
    R.Y = filter_ecg(x,R.filters);

    % A separate deterministic Fourier demonstration: same 240 samples.
    demoFs = 120000; demoN = 240;
    demoT = (0:demoN-1)'/demoFs;
    demoX = cos(2*pi*6000*demoT);
    n = 0:demoN-1;
    Xdirect = exp(-1i*2*pi*(n.'*n)/demoN)*demoX;
    R.demo.relativeError = max(abs(Xdirect-fft(demoX)))/ ...
        max(1,max(abs(fft(demoX))));
    [R.demo.nativeF,R.demo.nativeA] = amplitude_spectrum(demoX,demoFs,demoN);
    [R.demo.denseF,R.demo.denseA] = amplitude_spectrum(demoX,demoFs,4096);

    seg = t>=cfg.segmentSeconds(1) & t<cfg.segmentSeconds(2);
    segment = x(seg);
    if isempty(segment), error('ECG:EmptySegment', 'Selected segment is empty.'); end
    fftLength = 2^nextpow2(D.N);
    [R.spectra.f,R.spectra.full] = amplitude_spectrum(x-mean(x),Fs,fftLength);
    [~,R.spectra.segment] = amplitude_spectrum(segment-mean(segment),Fs,fftLength);
    R.spectra.segmentN = numel(segment);

    fmax = min(cfg.responseMaxHz,0.99*Fs/2);
    R.response.f = linspace(0,fmax,cfg.responsePoints)';
    [R.response.Hma,R.response.gdMA] = frequency_response_delay( ...
        R.filters.bMA,1,R.response.f,Fs);
    [R.response.Hiir,R.response.gdIIR] = cascade_response( ...
        R.filters.bSections,R.filters.aSections,R.response.f,Fs);
    [Hm,gm] = frequency_response_delay(R.filters.bMA,1,cfg.probeHz,Fs);
    [Hi,gi] = cascade_response(R.filters.bSections,R.filters.aSections,cfg.probeHz,Fs);
    R.probeTable = table(cfg.probeHz,20*log10(abs(Hm)),20*log10(abs(Hi)), ...
        1000*gm/Fs,1000*gi/Fs,'VariableNames', ...
        {'Frequency_Hz','FIR_Gain_dB','IIR_Gain_dB', ...
         'FIR_GroupDelay_ms','IIR_GroupDelay_ms'});

    use = t>=cfg.evaluationStartSeconds;
    E = R.Y(use,:); L = size(E,1);
    K = 2^nextpow2(max(cfg.minimumPsdFftFactor*L, ...
        ceil(Fs/cfg.maximumPsdGridSpacingHz)));
    psd = zeros(floor(K/2)+1,3);
    powerCheck = zeros(3,1);
    for k = 1:3
        [f,psd(:,k),powerCheck(k)] = windowed_psd(E(:,k),Fs,K);
    end
    R.evaluation.firstTime = t(find(use,1));
    R.evaluation.lastTime = t(end);
    R.evaluation.N = L;
    R.evaluation.fftLength = K;
    R.evaluation.df = Fs/K;
    R.evaluation.Y = E;
    R.evaluation.f = f;
    R.evaluation.P = psd;
    R.evaluation.expectedPower = powerCheck;
    count = numel(cfg.targetsHz);
    bandPower = zeros(count,3);
    for k = 1:count
        ix = abs(f-cfg.targetsHz(k))<=cfg.bandHalfWidthHz;
        if ~any(ix), error('ECG:EmptyBand', 'No FFT grid point inside a target band.'); end
        bandPower(k,:) = sum(psd(ix,:),1)*(Fs/K);
    end
    reductionMA = reduction_db(bandPower(:,1),bandPower(:,2));
    reductionIIR = reduction_db(bandPower(:,1),bandPower(:,3));
    R.bandTable = table(cfg.targetsHz,bandPower(:,1),bandPower(:,2),bandPower(:,3), ...
        reductionMA,reductionIIR,'VariableNames', ...
        {'Center_Hz','RawBandPower','FIRBandPower','IIRBandPower', ...
         'FIR_Reduction_dB','IIR_Reduction_dB'});

    baseNorm = norm(E(:,1));
    if baseNorm==0, error('ECG:ZeroEvaluationPower', 'Evaluation input has zero power.'); end
    rmsRatio = zeros(3,1); relDiff = zeros(3,1);
    for k = 1:3
        rmsRatio(k) = norm(E(:,k))/baseNorm;
        relDiff(k) = norm(E(:,k)-E(:,1))/baseNorm;
    end
    R.overallTable = table({'Raw';'FIR_MA';'IIR_3_Notches'},rmsRatio,relDiff, ...
        [1;1;R.filters.dcIIR],'VariableNames', ...
        {'Method','RMSRatioToRaw','RelativeDifferenceToRaw','DCGain'});
    R.zoomStart = min(3,t(end)-1);
    R.zoomEnd = R.zoomStart+1;
end

function out = reduction_db(before,after)
    out = NaN(size(before));
    ok = before>0 & after>0;
    out(ok) = 10*log10(before(ok)./after(ok));
end
