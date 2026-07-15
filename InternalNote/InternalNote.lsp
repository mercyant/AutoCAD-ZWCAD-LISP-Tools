(defun c:INT (/ *error* lay_name ss i ent old_cmdecho)
  ;; --- 1. 錯誤處理函數 ---
  ;; 當使用者按下 Esc 或程式出錯時，確保環境變數能恢復
  (defun *error* (msg)
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (if (not (member msg '("Function cancelled" "quit / exit abort")))
      (princ (strcat "\n系統提示: " msg))
    )
    (princ)
  )

  ;; --- 2. 環境變數設定 ---
  (setq lay_name "Internal_Note")
  (setq old_cmdecho (getvar "CMDECHO"))

  ;; --- 3. 圖層檢查與自動建立 ---
  ;; 就像在抽屜裡準備一個專用的「草稿夾」
  (if (not (tblsearch "LAYER" lay_name))
    (progn
      (princ (strcat "\n正在建立筆記專用圖層: " lay_name "..."))
      ;; 建立圖層 (Make) -> 顏色設為橘色 (Color 30) -> 設定為不列印 (Plot No)
      (command "-LAYER" "Make" lay_name "Color" "30" "" "Plot" "No" "" "")
    )
    (progn
      ;; 如果抽屜已經存在，確保它的「不列印」屬性是被鎖定的
      (command "-LAYER" "Plot" "No" lay_name "")
    )
  )

  ;; --- 4. 物件選取與轉換 ---
  (princ "\n請選取要轉為「不列印筆記」的物件 (線條、文字等): ")
  (setq ss (ssget))

  (if ss
    (progn
      (setvar "CMDECHO" 0) ; 隱藏繁雜的指令執行過程
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        ;; 變更屬性：圖層移至 Internal_Note，顏色改為隨圖層
        (command "CHPROP" ent "" "Layer" lay_name "Color" "Bylayer" "")
        (setq i (1+ i))
      )
      (setvar "CMDECHO" old_cmdecho)
      (princ (strcat "\n任務完成！已將 " (itoa (sslength ss)) " 個物件移至 " lay_name "。"))
    )
    (princ "\n未選取任何物件。")
  )
  (princ)
)

(princ "\n[Internal Note 載入成功] 輸入指令: INT")
(princ)