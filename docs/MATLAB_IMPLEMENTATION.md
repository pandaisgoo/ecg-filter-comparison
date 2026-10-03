# 程式與方法對應

## 檔案配置

| 檔案 | 職責 |
| --- | --- |
| `run_demo.m` | 分析入口、路徑管理、避免無意覆寫、輸出流程 |
| `run_tests.m` | 合成測試、數值檢查及報告數值比較的入口 |
| `package_github.m` | 建立排除原始資料的本機打包檔 |
| `src/ecg_config.m` | 集中記錄分析參數 |
| `src/load_ecg_data.m` | 讀取並檢查 ECG、取樣率與資料尺度 |
| `src/detect_r_peaks.m` | 固定門檻的候選 R 波與 R–R 間隔 |
| `src/design_ecg_filters.m` | FIR 係數、IIR 二階段及串接係數 |
| `src/filter_ecg.m` | 相同零初始條件的因果濾波 |
| `src/amplitude_spectrum.m` | 依原始樣本數正規化的單邊振幅頻譜 |
| `src/windowed_psd.m` | 去平均值、periodic Hann window 與單邊 PSD |
| `src/frequency_response_delay.m` | 單一系統的頻率響應及解析群延遲 |
| `src/cascade_response.m` | 串接系統的響應乘積與群延遲加總 |
| `src/analyze_ecg.m` | 不讀寫檔案的主要數值分析 |
| `src/validate_numerics.m` | 十項數值一致性檢查 |
| `src/compare_report_values.m` | 使用列印精度核對既有報告；不改計算值 |
| `src/plot_ecg_results.m` | 白底、黑字、可區分線型的八張圖 |
| `src/write_ecg_results.m` | 新運算的 CSV、設定與執行紀錄 |
| `tests/test_ecg_functions.m` | 17 項合成訊號／輸入檢查 |

## 保留的分析規格

取樣率來自輸入檔，不在不同區塊重複指定。對參考資料 Fs=1800 Hz，
移動平均 FIR 長度為 30；IIR 保留 r=0.95 與 60、120、180 Hz 三個二階系統串接。
IIR 不另外正規化 DC 增益。不使用 `filtfilt`，也不對輸出作時間對齊。

峰值偵測維持去平均值、最大絕對值正規化、0.6 的高度門檻、0.6 秒最小間距，
以及嚴格的 0.4 < RR < 1.5 秒篩選。此固定參數不代表適用所有 ECG。

完整訊號與 [0.8,1.6) 秒固定片段各自扣除平均值，以各自原始樣本數正規化 FFT。
評估區間從 1 秒開始至紀錄末端；對參考資料共 13,200 個樣本。
PSD 用 periodic Hann window，FFT 長度保持先前流程的決定方式，
對目標頻率正負 1 Hz 的格點以 PSD 總和乘上頻點間距估算功率。

八張圖的主題與檔名不變。圖表配色改成白底和較深的線條，資料點由新運算產生，
不使用影像反相來取代計算。

## 此版工程調整

將分析、畫圖、輸出與測試拆成函式；新的運算不生成或修改 README、HTML、
LaTeX 或 PDF 報告。避免前版產生程式重寫已編輯的正式文件。
新增輸入錯誤訊息、輸出覆寫選項與獨立的報告數值比較。
這些是本次整理加入的工程功能，不代表它們已包含於較早的執行版本。

此套件依據既有程式片段及執行報告重整，**不是從你的 MATLAB 帳號下載的原始
執行檔**。程式重整使用 AI 輔助，公開前應自行理解、執行與審閱。
資料使用權利不因提供程式而改變；沒有對原始 ECG 或第三方材料授予新授權。

## 官方函式文件

程式方法主要依照提供的報告；下列文件僅用來確認 MATLAB API 與繪圖設定：

- MATLAB `fft`: https://www.mathworks.com/help/matlab/ref/fft.html
- MATLAB `findpeaks`: https://www.mathworks.com/help/signal/ref/findpeaks.html
- MATLAB `exportgraphics`: https://www.mathworks.com/help/matlab/ref/exportgraphics.html
- MATLAB `figure`: https://www.mathworks.com/help/matlab/ref/figure.html
- MATLAB `zip`: https://www.mathworks.com/help/matlab/ref/zip.html

沒有以一般公開資料集或其他演算法替換你提供的輸入與方法。
