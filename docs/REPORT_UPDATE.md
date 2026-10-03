# 報告與 README 更新說明

這個 ZIP 是文件更新包，不是完整的可執行專案。
包含 README、已編譯報告、LaTeX 與八張結果圖；**不包含 `run_demo.m`、原始 ECG 資料、原始 CSV 或 `run_log.txt`**。

## 合併位置

將 ZIP 的內容合併到原本 `ecg-filter-comparison` 的根目錄：

```text
README.md
report/
  main.tex
  ECG_Report.pdf
results/
  figures/
docs/
  BUILD_REPORT.md
  REPORT_UPDATE.md
```

保留原有的 MATLAB 程式、CSV、資料與其他檔案。遇到同名文件時，先備份自行修改的版本再合併；
不要刪掉整個 `results/` 或 `report/` 來替換。
其他既有文件不在這次更新範圍。

## 實驗與文件的關係

本次只改寫敘述與編排，未重新執行 MATLAB，也未修改八張結果圖片。
報告數值按既有執行紀錄保留，沒有補造逐項測試值或新的效能數字。
原有程式若會自動產生 README 或報告，重新執行前請備份文件，避免覆蓋人工整理版本。
LaTeX 內的數字是固定快照，新的實驗結果需另行核對並更新。
