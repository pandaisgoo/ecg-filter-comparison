# 準備時的獨立數值核對

**這不是 MATLAB 執行紀錄。** 套件建立環境沒有 MATLAB 或 GNU Octave runtime。
使用 Python、NumPy 與 SciPy 對等的 FFT、因果濾波、峰值與頻譜公式，
在使用者提供的 `ECG.mat` 上進行獨立核對。未執行 MATLAB 的 `checkcode`、
`run_tests`、`run_demo` 或圖形匯出，也未使用 MATLAB 語法解析器。

對照文件是使用者提供的 2026-10-03 09:51:52 執行結果 PDF：
其第 4–5 頁列候選峰值與 R–R／心率數字，第 9 頁列三個頻帶降低量，
第 10 頁列 RMS 比值及相對變動量。

18 項對照量都落在報告列印精度的容許範圍。另有 10 項對等公式的數值一致性
檢查通過；它們不能代替 `.m` 程式的實際執行或繪圖測試。

- `verification/python_reference_crosscheck.csv`：列印參考值與重新計算值，18 項。
- `verification/python_numerical_checks.csv`：Python 對等公式的 10 項檢查。
- `verification/audit_metadata.json`：計算環境與輸入檔 SHA-256。

這些檔案不應被重新命名成 `results/validation.csv` 或原始 MATLAB 結果。
MATLAB 執行版本的 CSV 與 `run_log.txt`，只能由你實際執行產生。

本次核對的輸入振幅範圍約 [-53.2813,204.099]，不是舊截圖中最大值約 1 的尺度。
未將原始輸入自動縮放來仿製截圖；這不妨礙相同比例縮放下不變的比較量吻合。
