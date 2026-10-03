# MATLAB 程式使用說明

本套件是 ECG 訊號分析與 FIR／IIR 濾波器比較的模組化實作，共 18 個 `.m` 檔案。

## 放入原專案

先將舊版 `run_demo.m` 備份到專案外。將此 ZIP 解壓，將 `run_demo.m`、
`run_tests.m`、`package_github.m`、`src/`、`tests/`、`docs/` 合併到你的
`ecg-filter-comparison/` 根目錄；不要多包一層 `ECG_MATLAB_Source/`。
本套件不包含、也不會覆蓋根目錄 README、LaTeX、報告 PDF 或既有結果圖。
根目錄 `.gitignore` 有新增本機測試目錄的忽略規則，若原本有自訂規則，請合併而非丟棄。

## 資料與環境

使用 MATLAB 與 Signal Processing Toolbox。將自己的 `ECG.mat` 放在 `data/`；
也接受放在主程式旁邊，或在呼叫時指定路徑。原始資料沒有包含在套件內。
檔案需包含實數向量 `ECG`，以及取樣率 `Fs` 或 `ECG_Fs`。
本套件使用的 API 涵蓋 `findpeaks`、`freqz`、`table`、`writetable`、`jsonencode`。
繪圖優先使用 `exportgraphics`，沒有該函式時使用 `print`。
尚未宣稱任何 MATLAB 版本或 GNU Octave 的完整相容性測試已完成。

## 第一次：先檢查，不改舊結果

在 MATLAB 的 Current Folder 選擇同時有 `run_demo.m` 和 `src/` 的那一層。
Command Window 執行：

```matlab
which run_demo
S = run_tests;
R = run_demo([], 'OutputDir', 'results_check', 'CompareWithReport', true);
```

`which run_demo` 應指向這個專案的新主程式，而不是其他資料夾的舊版本。
`run_tests` 包含 17 項合成訊號／輸入檢查、10 項數值一致性檢查，以及
18 項與報告列印值的比較。沒有資料時只執行合成測試；它不會寫入檔案。
這些數目是測試的設計，並非套件交付時已在 MATLAB 執行通過的宣稱。

若要再次使用同一測試輸出資料夾，需明確允許更新：

```matlab
R = run_demo([], 'OutputDir', 'results_check', ...
             'CompareWithReport', true, 'Overwrite', true);
```

所有計算都是從指定的資料重新執行。報告參考值只用於比較，絕不會補進輸出。
程式不在 root workspace 留下或改寫原始 `ECG`；每個函式各自管理變數。

## 檢查後，更新正式結果

確認圖形及 `results_check/report_comparison.csv` 後，執行：

```matlab
R = run_demo([], 'CompareWithReport', true, 'Overwrite', true);
```

這次更新的是 `results/` 中本程式管理的 CSV、紀錄及八張圖，不會重寫
`README.md`、`report/main.tex` 或 `report/ECG_Report.pdf`。

**既有 PDF 不會自動嵌入新圖。** 若要讓 PDF 使用新輸出的圖片，須自行重新編譯
LaTeX；LaTeX 來源若仍另有 `report/figures/` 副本，要先確認實際引用的圖形目錄。

預設 `Overwrite=false`。目的地已有同名結果時，程式會停下，不會直接蓋掉。
新圖表與數據先在暫存資料夾產生，全部產生成功後再複製到指定目錄。

## 執行選項

```matlab
% 全新目錄可用最短呼叫，輸出到 results/
R = run_demo;

% 指定原始資料與新的輸出路徑
R = run_demo('C:\my-data\ECG.mat', 'OutputDir', 'results_check_2');

% 只計算，不畫圖（請使用新的輸出目錄）
R = run_demo([], 'OutputDir', 'results_check_numeric', 'MakeFigures', false);

% 不需要 ECG.mat 的合成測試
S = run_tests(false);
```

相對路徑以 `run_demo.m` 所在的專案根目錄為準。
`CompareWithReport=true` 只適用於核對既有報告資料，不是其他 ECG 的通用正確答案。
若故意修改 `src/ecg_config.m` 的方法參數，請同時更新報告，不能沿用舊數字。

## 輸出檔案

| 檔案 | 內容 |
| --- | --- |
| `results/figures/*.png` | 八張白底、300 DPI 圖片；保留舊版圖片檔名 |
| `r_peak_candidates.csv` | 候選峰值位置、時間與正規化高度 |
| `rr_intervals.csv` | 相鄰間隔，以及是否被用於估計 |
| `band_power.csv` | 三個頻帶的輸入／輸出功率與降低量 |
| `signal_changes.csv` | RMS 比值、相對原訊號變動量及 DC 增益 |
| `response_probes.csv` | 指定頻率的增益與群延遲 |
| `validation.csv` | 本次 MATLAB 執行的十項數值檢查 |
| `run_summary.csv` | 本次取樣率、樣本數、振幅範圍與摘要 |
| `run_log.txt` | 本次執行時間、環境及處理方式 |
| `configuration.json` | 本次使用的設定值 |
| `report_comparison.csv` | 選用：與報告已印出數值的比較 |

## 振幅尺度說明

本程式保留 `ECG.mat` 的原始振幅，只有選取候選 R 波前另外去平均值及正規化。
目前提供的原始資料最小值約 -53.2813、最大值約 204.099。
既有結果截圖的縱軸曾顯示約 -0.3 到 1 的尺度，但單靠截圖不能確認當時
採用的是哪一種縮放或資料版本。新程式不會為了模仿舊截圖而偷偷縮放原始資料。
所以時域、振幅頻譜及 PSD 的縱軸可能與舊截圖不同。
對所有比較訊號施加相同的非零比例縮放，不改變頻帶功率的降低量或本版的 RMS 比值。
本次原始資料的 18 項摘要數值已透過獨立等價計算核對到報告的列印精度。

## 準備上傳

確認結果後，保留原本的公開報告及 README，將這次的 `.m` 檔與新產生的
正式結果一起加入 Git。`results_check*/` 與 `.mat` 已列入 `.gitignore`。

也可在 MATLAB 執行：

```matlab
archive = package_github;
```

它只建立本機的 ZIP，不會替你發布 GitHub。打包使用檔案白名單，排除
原始 `.mat`、`.git/`、測試輸出資料夾與暫存檔。公開前仍需人工檢查實際檔案內容。
這個 ZIP 是給搬移或備份用；Git 倉庫應提交解壓後的檔案，而不是把整個 ZIP 提交。

## 測試證據的界線

準備套件時使用 Python/NumPy/SciPy 對等公式核對數值，沒有 MATLAB runtime，
因此 **沒有直接執行這 18 個 `.m` 檔，也未測試 MATLAB 的圖形匯出**。
`docs/verification/` 的檔案是獨立 Python 檢查，不是 MATLAB 的原始 CSV；
不應移到 `results/` 冒充本次 MATLAB 執行結果。
請以你自己的 `run_tests`、`run_demo` 實際輸出作為 MATLAB 驗證紀錄。

## 文件

- [程式與方法對應](MATLAB_IMPLEMENTATION.md)
- [準備時的數值核對](NUMERICAL_CROSSCHECK.md)
