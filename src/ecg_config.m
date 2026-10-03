function cfg = ecg_config
%ECG_CONFIG Parameters used by the existing ECG comparison report.
% Changing these values creates a different experiment. Reference report
% values are kept separately and are never used to generate new outputs.
    cfg.codeVersion = '1.0.0';
    cfg.targetsHz = [60; 120; 180];
    cfg.poleRadius = 0.95;
    cfg.peakHeight = 0.6;
    cfg.peakDistanceSeconds = 0.6;
    cfg.rrBoundsSeconds = [0.4, 1.5]; % strict lower/upper bounds
    cfg.segmentSeconds = [0.8, 1.6]; % half-open [0.8,1.6)
    cfg.evaluationStartSeconds = 1;
    cfg.bandHalfWidthHz = 1;
    cfg.minimumDurationSeconds = 2.5;
    cfg.responsePoints = 6001;
    cfg.responseMaxHz = 300;
    cfg.probeHz = [5;10;20;40;80;100];
    cfg.minimumPsdFftFactor = 4;
    cfg.maximumPsdGridSpacingHz = 0.1;
    cfg.figureResolutionDpi = 300;
    cfg.figureNames = { ...
        '01_fft_padding.png', '02_ecg_peaks.png', ...
        '03_full_segment_spectra.png', '04_local_comparison.png', ...
        '05_magnitude_response.png', '06_phase_response.png', ...
        '07_group_delay.png', '08_psd_comparison.png'};
    cfg.figureFiles = cellfun(@(n) fullfile('figures', n), ...
        cfg.figureNames, 'UniformOutput', false);
    cfg.resultFiles = { ...
        'r_peak_candidates.csv', 'rr_intervals.csv', 'band_power.csv', ...
        'signal_changes.csv', 'response_probes.csv', 'validation.csv', ...
        'run_summary.csv', 'run_log.txt', 'configuration.json'};
end
