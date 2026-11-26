# EXIF 參數邊框

在照片下方加上機型、焦距、光圈、快門、ISO 的參數邊框。單一 HTML 檔，照片只在瀏覽器裡處理，不會上傳。

## 功能

- 一次選多張照片，用 [exifr](https://github.com/MikeKovarik/exifr) 讀出每張的 EXIF
- 三種樣式：白底、黑底、霧面（模糊背景）
- 參數可逐張手動修改；沒有 EXIF 的照片可一鍵把機型套用到全部
- 原尺寸輸出（48MP 照片會縮到約 13MP，受 iOS Safari 畫布上限限制），JPEG 品質 0.95
- 存檔時寫回原照片的 EXIF：方向改為正向、像素尺寸改成新尺寸、移除舊縮圖；GPS 預設清除，可勾選保留
- 原照片沒有 EXIF 時，改把參數欄的值寫成 EXIF
- 批次存檔：逐張存到照片，或打包成 ZIP

## 使用

直接用瀏覽器開 `index.html`。

在 Claude Artifact 裡開啟時，會透過 Artifact 的 downloads 功能存檔（iPhone 會跳出分享選單，可存到照片）。
當成一般網頁開啟時（例如 GitHub Pages）：

- 「全部存到照片」會先產生所有原尺寸圖片，再按「一次存到照片」，從分享選單選「儲存 N 張影像」，就會一次全部存進「照片」（含 EXIF）。不支援 Web Share 的瀏覽器改為長按或按右鍵逐張存檔。
- 「打包成 ZIP」會直接下載。ZIP 在 iPhone 上只能存到「檔案」，不能直接匯入照片。

## 相依

從 CDN 載入：exifr 7.1.3、JSZip 3.10.1、Google Fonts（Archivo、Inter、IBM Plex Mono）。
