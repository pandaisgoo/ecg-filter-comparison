function T = test_ecg_functions
%TEST_ECG_FUNCTIONS Deterministic unit tests; ECG.mat is not required.
    names = {}; values = []; tolerances = [];
    [f,A] = amplitude_spectrum(3*ones(128,1),1000,256);
    record('DC_amplitude',abs(A(1)-3),1e-12);
    [~,A] = amplitude_spectrum(2.5*(-1).^(0:127)',1000,128);
    record('Nyquist_not_doubled',abs(A(end)-2.5),1e-12);
    record('Frequency_grid',abs(f(end)-500),1e-12);
    [~,A] = amplitude_spectrum(1.8*cos(2*pi*16*(0:127)'/128),1024,1024);
    record('Zero_padding_scales_by_original_N',abs(A(129)-1.8),1e-12);
    s = cos(2*pi*37*(0:1000)'/1001)+0.1*sin(2*pi*3*(0:1000)'/1001);
    [~,P,power] = windowed_psd(s,1000,3001);
    record('Odd_PSD_Parseval',abs(sum(P)*(1000/3001)-power),1e-11);
    F = design_ecg_filters(1800,[60;120;180],0.95);
    impulse = [1;zeros(511,1)]; Y = filter_ecg(impulse,F);
    record('FIR_impulse',max(abs(Y(1:30,2)-1/30)),1e-14);
    record('FIR_tail',max(abs(Y(31:end,2))),1e-14);
    record('Original_input_preserved',max(abs(Y(:,1)-impulse)),0);
    H = cascade_response(F.bSections,F.aSections,[60;120;180],1800);
    record('Notch_zeros',max(abs(H)),1e-10);
    fprobe = [2;5;10;20;40;80;100];
    [~,gd] = frequency_response_delay(F.bMA,1,fprobe,1800);
    record('FIR_fixed_delay',max(abs(gd-14.5)),1e-10);
    s = sin((0:999)'*0.13)+0.4*cos((0:999)'*0.037);
    Y = filter_ecg(s,F); scaled = filter_ecg(7*s,F);
    record('Filter_linearity_scale',max(abs(scaled(:)-7*Y(:))),1e-10);
    cfg = ecg_config;
    signal = zeros(10000,1); signal([501,1941,3381,4821,6261,7701,9141])=1;
    peaks = detect_r_peaks(signal,1800,cfg);
    record('Synthetic_candidate_count',abs(numel(peaks.indices)-7),0);
    record('Synthetic_rate',abs(peaks.heartRate-75),1e-10);
    record('Reject_bad_FIR_length',double(~throws( ...
        @()design_ecg_filters(1000,[60;120;180],0.95))),0);
    record('Reject_Nyquist_target',double(~throws( ...
        @()design_ecg_filters(300,[60;120;180],0.95))),0);
    record('Reject_unstable_radius',double(~throws( ...
        @()design_ecg_filters(1800,[60;120;180],1))),0);
    record('Reject_short_FFT',double(~throws( ...
        @()amplitude_spectrum(ones(10,1),1000,8))),0);
    passed = isfinite(values) & values<=tolerances;
    T = table(names,values,tolerances,passed, ...
        'VariableNames',{'Test','Value','Limit','Passed'});

    function record(name,value,tolerance)
        names{end+1,1}=name;
        values(end+1,1)=value;
        tolerances(end+1,1)=tolerance;
    end
end

function tf = throws(fun)
    tf=false;
    try
        fun();
    catch
        tf=true;
    end
end
