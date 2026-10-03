function destination = package_github
%PACKAGE_GITHUB Make a source/report/results ZIP without raw data or .git.
% Run from MATLAB after reviewing the source, report, and output contents.
% This creates a local ZIP only; it does not publish anything to GitHub.
% The whitelist excludes .mat, backups, old runs, and compiled TeX files.
    root=fileparts(mfilename('fullpath'));
    selected={};
    rootFiles={'run_demo.m','run_tests.m','package_github.m','README.md','.gitignore'};
    for k=1:numel(rootFiles)
        if isfile(fullfile(root,rootFiles{k})), selected{end+1}=rootFiles{k}; end %#ok<AGROW>
    end
    add_folder('src',{'.m'});
    add_folder('tests',{'.m'});
    add_folder('docs',{'.md'});
    add_folder('report',{'.tex','.pdf','.bib','.sty','.png'});
    if isfile(fullfile(root,'data','README.md'))
        selected{end+1}=fullfile('data','README.md');
    end
    cfgPath=fullfile(root,'src'); oldPath=path;
    pathGuard=onCleanup(@()path(oldPath)); %#ok<NASGU>
    addpath(cfgPath,'-begin'); cfg=ecg_config;
    resultNames=[cfg.resultFiles,{'report_comparison.csv'},cfg.figureFiles];
    for k=1:numel(resultNames)
        relative=fullfile('results',resultNames{k});
        if isfile(fullfile(root,relative)), selected{end+1}=relative; end %#ok<AGROW>
    end
    % Numeric audit records are intentionally excluded: keep MATLAB outputs
    % distinct from separate preparation-time cross-checks.
    destination=fullfile(root, ...
        ['ecg-filter-comparison-',datestr(now,'yyyymmdd-HHMMSSFFF'),'.zip']);
    zip(destination,unique(selected,'stable'),root);
    fprintf('Created %s\nECG.mat and the .git directory are excluded.\n',destination);
    fprintf('Review permissions for both original data and derived figures before publishing.\n');

    function add_folder(name,extensions)
        folder=fullfile(root,name);
        if ~isfolder(folder), return; end
        listing=dir(fullfile(folder,'**','*'));
        for j=1:numel(listing)
            if listing(j).isdir, continue; end
            [~,base,ext]=fileparts(listing(j).name);
            if isempty(base) || base(1)=='.' || ~any(strcmpi(ext,extensions)), continue; end
            full=fullfile(listing(j).folder,listing(j).name);
            selected{end+1}=full(numel(root)+2:end);
        end
    end
end
