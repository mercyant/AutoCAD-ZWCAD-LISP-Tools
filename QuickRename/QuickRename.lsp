(defun c:QR (/ ent oldname tmp_file fn dcl_id newname result)
  (vl-load-com)
  ;; 1. 選取圖面上的圖塊
  (setq ent (car (entsel "\n請點選您想改名的圖塊：")))
  
  (if (and ent (= (cdr (assoc 0 (entget ent))) "INSERT"))
    (progn
      (setq oldname (cdr (assoc 2 (entget ent))))
      
      ;; 2. 建立臨時的對話框描述檔案 (DCL)
      (setq tmp_file (vl-filename-mktemp "rename.dcl"))
      (setq fn (open tmp_file "w"))
      (write-line "rename_dlg : dialog { label = \"圖塊重新命名\";" fn)
      (write-line "  : edit_box { label = \"新的中文名稱：\"; key = \"eb1\"; edit_width = 35; fill_horizontal = true; }" fn)
      (write-line "  spacer; ok_cancel; }" fn)
      (close fn)
      
      ;; 3. 載入並啟動視窗
      (setq dcl_id (load_dialog tmp_file))
      (if (new_dialog "rename_dlg" dcl_id)
        (progn
          (set_tile "eb1" oldname) ;; 預設顯示舊名稱
          (action_tile "accept" "(setq newname (get_tile \"eb1\")) (done_dialog 1)")
          (action_tile "cancel" "(done_dialog 0)")
          (setq result (start_dialog))
          (unload_dialog dcl_id)
          (vl-file-delete tmp_file) ;; 刪除臨時檔，保持環境整潔
          
          ;; 4. 執行更名動作
          (if (and (= result 1) newname (/= newname "") (/= newname oldname))
            (progn
              (command "-RENAME" "B" oldname newname)
              (princ (strcat "\n已成功更名為： " newname))
            )
          )
        )
        (princ "\n無法載入對話框視窗。")
      )
    )
    (princ "\n這似乎不是一個圖塊，請再次嘗試點選。")
  )
  (princ)
)