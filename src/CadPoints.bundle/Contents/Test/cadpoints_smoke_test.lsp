;;; CadPoints smoke test for AutoCAD LT.
;;; Usage: APPLOAD cadpoints.lsp, then APPLOAD this file, then run CPTESTNAMES.

(defun c:CPTESTNAMES (/ first second third fourth ok)
  (setq *cadpoints-point-name-counters* nil)
  (setq *cadpoints-point-name-pattern* "")
  (setq first (cp:next-point-name "CP_POINTS_A"))
  (setq second (cp:next-point-name "CP_POINTS_A"))
  (setq third (cp:next-point-name "CP_POINTS_B"))
  (setq *cadpoints-point-name-counters* nil)
  (setq *cadpoints-point-name-pattern* "A-SO01-###")
  (setq fourth (cp:next-point-name "CP_POINTS_A"))
  (setq ok (and (= first "A001") (= second "A002") (= third "B001") (= fourth "A-SO01-001")))
  (if ok
    (princ "\nCPTESTNAMES OK")
    (princ (strcat "\nCPTESTNAMES FAILED: " first ", " second ", " third ", " fourth))
  )
  (princ)
)
