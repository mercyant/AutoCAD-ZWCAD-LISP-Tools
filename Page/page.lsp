(defun c:page (/ *error* oldEcho oldOsm dcl_id prefix startNum padLen h ss i en entData ptList total count currentNumStr get-sub-center)
  (vl-load-com)

  ;; --- 內部函數：偵測圖塊內標記 (加入座標轉換) ---
  (defun get-sub-center (blk-en / sub-en sub-data sub-type pt-found minp maxp blk-base blk-scale)
    (setq entData (entget blk-en))
    (setq sub-en (tblobjname "BLOCK" (cdr (assoc 2 entData))))
    (setq blk-base (cdr (assoc 10 entData)))
    (setq blk-scale (cdr (assoc 41 entData))) 
    (while (and sub-en (not pt-found))
      (setq sub-data (entget sub-en))
      (setq sub-type (cdr (assoc 0 sub-data)))
      (if (or (= sub-type "CIRCLE") (= sub-type "LWPOLYLINE"))
        (progn
          (vla-getboundingbox (vlax-ename->vla-object sub-en) 'minp 'maxp)
          (setq pt-found (mapcar '(lambda (a b) (/ (+ a b) 2.0)) (vlax-safearray->list minp) (vlax-safearray->list maxp)))
          ;; 計算並轉換為當前顯示座標
          (setq pt-found (mapcar '+ blk-base (mapcar '(lambda (x) (* x blk-scale)) pt-found)))
        )
      )
      (setq sub-en (entnext sub-en))
    )
    pt-found
  )

  (defun *error* (msg) (setvar "CMDECHO" oldEcho) (setvar "OSMODE" oldOsm) (princ))

  (setq oldEcho (getvar "CMDECHO") oldOsm (getvar "OSMODE"))
  (setvar "CMDECHO" 0)

  ;; --- DCL 對話框 (略，同前) ---
  (setq dcl_id (load_dialog (setq temp_dcl (vl-filename-mktemp "page.dcl"))))
  (setq f (open temp_dcl "w"))
  (write-line "page_input : dialog { label = \"ZWCAD 頁碼參數設定\"; : edit_box { label = \"頁碼前綴:\"; key = \"pre\"; } : edit_box { label = \"起始數字:\"; key = \"start\"; } : edit_box { label = \"補零位數:\"; key = \"pad\"; } : edit_box { label = \"文字高度:\"; key = \"hgt\"; } ok_cancel; }" f)
  (close f)
  (setq dcl_id (load_dialog temp_dcl))
  (new_dialog "page_input" dcl_id)
  (set_tile "pre" "")(set_tile "start" "1")(set_tile "pad" "2")(set_tile "hgt" "2.5")
  (action_tile "accept" "(setq prefix (get_tile \"pre\") startNum (atoi (get_tile \"start\")) padLen (atoi (get_tile \"pad\")) h (atof (get_tile \"hgt\"))) (done_dialog)")
  (start_dialog) (unload_dialog dcl_id) (vl-file-delete temp_dcl)

  (if (and prefix startNum)
    (progn
      (princ "\n>>> [框選範圍] 請選取標記物件 <<<")
      (if (setq ss (ssget '((0 . "CIRCLE,LWPOLYLINE,INSERT"))))
        (progn
          (setq ptList '() i 0)
          (repeat (sslength ss)
            (setq en (ssname ss i) entData (entget en) type (cdr (assoc 0 entData)) centerPt nil)
            (cond 
              ((= type "CIRCLE") (setq centerPt (cdr (assoc 10 entData))))
              ((= type "LWPOLYLINE")
               (vla-getboundingbox (vlax-ename->vla-object en) 'minpt 'maxpt)
               (setq centerPt (mapcar '(lambda (a b) (/ (+ a b) 2.0)) (vlax-safearray->list minpt) (vlax-safearray->list maxpt))))
              ((= type "INSERT") (setq centerPt (get-sub-center en)))
            )
            (if centerPt (setq ptList (cons centerPt ptList)))
            (setq i (1+ i))
          )

          ;; 排序邏輯
          (setq ptList (vl-sort ptList '(lambda (p1 p2) (if (not (equal (cadr p1) (cadr p2) 1.0)) (> (cadr p1) (cadr p2)) (< (car p1) (car p2))))))

          (setvar "OSMODE" 0) 
          (setq count startNum)
          (foreach pt ptList
            (setq currentNumStr (itoa count))
            (while (< (strlen currentNumStr) padLen) (setq currentNumStr (strcat "0" currentNumStr)))
            
            ;; --- 關鍵修正：將 WCS 座標轉換為目前的 UCS 座標 ---
            (setq finalPt (trans pt 0 1)) 
            
            (command "_.TEXT" "J" "MC" finalPt h 0 (strcat prefix currentNumStr))
            (setq count (1+ count))
          )
        )
      )
    )
  )
  (setvar "OSMODE" oldOsm) (setvar "CMDECHO" oldEcho) (princ)
)