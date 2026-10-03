function S = run_tests(dataFile)
%RUN_TESTS Run unit tests and, when data exists, report consistency checks.
%   S = RUN_TESTS              auto-detect data/ECG.mat or ECG.mat
%   S = RUN_TESTS('path.mat')  explicitly use the reference input
%   S = RUN_TESTS(false)       synthetic tests only
% No report, CSV, or figure is overwritten by this function.
    root = fileparts(mfilename('fullpath'));
    oldPath = path;
    guard = onCleanup(@() path(oldPath)); %#ok<NASGU>
    addpath(fullfile(root,'src'),fullfile(root,'tests'),'-begin');
    if isempty(which('findpeaks')) || isempty(which('freqz'))
        error('ECG:MissingToolbox','Signal Processing Toolbox is required.');
    end
    S.synthetic = test_ecg_functions;
    disp(S.synthetic);
    assert(all(S.synthetic.Passed),'ECG:UnitTestFailure','A unit test failed.');
    if nargin<1 || isempty(dataFile)
        dataFile=fullfile(root,'data','ECG.mat');
        if ~isfile(dataFile), dataFile=fullfile(root,'ECG.mat'); end
        if ~isfile(dataFile), dataFile=false; end
    end
    if isequal(dataFile,false)
        fprintf('Synthetic tests passed: %d/%d. Reference-data tests skipped.\n', ...
            height(S.synthetic),height(S.synthetic));
        return;
    end
    if isstring(dataFile), dataFile=char(dataFile); end
    if isempty(regexp(dataFile,'^([A-Za-z]:[\\/]|[\\/])','once'))
        dataFile=fullfile(root,dataFile);
    end
    R=analyze_ecg(load_ecg_data(dataFile),ecg_config);
    S.numeric=validate_numerics(R);
    S.report=compare_report_values(R);
    disp(S.numeric); disp(S.report);
    assert(all(S.numeric.Passed),'ECG:NumericalCheckFailed','A numerical check failed.');
    assert(all(S.report.Passed),'ECG:ReportMismatch', ...
        'Reference values do not match. Check the input file and parameters.');
    fprintf('Passed: %d unit tests, %d numerical checks, %d rounded-report comparisons.\n', ...
        height(S.synthetic),height(S.numeric),height(S.report));
end
