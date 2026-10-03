function plot_ecg_results(R, folder)
%PLOT_ECG_RESULTS Eight white-background PNGs, with original output filenames.
% All y-values are calculated data, not recolored screenshots. Axes and
% labels explicitly use light-mode styling, including the exported margins.
    if ~isfolder(folder), mkdir(folder); end
    cfg = R.config;
    Fs = R.data.Fs; t = R.data.t; x = R.data.x;
    for id = 1:8
        [h,ax] = white_figure;
        closer = onCleanup(@() close_if_valid(h));
        switch id
            case 1
                plot(ax,R.demo.nativeF/1000,R.demo.nativeA,'o', ...
                    R.demo.denseF/1000,R.demo.denseA,'-','LineWidth',1.3);
                xlim(ax,[4,8]); ylim(ax,[0,1.2]);
                xlabel(ax,'Frequency (kHz)'); ylabel(ax,'Single-sided amplitude');
                title(ax,'Same 240 samples: FFT and zero-padding');
                legend(ax,{'240-point FFT','4096-point FFT'},'Location','best');
            case 2
                plot(ax,t,x,'-','LineWidth',1);
                hold(ax,'on');
                plot(ax,R.peaks.times,x(R.peaks.indices),'o','MarkerSize',5);
                xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude (input units)');
                title(ax,'ECG and candidate R peaks');
                legend(ax,{'ECG','Candidate peaks'},'Location','best');
            case 3
                plot(ax,R.spectra.f,R.spectra.full,'-', ...
                    R.spectra.f,R.spectra.segment,'--','LineWidth',1);
                xlim(ax,[0,min(200,Fs/2)]);
                xlabel(ax,'Frequency (Hz)');
                ylabel(ax,'One-sided amplitude (input units)');
                title(ax,'Full record and 0.8-1.6 s segment; mean removed');
                legend(ax,{'Full record','0.8-1.6 s segment'},'Location','best');
            case 4
                use = t>=R.zoomStart & t<=R.zoomEnd;
                plot(ax,t(use),R.Y(use,1),'-',t(use),R.Y(use,2),'--', ...
                    t(use),R.Y(use,3),':','LineWidth',1.25);
                xlim(ax,[R.zoomStart,R.zoomEnd]);
                xlabel(ax,'Time (s)'); ylabel(ax,'Amplitude (input units)');
                title(ax,'Causal filtering comparison; no time alignment');
                legend(ax,{'Raw','FIR moving average','Three-section IIR'},'Location','best');
            case 5
                plot(ax,R.response.f,20*log10(max(abs(R.response.Hma),1e-5)),'-', ...
                    R.response.f,20*log10(max(abs(R.response.Hiir),1e-5)),'--', ...
                    'LineWidth',1.25);
                ylim(ax,[-80,5]);
                xlabel(ax,'Frequency (Hz)'); ylabel(ax,'Gain (dB)');
                title(ax,'Filter magnitude responses');
                legend(ax,{'FIR moving average','Three-section IIR'},'Location','best');
            case 6
                ma = angle(R.response.Hma); ii = angle(R.response.Hiir);
                ma(abs(R.response.Hma)<1e-7)=NaN;
                ii(abs(R.response.Hiir)<1e-7)=NaN;
                plot(ax,R.response.f,ma,'-',R.response.f,ii,'--','LineWidth',1.1);
                xlabel(ax,'Frequency (Hz)'); ylabel(ax,'Wrapped phase (rad)');
                title(ax,'Phase responses; zeros are omitted');
                legend(ax,{'FIR moving average','Three-section IIR'},'Location','best');
            case 7
                plot(ax,R.response.f,1000*R.response.gdMA/Fs,'-', ...
                    R.response.f,1000*R.response.gdIIR/Fs,'--','LineWidth',1.25);
                xlabel(ax,'Frequency (Hz)'); ylabel(ax,'Group delay (ms)');
                title(ax,'Group delay; undefined values at zeros are omitted');
                legend(ax,{'FIR moving average','Three-section IIR'},'Location','best');
            case 8
                f = R.evaluation.f; P = R.evaluation.P;
                plot(ax,f,10*log10(max(P(:,1),realmin)),'-', ...
                    f,10*log10(max(P(:,2),realmin)),'--', ...
                    f,10*log10(max(P(:,3),realmin)),':','LineWidth',1);
                xlim(ax,[0,min(200,Fs/2)]);
                xlabel(ax,'Frequency (Hz)'); ylabel(ax,'PSD (dB, input units squared/Hz)');
                title(ax,'Same analysis interval; periodic Hann window');
                legend(ax,{'Raw','FIR moving average','Three-section IIR'},'Location','best');
        end
        grid(ax,'on'); box(ax,'on');
        % plot() can reset axes defaults: enforce colors again after plotting.
        set(ax,'Color','w','XColor','k','YColor','k', ...
            'GridColor',[0.65,0.65,0.65],'GridAlpha',0.3,'FontSize',11);
        texts = findall(h,'Type','text');
        set(texts,'Color','k');
        legends = findall(h,'Type','legend');
        set(legends,'Color','w','TextColor','k','EdgeColor',[0.4,0.4,0.4]);
        drawnow;
        output = fullfile(folder,cfg.figureNames{id});
        if ~isempty(which('exportgraphics'))
            exportgraphics(ax,output,'Resolution',cfg.figureResolutionDpi, ...
                'BackgroundColor','white');
        else
            set(h,'PaperPositionMode','auto','InvertHardcopy','off');
            print(h,output,'-dpng',sprintf('-r%d',cfg.figureResolutionDpi));
        end
        clear closer;
    end
end

function [h,ax] = white_figure
    h = figure('Visible','off','Color','w','Position',[100,100,1000,430]);
    if isprop(h,'Theme'), set(h,'Theme','light'); end
    set(h,'Color','w','InvertHardcopy','off');
    ax = axes('Parent',h,'Color','w','XColor','k','YColor','k');
    % Distinct dark colors plus different line styles remain legible on white.
    set(ax,'ColorOrder',[0,0.35,0.65;0.80,0.25,0.05;0.42,0.20,0.56]);
    set(ax,'NextPlot','replacechildren');
end

function close_if_valid(h)
    if isgraphics(h), close(h); end
end
