function T = validate_numerics(R)
%VALIDATE_NUMERICS Ten consistency checks, recalculated on every run.
% These test numerical identities, not diagnostic accuracy or denoising quality.
    xe = 2.3*cos(2*pi*123*(0:999)'/1000);
    [~,ae] = amplitude_spectrum(xe,1000,1000);
    evenError = abs(ae(124)-2.3);
    xo = 1.7*cos(2*pi*77*(0:1000)'/1001);
    [~,ao] = amplitude_spectrum(xo,1000,1001);
    oddError = abs(ao(78)-1.7);
    x = R.data.x; F = R.filters;
    yconv = conv(x,F.bMA(:));
    firError = max(abs(yconv(1:numel(x))-R.Y(:,2)))/ ...
        max(1,max(abs(R.Y(:,2))));
    expanded = filter(F.bTotal,F.aTotal,x);
    cascadeError = max(abs(expanded-R.Y(:,3)))/max(1,max(abs(R.Y(:,3))));
    valid = abs(R.response.Hma)>1e-3 & isfinite(R.response.gdMA);
    delayError = Inf;
    if any(valid)
        delayError = max(abs(R.response.gdMA(valid)-F.firDelaySamples));
    end
    f = R.config.probeHz;
    calculated = cascade_response(F.bSections,F.aSections,f,R.data.Fs);
    builtIn = freqz(F.bTotal,F.aTotal,2*pi*f/R.data.Fs);
    responseError = max(abs(calculated-builtIn(:)));
    expected = R.evaluation.expectedPower(1);
    psdError = abs(sum(R.evaluation.P(:,1))*R.evaluation.df-expected)/ ...
        max(expected,realmin);
    radius = 0;
    for k = 1:size(F.aSections,1)
        radius = max(radius,max(abs(roots(F.aSections(k,:)))));
    end
    names = {'DFT_vs_FFT';'Amplitude_even_length';'Amplitude_odd_length'; ...
        'FIR_filter_vs_convolution';'IIR_cascade_vs_expanded'; ...
        'FIR_group_delay';'Response_vs_freqz';'PSD_Parseval'; ...
        'IIR_max_pole_radius';'Finite_filter_outputs'};
    values = [R.demo.relativeError;evenError;oddError;firError; ...
        cascadeError;delayError;responseError;psdError;radius; ...
        double(~all(isfinite(R.Y(:))))];
    limits = [1e-10;1e-10;1e-10;1e-10;1e-6;1e-7;1e-6;1e-10;1-1e-12;0];
    passed = isfinite(values) & values<=limits;
    T = table(names,values,limits,passed, ...
        'VariableNames',{'Test','Value','Limit','Passed'});
end
