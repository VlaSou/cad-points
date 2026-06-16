;;; CadPoints document startup loader for AutoCAD LT.
;;; Kept inside the .bundle and enabled through PackageContents.xml SupportPath.

(if (not (member "C:CPHELP" (atoms-family 1)))
  (load "cadpoints.lsp")
)

(princ)
