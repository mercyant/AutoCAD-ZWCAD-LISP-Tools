(defun c:LL (/ e ss l p i final_l)
  ;; 確保載入 Visual LISP 擴充庫
  (vl-load-com)

  ;; 1. 選取物件 (線、聚合線、圓弧、圓、橢圓、樣條曲線)
  (if
    (setq l 0.0 ss (ssget '((0 . "LINE,SPLINE,LWPOLYLINE,POLYLINE,ARC,CIRCLE,ELLIPSE"))))
    (progn
      ;; 2. 累加選取物件的總長度
      (repeat (setq i (sslength ss))
        (setq e (ssname ss (setq i (1- i)))
              l (+ l (vlax-curve-getDistAtParam e (vlax-curve-getEndParam e)))
        )
      )

      ;; 3. 核心邏輯：尾數 1-4 變 5, 6-9 進位至 10 (以 5 為單位向上取整)
      ;; 演算法：(總長 / 5.0) -> 無條件進位 -> 再乘以 5
      (setq final_l (* (fix (+ (/ l 5.0) 0.999999)) 5))

      ;; 4. 輸出結果
      (setq p (getpoint "\n請點擊位置以插入總長度文字: "))
      (if p
        (entmake
          (list
            '(0 . "TEXT")
            '(100 . "AcDbText")
            (cons 10 (trans p 1 0)) ;; 座標轉換至世界座標系
            (cons 40 (/ 5.0 (getvar 'cannoscalevalue))) ;; 文字高度隨註解比例調整
            (cons 1 (rtos final_l 2 0)) ;; 轉為整數字串輸出
          )
        )
        ;; 若未點擊位置，則顯示於指令列
        (princ (strcat "\n[銅板計算] 原始總長: " (rtos l 2 2) " -> 修正後總長: " (rtos final_l 2 0)))
      )
    )
  )
  (princ)
)