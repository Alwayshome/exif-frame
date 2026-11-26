# AGENTS.md — EXIF 參數邊框

給接手這個專案的 agent 看的說明。使用者介面和對使用者的回覆一律用**繁體中文**。

## 這是什麼

一個單檔網頁工具：選一張或多張照片，讀出 EXIF（機型、等效焦距、光圈、快門、ISO、拍攝時間、鏡頭），在照片下方加上「參數邊框」，再存成 JPEG。存檔時會把原照片的 EXIF 寫回新圖片。照片只在瀏覽器裡處理，不會上傳。

使用者主要在 **iPhone** 上使用。

## 檔案與發布位置

| 項目 | 位置 |
|---|---|
| 原始檔（唯一要改的檔） | `src/page.html` |
| 一般網頁版（產生出來的） | `index.html` ← 用 `sh build.sh` 從 `src/page.html` 產生，不要手改 |
| GitHub | `Alwayshome/exif-frame`（公開），分支 `main` |
| GitHub Pages | https://alwayshome.github.io/exif-frame/ （從 `main` 根目錄部署，push 後約 1 分鐘生效） |
| Claude Artifact | 使用者的私人 Artifact，網址問使用者，或用 Artifact 工具的 `list` 找標題「EXIF 參數邊框」 |

`src/page.html` 沒有 `<!doctype>`、`<head>`、`<body>`，因為 Claude Artifact 發布時會自動包上外殼。`build.sh` 只是幫一般網頁版補上這層外殼。

### 修改流程

1. 改 `src/page.html`。
2. `sh build.sh` 產生 `index.html`。
3. 語法檢查：`awk '/^<script>$/{f=1;next}/^<\/script>$/{f=0}f' index.html > /tmp/c.js && node --check /tmp/c.js`
4. commit。push 前先問使用者（push 了 Pages 就會直接更新到公開網址）。
5. 同步更新 Artifact：用 Artifact 工具 publish `src/page.html`，並帶上原本的 Artifact 網址（`url`）。從新對話發布前要先 `read` 一次。capabilities 不必再傳，會沿用 `downloads`。

## 程式結構（都在 `src/page.html` 裡）

- **外部函式庫**（CDN）：exifr 7.1.3（讀 EXIF）、JSZip 3.10.1（打包 ZIP）、Google Fonts（Archivo、Inter、IBM Plex Mono）。
- **狀態**：`S.items` 是照片清單，每張有 `file`、`name`、`v`（參數欄的字串值）、`found`、`thumb`、`exifSeg`（原始 EXIF 區塊）。`S.cur` 是目前選的那張；沒選照片時用 `SAMPLE`（程式畫的夕陽範例圖）。
- **記憶體**：一次只保留目前這張的解碼圖（`cache`），其他照片要用時才重新解碼。不要改成全部常駐，iPhone 會因為記憶體不足而當掉。
- **繪圖**：`render(img, v, maxEdge)` 分派給 `drawBar`（白底／黑底）或 `drawBlur`（霧面）。預覽用 1600px，存檔時用原尺寸。
- **EXIF 寫回**：
  - `readExifSegment`：從原 JPEG 取出 APP1「Exif」區塊。
  - `patchExif`：Orientation 改成 1，因為像素已經轉正；PixelX／YDimension 改成新尺寸；斷開 IFD1，移除舊縮圖；不保留 GPS 時清空 GPS 值和 GPS IFD。
  - `buildExif`：原圖沒有 EXIF 時（截圖、HEIC 來源），用參數欄的值寫一份最小的 EXIF。
  - `insertExif`：移除 canvas 產生的 JFIF APP0，在 SOI 後面插入 APP1。
- **存檔**（`saveList`、`saveZip`、`showGallery`）：
  - 在 Artifact 裡：用 `claude.use("downloads")` 的 `save()` 一張一張存；iOS Claude App 會跳出分享選單。
  - 一般網頁（沒有 `window.claude`）：先產生所有圖片顯示在下方，再由「一次存到照片」按鈕呼叫 `navigator.share({files})`。分享選單只能在使用者點擊當下打開，產生圖片要好幾秒，所以一定要兩段式，不能改回一鍵。
  - ZIP：Artifact 裡走 downloads，一般網頁用 `<a download>`。iPhone 上 ZIP 只能存到「檔案」，不能直接進照片。
- **偏好設定**：樣式和四個勾選項（`t-date`、`t-lens`、`t-exif`、`t-gps`）存在 localStorage，key 是 `exif-frame:prefs:v1`，所有讀寫都包在 try/catch。

## 已定案的決策（除非使用者要求，否則不要改）

- 輸出原尺寸。只有超過 iOS Safari 畫布上限（約 1670 萬像素）時才縮小，所以 48MP 照片會縮到約 13MP。JPEG 品質 0.95。
- 「顯示拍攝時間」預設**不勾**；「顯示鏡頭」預設不勾；「寫入 EXIF」預設勾；「保留 GPS」預設**不勾**（隱私考量）。
- 原圖有 EXIF 時寫回原本那份；在參數欄手動改的值只影響邊框上的文字，不會寫進 EXIF。
- 邊框不放任何品牌 Logo，只放文字。
- Artifact 裡不能用 `<a download>`、`alert`、`confirm`、Web Share，存檔一律走 `downloads` capability。

## 驗證狀態

- 使用者已確認：iPhone 上能讀到參數、能一次處理多張、Artifact 版能存檔，「照片」App 裡看得到寫回的 EXIF。
- 尚未實機驗證：Pages 版用分享選單一次存多張到照片；張數很多時 iOS 分享選單會不會失敗；localStorage 記住選項。

## 可能的後續

- 一次很多張時，分享選單可能失敗，可以考慮自動分批，例如每 10 張一組。
- 參數欄手動改的值，可選擇是否覆寫原 EXIF 的對應欄位。
