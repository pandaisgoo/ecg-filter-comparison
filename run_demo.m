function R = run_demo(dataFile, varargin)
%RUN_DEMO ECG spectral analysis and FIR/IIR comparison.
%   R = RUN_DEMO loads data/ECG.mat (or ECG.mat beside this file).
%   R = RUN_DEMO([], 'OutputDir', 'results_check', ...
%                'CompareWithReport', true) runs without changing the report.
%   R = RUN_DEMO([], 'Overwrite', true) replaces managed files in results/.
%
% Needs MATLAB and Signal Processing Toolbox. Input may contain ECG and
% either Fs or ECG_Fs. Amplitude is never silently rescaled before filtering.
% This entry point writes results ONLY; it does not write README or reports.
% Figures are generated with a white background, independently of UI theme.

    root = fileparts(mfilename('fullpath'));
    oldPath = path;
    pathGuard = onCleanup(@() path(oldPath)); %#ok<NASGU>
    addpath(fullfile(root, 'src'), '-begin');
    if nargin < 1, dataFile = []; end
    if isempty(dataFile)
        dataFile = fullfile(root, 'data', 'ECG.mat');
        if ~isfile(dataFile), dataFile = fullfile(root, 'ECG.mat'); end
    else
        dataFile = resolve_path(root, dataFile);
    end

    p = inputParser;
    p.FunctionName = mfilename;
    addParameter(p, 'OutputDir', fullfile(root, 'results'), @is_text_scalar);
    addParameter(p, 'Overwrite', false, @is_logical_scalar);
    addParameter(p, 'MakeFigures', true, @is_logical_scalar);
    addParameter(p, 'CompareWithReport', false, @is_logical_scalar);
    parse(p, varargin{:});
    opts = p.Results;
    outputDir = resolve_path(root, opts.OutputDir);
    cfg = ecg_config;

    if isempty(which('findpeaks')) || isempty(which('freqz'))
        error('ECG:MissingToolbox', ...
            'Signal Processing Toolbox is required (findpeaks and freqz).');
    end
    managed = [cfg.resultFiles, cfg.figureFiles, {'report_comparison.csv'}];
    for k = 1:numel(managed)
        if ~opts.Overwrite && isfile(fullfile(outputDir, managed{k}))
            error('ECG:OutputExists', ...
                ['Output already exists: %s\nUse another OutputDir, ' ...
                 'or explicitly set ''Overwrite'', true.'], ...
                fullfile(outputDir, managed{k}));
        end
    end
    % Do not leave a stale optional comparison in an overwritten run.
    if opts.Overwrite && ~opts.CompareWithReport && ...
            isfile(fullfile(outputDir, 'report_comparison.csv'))
        error('ECG:StaleReference', ...
            ['This directory has report_comparison.csv. Use a new OutputDir ' ...
             'or set ''CompareWithReport'', true.']);
    end
    if opts.Overwrite && ~opts.MakeFigures && isfolder(fullfile(outputDir,'figures'))
        error('ECG:StaleFigures', ...
            'For a no-figure run, use a new OutputDir to avoid stale figures.');
    end

    D = load_ecg_data(dataFile);
    R = analyze_ecg(D, cfg);
    R.validationTable = validate_numerics(R);
    if ~all(R.validationTable.Passed)
        disp(R.validationTable);
        error('ECG:NumericalCheckFailed', ...
            'A numerical consistency check failed; no output was committed.');
    end
    R.referenceComparison = table;
    if opts.CompareWithReport
        R.referenceComparison = compare_report_values(R);
        if ~all(R.referenceComparison.Passed)
            warning('ECG:ReportMismatch', ...
                ['Values do not match the rounded reference report. ' ...
                 'Results are kept as computed; no values are substituted.']);
        end
    end
    R.runTime = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    R.matlabVersion = version;
    R.outputDir = outputDir;
    R.figuresGenerated = opts.MakeFigures;

    % Generate in a temporary directory first. If plotting fails, existing
    % report images and CSVs are not overwritten by a partial new run.
    parentDir = fileparts(outputDir);
    if ~isfolder(parentDir), mkdir(parentDir); end
    stage = tempname(parentDir);
    mkdir(stage);
    stageGuard = onCleanup(@() remove_stage(stage)); %#ok<NASGU>
    if opts.MakeFigures
        plot_ecg_results(R, fullfile(stage, 'figures'));
    end
    write_ecg_results(R, stage);
    listing = dir(fullfile(stage, '**', '*'));
    listing = listing(~[listing.isdir]);
    if ~isfolder(outputDir), mkdir(outputDir); end
    % Preflight every destination before copying; never copy unrelated files.
    for k = 1:numel(listing)
        source = fullfile(listing(k).folder, listing(k).name);
        rel = source(numel(stage)+2:end);
        if ~opts.Overwrite && isfile(fullfile(outputDir, rel))
            error('ECG:OutputExists', 'Destination appeared during run: %s', rel);
        end
    end
    for k = 1:numel(listing)
        source = fullfile(listing(k).folder, listing(k).name);
        rel = source(numel(stage)+2:end);
        destination = fullfile(outputDir, rel);
        folder = fileparts(destination);
        if ~isfolder(folder), mkdir(folder); end
        [ok, msg] = copyfile(source, destination, 'f');
        if ~ok, error('ECG:CopyFailed', '%s', msg); end
    end

    fprintf('\nECG analysis complete: %s\n', outputDir);
    fprintf('Fs = %.10g Hz; N = %d; FIR length = %d\n', D.Fs, D.N, R.filters.M);
    fprintf('Candidate peaks = %d; estimated rate = %.6f bpm\n', ...
        numel(R.peaks.indices), R.peaks.heartRate);
    fprintf('Numerical checks: %d/%d passed.\n', ...
        sum(R.validationTable.Passed), height(R.validationTable));
    if opts.CompareWithReport
        fprintf('Rounded-report comparison: %d/%d matched.\n', ...
            sum(R.referenceComparison.Passed), height(R.referenceComparison));
    end
    disp(R.bandTable);
    fprintf('README, LaTeX, and report PDF were not changed.\n');
end

function p = resolve_path(root, p)
    if ~is_text_scalar(p)
        error('ECG:InvalidPath', 'Path must be a character vector or string scalar.');
    end
    p = char(p);
    if isempty(p), error('ECG:InvalidPath', 'Path cannot be empty.'); end
    if isempty(regexp(p, '^([A-Za-z]:[\\/]|[\\/])', 'once'))
        p = fullfile(root, p);
    end
end

function tf = is_text_scalar(v)
    tf = (ischar(v) && isrow(v)) || (isstring(v) && isscalar(v));
end

function tf = is_logical_scalar(v)
    tf = islogical(v) && isscalar(v);
end

function remove_stage(folder)
    if isfolder(folder), rmdir(folder, 's'); end
end
