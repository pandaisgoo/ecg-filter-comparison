# 編譯技術報告

在專案根目錄執行：

```text
cd report
xelatex -interaction=nonstopmode -halt-on-error -jobname=ECG_Report main.tex
xelatex -interaction=nonstopmode -halt-on-error -jobname=ECG_Report main.tex
```

主文件使用 XeLaTeX，圖檔從 `../results/figures/` 讀取。
請保留八張 PNG 的檔名；第二次編譯用於更新交叉引用。

也可使用獨立的 `ECG_Public_LaTeX_Source.zip`，其中主檔與 `figures/` 放在同一層。
此更新包保留 2026-10-03 的實驗數值，不會因 MATLAB 重跑自動更新。
