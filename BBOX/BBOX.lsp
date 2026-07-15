(defun c:BBOX (/ *error* ss_all ss_temp w en i obj mode p_pick side1 side2 cap1 cap2 ss_hatch_boundary old_cmdecho w_saved_local)
  (vl-load-com)

  ;; --- 1. 強化錯誤處理 ---
  (defun *error* (msg)
    ;; 當使用者按 ESC 時，取消所有亮顯物件
    (if ss_all
      (repeat (setq i (sslength ss_all))
        (redraw (ssname ss_all (setq i (1- i))) 4)
      )
    )
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (princ (strcat "\n[提示] 操作已安全取消。"))
    (princ)
  )

  (setq old_cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  ;; --- 2. 參數設定 ---
  (initget "Single Both")
  (setq mode (getkword "\n模式 [單側(S) / 雙側(B)] <Both>: "))
  (if (null mode) (setq mode "Both"))

  (setq w (getdist (strcat "\n總寬度 <" (if (not w_saved) "50" (rtos w_saved)) ">: ")))
  (if (null w) 
    (setq w (if (not w_saved) 50.0 w_saved))
    (setq w_saved w)
  )

  ;; --- 3. 連續收集線段 (ESC 可隨時中斷) ---
  (princ "\n[選取] 框選或點選路徑，選錯請直接按 ESC 取消，完成請按 Enter: ")
  (setq ss_all (ssadd))
  
  ;; 使用捕捉錯誤的方式來執行選取，確保 ESC 能被響應
  (while (setq ss_temp (ssget '((0 . "LINE,LWPOLYLINE"))))
    (repeat (setq i (sslength ss_temp))
      (setq en (ssname ss_temp (setq i (1- i))))
      (if (not (ssmemb en ss_all))
        (progn
          (ssadd en ss_all)
          (redraw en 3) ; 亮顯選取
        )
      )
    )
    (princ (strcat "\n目前已選取 " (itoa (sslength ss_all)) " 個物件。繼續選取或 Enter 開始執行..."))
  )

  ;; --- 4. 執行處理 (僅在按下 Enter 後執行) ---
  (if (and ss_all (> (sslength ss_all) 0))
    (progn
      (setvar "PEDITACCEPT" 1)
      (command "._PEDIT" "M" ss_all "" "J" "1.0" "")
      (setq en_final (entlast))
      (setq obj (vlax-ename->vla-object en_final))
      (setq ss_hatch_boundary (ssadd))

      (cond
        ((= mode "Both")
         (setq halfW (/ w 2.0))
         (vla-offset obj halfW) (setq side1 (entlast))
         (vla-offset obj (- halfW)) (setq side2 (entlast))
         (setq p1s (vlax-curve-getStartPoint side1) p2s (vlax-curve-getStartPoint side2)
               p1e (vlax-curve-getEndPoint side1) p2e (vlax-curve-getEndPoint side2))
         (entmake (list '(0 . "LINE") (cons 10 p1s) (cons 11 p2s))) (setq cap1 (entlast))
         (entmake (list '(0 . "LINE") (cons 10 p1e) (cons 11 p2e))) (setq cap2 (entlast))
         (mapcar '(lambda (x) (ssadd x ss_hatch_boundary)) (list side1 side2 cap1 cap2))
        )
        ((= mode "Single")
         (setq p_pick (getpoint "\n點擊偏移方向側 (或按 ESC 放棄): "))
         (if p_pick
           (progn
             (setq p_near (vlax-curve-getClosestPointTo obj p_pick))
             (vla-offset obj w) (setq side1 (entlast))
             (setq p_test (vlax-curve-getClosestPointTo (vlax-ename->vla-object side1) p_pick))
             (if (> (distance p_pick p_test) (distance p_pick p_near))
               (progn (entdel side1) (vla-offset obj (- w)) (setq side1 (entlast)))
             )
             (setq p1s (vlax-curve-getStartPoint obj) p2s (vlax-curve-getStartPoint side1)
                   p1e (vlax-curve-getEndPoint obj) p2e (vlax-curve-getEndPoint side1))
             (entmake (list '(0 . "LINE") (cons 10 p1s) (cons 11 p2s))) (setq cap1 (entlast))
             (entmake (list '(0 . "LINE") (cons 10 p1e) (cons 11 p2e))) (setq cap2 (entlast))
             (mapcar '(lambda (x) (ssadd x ss_hatch_boundary)) (list en_final side1 cap1 cap2))
           )
         )
        )
      )

      (if (and ss_hatch_boundary (> (sslength ss_hatch_boundary) 0))
        (progn
          (command "._PEDIT" "M" ss_hatch_boundary "" "J" "0.1" "")
          (command "._-HATCH" "P" "SOLID" "S" (entlast) "" "")
          (princ "\n[完成] 填充任務已成功。")
        )
      )
    )
    (princ "\n[提示] 未選取物件。")
  )

  (setvar "CMDECHO" old_cmdecho)
  (princ)
)