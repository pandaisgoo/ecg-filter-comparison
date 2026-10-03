function F = design_ecg_filters(Fs, targetsHz, r)
%DESIGN_ECG_FILTERS FIR moving average and unnormalized IIR notch cascade.
% Every IIR section keeps b=[1,-2*cos(theta),1] and
% a=[1,-2*r*cos(theta),r^2]. There is no hidden DC-gain normalization.
    validateattributes(Fs, {'numeric'}, {'scalar','real','finite','positive'});
    validateattributes(targetsHz, {'numeric'}, {'vector','real','finite','positive'});
    validateattributes(r, {'numeric'}, {'scalar','real','finite','>',0,'<',1});
    targetsHz = double(targetsHz(:));
    if isempty(targetsHz) || any(diff(targetsHz) <= 0) || any(targetsHz >= Fs/2)
        error('ECG:InvalidTargets', ...
            'Notch frequencies must increase strictly and lie below Fs/2.');
    end
    M = round(Fs/targetsHz(1));
    if abs(Fs/targetsHz(1)-M) > 1e-8 || M < 2
        error('ECG:NonintegerFIRLength', ...
            'Fs/first target must be an integer; do not silently round it.');
    end
    F.M = M;
    F.bMA = ones(1,M)/M;
    F.bSections = zeros(numel(targetsHz),3);
    F.aSections = zeros(numel(targetsHz),3);
    F.bTotal = 1;
    F.aTotal = 1;
    F.targetsHz = targetsHz;
    F.poleRadius = r;
    F.Fs = Fs;
    for k = 1:numel(targetsHz)
        theta = 2*pi*targetsHz(k)/Fs;
        F.bSections(k,:) = [1,-2*cos(theta),1];
        F.aSections(k,:) = [1,-2*r*cos(theta),r^2];
        F.bTotal = conv(F.bTotal,F.bSections(k,:));
        F.aTotal = conv(F.aTotal,F.aSections(k,:));
    end
    F.firDelaySamples = (M-1)/2;
    F.firDelayMs = 1000*F.firDelaySamples/Fs;
    F.dcIIR = real(cascade_response(F.bSections,F.aSections,0,Fs));
end
