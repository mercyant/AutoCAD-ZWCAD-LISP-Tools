# AutoCAD & ZWCAD LISP Tools

一組實用的 AutoLISP 工具集，適用於 AutoCAD 及 ZWCAD，專為提升繪圖效率而設計。

---

## 📦 工具清單

| 指令 | 檔案 | 功能說明 |
|------|------|----------|
| `QR` | [QuickRename.lsp](QuickRename/QuickRename.lsp) | 快速變更圖塊名稱，透過對話框輸入新名稱 |
| `INT` | [InternalNote.lsp](InternalNote/InternalNote.lsp) | 將選取物件移至不列印圖層 `Internal_Note`，適合內部註記 |
| `BBOX` | [BBOX.lsp](BBOX/BBOX.lsp) | 沿路徑線條產生加粗填充效果，支援單側/雙側模式 |
| `LL` | [LL.lsp](LL/LL.lsp) | 計算選取線段總長度，以 5 為單位向上取整（銅板長計算） |
| `page` | [page.lsp](Page/page.lsp) | 自動編排頁碼，支援前綴、補零、起始數字設定 |

---

## 🚀 安裝方式

### 方法一：手動載入

1. 下載所需的 `.lsp` 檔案
2. 在 CAD 指令列輸入 `APPLOAD`
3. 瀏覽並選取下載的 `.lsp` 檔案
4. 點擊「載入」

### 方法二：自動載入（每次啟動）

1. 將 `.lsp` 檔案放到 CAD 的支援路徑中
2. 編輯 `acaddoc.lsp`（或 `zwcad.lsp`），加入：

```lisp
(load "QuickRename.lsp")
(load "InternalNote.lsp")
(load "BBOX.lsp")
(load "LL.lsp")
(load "page.lsp")
```

---

## 📖 工具詳細說明

### QR — 快速變更圖塊名稱

點選圖面上的圖塊，彈出對話框讓你輸入新名稱，一鍵完成重新命名。

**使用方式：**
1. 輸入 `QR`
2. 點選要改名的圖塊
3. 在對話框中輸入新名稱
4. 按「確定」

---

### INT — 不列印物件

將選取的物件移至 `Internal_Note` 圖層（橘色、不列印），適合標註內部備忘而不影響出圖。

**使用方式：**
1. 輸入 `INT`
2. 選取要設為不列印的物件
3. 完成！物件已移至不列印圖層

**特性：**
- 自動建立 `Internal_Note` 圖層（若不存在）
- 圖層顏色：橘色（Color 30）
- 圖層列印：關閉

---

### BBOX — 線條加粗（填充）

沿著選取的路徑線條，產生指定寬度的填充區域，模擬加粗效果。

**使用方式：**
1. 輸入 `BBOX`
2. 選擇模式：`S`（單側）或 `B`（雙側，預設）
3. 輸入總寬度（預設 50）
4. 框選或點選路徑線段，按 Enter 確認
5. 單側模式需額外點擊偏移方向

---

### LL — 銅板長計算

選取線段後自動計算總長度，並以 5 為單位向上取整，適用於銅板材料計算。

**使用方式：**
1. 輸入 `LL`
2. 選取要量測的線段
3. 點擊位置插入結果文字（或直接顯示於指令列）

**支援物件：** LINE、SPLINE、LWPOLYLINE、POLYLINE、ARC、CIRCLE、ELLIPSE

---

### page — 自動頁碼

在圖面上的標記物件（圓、聚合線、圖塊）中心自動編排頁碼。

**使用方式：**
1. 輸入 `page`
2. 在對話框中設定：前綴、起始數字、補零位數、文字高度
3. 框選含有標記的區域
4. 自動依位置排序並填入頁碼（由上而下、由左而右）

---

## 🛠️ 相容性

- ✅ AutoCAD 2010+
- ✅ ZWCAD 2020+
- 需要 Visual LISP 支援（`vl-load-com`）

---

## 📄 授權

本專案採用 [MIT License](LICENSE) 授權。
