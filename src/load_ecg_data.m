function D = load_ecg_data(filename)
%LOAD_ECG_DATA Validate and load ECG plus Fs or ECG_Fs, without rescaling.
    if ~(ischar(filename) || (isstring(filename) && isscalar(filename)))
        error('ECG:InvalidPath', 'Data path must be text.');
    end
    filename = char(filename);
    if ~isfile(filename)
        error('ECG:MissingData', ...
            'File not found: %s. Put ECG.mat in data/ or pass its path.', filename);
    end
    S = load(filename);
    if ~isfield(S, 'ECG')
        error('ECG:MissingSignal', 'MAT file must contain the vector ECG.');
    end
    if isfield(S, 'Fs')
        fs = S.Fs;
        if isfield(S, 'ECG_Fs') && ~isequal(double(S.Fs), double(S.ECG_Fs))
            error('ECG:AmbiguousRate', 'Fs and ECG_Fs disagree.');
        end
    elseif isfield(S, 'ECG_Fs')
        fs = S.ECG_Fs;
    else
        error('ECG:MissingRate', 'MAT file must contain Fs or ECG_Fs.');
    end
    validateattributes(S.ECG, {'numeric'}, ...
        {'vector','real','finite','nonempty'}, mfilename, 'ECG');
    validateattributes(fs, {'numeric'}, ...
        {'scalar','real','finite','positive'}, mfilename, 'Fs');
    D.x = double(S.ECG(:));
    D.Fs = double(fs);
    D.N = numel(D.x);
    D.t = (0:D.N-1)' / D.Fs;
    if D.N < 3 || max(D.x) == min(D.x)
        error('ECG:DegenerateSignal', 'ECG must be a nonconstant vector.');
    end
    [~, name, ext] = fileparts(filename);
    D.sourceName = [name, ext]; % omit the user's private absolute path
    D.inputMinimum = min(D.x);
    D.inputMaximum = max(D.x);
    D.inputMean = mean(D.x);
end
