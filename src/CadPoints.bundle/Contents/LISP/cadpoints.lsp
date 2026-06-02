;;; CadPoints for AutoCAD LT
;;; Commands: CPEXPORT, CPSETTINGS, CPHELP

(if (fboundp 'vl-load-com) (vl-load-com))

(setq *cadpoints-version* "0.6.1")
(setq *cadpoints-point-name-pattern* "")
(setq *cadpoints-point-name-counters* nil)
(setq *cadpoints-env-prefix* "CADPOINTS_")

(defun cp:env-name (name)
  (strcat *cadpoints-env-prefix* name)
)

(defun cp:getenv-default (name fallback / value)
  (setq value (getenv (cp:env-name name)))
  (if (and value (/= value "")) value fallback)
)

(defun cp:setenv-value (name value)
  (setenv (cp:env-name name) value)
)

(defun cp:trim (value)
  (vl-string-trim " \t\r\n" value)
)

(defun cp:split (value separator / index result token separator-length)
  (setq result '())
  (setq separator-length (strlen separator))
  (while (setq index (vl-string-search separator value))
    (setq token (substr value 1 index))
    (if (/= (cp:trim token) "")
      (setq result (cons (cp:trim token) result))
    )
    (setq value (substr value (+ index separator-length 1)))
  )
  (if (/= (cp:trim value) "")
    (setq result (cons (cp:trim value) result))
  )
  (reverse result)
)

(defun cp:yes-value-p (value)
  (member (strcase value) '("1" "Y" "YES" "A" "ANO" "TRUE"))
)

(defun cp:valid-scale-p (value)
  (member value '("25" "50" "100" "500" "1000"))
)

(defun cp:valid-table-scale-p (value)
  (cp:valid-scale-p value)
)

(defun cp:normalize-scale (value fallback)
  (if (cp:valid-scale-p value) value fallback)
)

(defun cp:normalize-table-scale (value)
  (cp:normalize-scale value "100")
)

(defun cp:real-to-string (value precision)
  (rtos value 2 precision)
)

(defun cp:point-z (point)
  (if (caddr point) (caddr point) 0.0)
)

(defun cp:3d-point (point)
  (list (car point) (cadr point) (cp:point-z point))
)

(defun cp:pad-number (value width / result)
  (setq result (itoa value))
  (while (< (strlen result) width)
    (setq result (strcat "0" result))
  )
  result
)

(defun cp:layer-suffix (layer-name / index last-index start)
  (setq index 0)
  (setq last-index nil)
  (while (setq index (vl-string-search "_" layer-name index))
    (setq last-index index)
    (setq index (+ index 1))
  )
  (if last-index
    (progn
      (setq start (+ last-index 2))
      (if (<= start (strlen layer-name))
        (substr layer-name start)
        layer-name
      )
    )
    layer-name
  )
)

(defun cp:hash-run (value / length start index)
  (setq length (strlen value))
  (setq start nil)
  (setq index 1)
  (while (and (<= index length) (not start))
    (if (= (substr value index 1) "#")
      (setq start index)
    )
    (setq index (+ index 1))
  )
  (if start
    (progn
      (setq index start)
      (while (and (<= index length) (= (substr value index 1) "#"))
        (setq index (+ index 1))
      )
      (list start (- index start))
    )
    nil
  )
)

(defun cp:apply-point-name-pattern (pattern number / run start width prefix suffix)
  (setq run (cp:hash-run pattern))
  (if run
    (progn
      (setq start (car run))
      (setq width (cadr run))
      (setq prefix (if (> start 1) (substr pattern 1 (- start 1)) ""))
      (setq suffix (substr pattern (+ start width)))
      (strcat prefix (cp:pad-number number width) suffix)
    )
    (strcat pattern (cp:pad-number number 3))
  )
)

(defun cp:counter-next (key / pair next)
  (setq pair (assoc key *cadpoints-point-name-counters*))
  (if pair
    (progn
      (setq next (+ (cdr pair) 1))
      (setq *cadpoints-point-name-counters*
        (subst (cons key next) pair *cadpoints-point-name-counters*)
      )
    )
    (progn
      (setq next 1)
      (setq *cadpoints-point-name-counters*
        (cons (cons key next) *cadpoints-point-name-counters*)
      )
    )
  )
  next
)

(defun cp:next-point-name (layer / pattern suffix key number)
  (setq pattern (cp:trim *cadpoints-point-name-pattern*))
  (if (= pattern "")
    (progn
      (setq suffix (cp:layer-suffix layer))
      (setq key suffix)
      (setq number (cp:counter-next key))
      (strcat suffix (cp:pad-number number 3))
    )
    (progn
      (setq key pattern)
      (setq number (cp:counter-next key))
      (cp:apply-point-name-pattern pattern number)
    )
  )
)

(defun cp:same-point-p (p1 p2 tolerance)
  (and p1 p2 (<= (distance p1 p2) tolerance))
)

(defun cp:ensure-layer (layer-name / layer-data)
  (setq layer-data (tblsearch "LAYER" layer-name))
  (if (not layer-data)
    (entmake
      (list
        '(0 . "LAYER")
        '(100 . "AcDbSymbolTableRecord")
        '(100 . "AcDbLayerTableRecord")
        (cons 2 layer-name)
        '(70 . 0)
        '(62 . 2)
        '(6 . "Continuous")
      )
    )
  )
)

(defun cp:add-text (point value height layer-name / insert-point)
  (cp:ensure-layer layer-name)
  (setq insert-point (list (car point) (cadr point) (cp:point-z point)))
  (entmake
    (list
      '(0 . "TEXT")
      '(100 . "AcDbEntity")
      (cons 8 layer-name)
      '(100 . "AcDbText")
      (cons 10 insert-point)
      (cons 40 height)
      (cons 1 value)
      '(50 . 0.0)
      '(7 . "Standard")
      '(72 . 0)
      (cons 11 insert-point)
      '(73 . 0)
    )
  )
)


(defun cp:add-point (point layer-name)
  (cp:ensure-layer layer-name)
  (entmake
    (list
      '(0 . "POINT")
      '(100 . "AcDbEntity")
      (cons 8 layer-name)
      '(100 . "AcDbPoint")
      (cons 10 (cp:3d-point point))
    )
  )
)

(defun cp:add-line (p1 p2 layer-name)
  (cp:ensure-layer layer-name)
  (entmake
    (list
      '(0 . "LINE")
      '(100 . "AcDbEntity")
      (cons 8 layer-name)
      '(100 . "AcDbLine")
      (cons 10 p1)
      (cons 11 p2)
    )
  )
)

(defun cp:add-lwpolyline (points layer-name / data point)
  (cp:ensure-layer layer-name)
  (setq data
    (list
      '(0 . "LWPOLYLINE")
      '(100 . "AcDbEntity")
      (cons 8 layer-name)
      '(100 . "AcDbPolyline")
      (cons 90 (length points))
      '(70 . 0)
    )
  )
  (foreach point points
    (setq data
      (append data
        (list
          (cons 10 (list (car point) (cadr point)))
          (cons 38 (cp:point-z point))
        )
      )
    )
  )
  (entmake data)
)

(defun cp:add-spline (points layer-name / data point result)
  (cp:ensure-layer layer-name)
  (if (> (length points) 2)
    (progn
      (setq data
        (list
          '(0 . "SPLINE")
          '(100 . "AcDbEntity")
          (cons 8 layer-name)
          '(100 . "AcDbSpline")
          '(70 . 8)
          '(71 . 3)
          '(72 . 0)
          '(73 . 0)
          (cons 74 (length points))
          '(42 . 0.000001)
          '(43 . 0.000001)
          '(44 . 0.0000000001)
        )
      )
      (foreach point points
        (setq data (append data (list (cons 11 point))))
      )
      (setq result (entmake data))
      (if result result (cp:add-lwpolyline points layer-name))
    )
    (cp:add-lwpolyline points layer-name)
  )
)

(defun cp:record-value (key record)
  (cdr (assoc key record))
)

(defun cp:make-record (point-no point-name layer entity-type handle vertex-no point)
  (list
    (cons "POINT_NO" point-no)
    (cons "POINT_NAME" point-name)
    (cons "LAYER" layer)
    (cons "ENTITY_TYPE" entity-type)
    (cons "HANDLE" handle)
    (cons "VERTEX_NO" vertex-no)
    (cons "POINT" point)
  )
)

(defun cp:add-record (records point-no layer entity-type handle vertex-no point draw-point-p point-layer label-p label-height label-layer / point-name)
  (setq point-name (cp:next-point-name layer))
  (if draw-point-p
    (cp:add-point point point-layer)
  )
  (if label-p
    (cp:add-text point point-name label-height label-layer)
  )
  (cons (cp:make-record point-no point-name layer entity-type handle vertex-no point) records)
)

(defun cp:add-segment (segments p1 p2)
  (if (and p1 p2 (/= (distance p1 p2) 0.0))
    (cons (list p1 p2) segments)
    segments
  )
)

(defun cp:lwpolyline-has-bulge-p (entity-data / result item)
  (setq result nil)
  (foreach item entity-data
    (if (and (= (car item) 42) (/= (cdr item) 0.0))
      (setq result T)
    )
  )
  result
)

(defun cp:polyline-curve-like-p (entity-data / flags)
  (setq flags (cdr (assoc 70 entity-data)))
  (if (not flags) (setq flags 0))
  (or
    (/= 0 (logand 2 flags))
    (/= 0 (logand 4 flags))
    (/= 0 (logand 8 flags))
  )
)

(defun cp:curve-total-length (entity / end-param result)
  (setq result
    (vl-catch-all-apply
      '(lambda ()
        (setq end-param (vlax-curve-getEndParam entity))
        (vlax-curve-getDistAtParam entity end-param)
      )
    )
  )
  (if (vl-catch-all-error-p result) nil result)
)

(defun cp:curve-closed-p (entity / result)
  (setq result (vl-catch-all-apply 'vlax-curve-isClosed (list entity)))
  (if (vl-catch-all-error-p result) nil result)
)

(defun cp:curve-point-at-distance (entity curve-distance / result)
  (setq result (vl-catch-all-apply 'vlax-curve-getPointAtDist (list entity curve-distance)))
  (if (vl-catch-all-error-p result) nil (cp:3d-point result))
)

(defun cp:sample-curve-points (entity sample-interval / total-distance current-distance point points closed-p last-point)
  (setq points '())
  (setq total-distance (cp:curve-total-length entity))
  (setq closed-p (cp:curve-closed-p entity))

  (if (and total-distance (> total-distance 0.0))
    (progn
      (if (<= sample-interval 0.0)
        (setq sample-interval 1.0)
      )

      (setq current-distance 0.0)
      (while (< current-distance total-distance)
        (setq point (cp:curve-point-at-distance entity current-distance))
        (if point (setq points (cons point points)))
        (setq current-distance (+ current-distance sample-interval))
      )

      (if (not closed-p)
        (progn
          (setq point (cp:curve-point-at-distance entity total-distance))
          (if point
            (progn
              (setq last-point (car points))
              (if (not (cp:same-point-p point last-point 0.000001))
                (setq points (cons point points))
              )
            )
          )
        )
      )
    )
  )

  (reverse points)
)

(defun cp:collect-sampled-curve (records segments point-no entity entity-data layer entity-type handle sample-interval draw-point-p point-layer label-p label-height label-layer / sampled-points vertex-no point previous-point first-point)
  (setq sampled-points (cp:sample-curve-points entity sample-interval))
  (setq vertex-no 1)
  (setq previous-point nil)
  (setq first-point nil)

  (foreach point sampled-points
    (if (not first-point) (setq first-point point))
    (setq records (cp:add-record records point-no layer entity-type handle vertex-no point draw-point-p point-layer label-p label-height label-layer))
    (setq segments (cp:add-segment segments previous-point point))
    (setq previous-point point)
    (setq point-no (+ point-no 1))
    (setq vertex-no (+ vertex-no 1))
  )

  (if (and first-point previous-point (cp:curve-closed-p entity))
    (setq segments (cp:add-segment segments previous-point first-point))
  )

  (list records segments point-no)
)

(defun cp:collect-line (records segments point-no entity-data layer entity-type handle draw-point-p point-layer label-p label-height label-layer / p1 p2)
  (setq p1 (cdr (assoc 10 entity-data)))
  (setq p2 (cdr (assoc 11 entity-data)))
  (setq records (cp:add-record records point-no layer entity-type handle 1 p1 draw-point-p point-layer label-p label-height label-layer))
  (setq point-no (+ point-no 1))
  (setq records (cp:add-record records point-no layer entity-type handle 2 p2 draw-point-p point-layer label-p label-height label-layer))
  (setq segments (cp:add-segment segments p1 p2))
  (list records segments (+ point-no 1))
)

(defun cp:collect-lwpolyline (records segments point-no entity-data layer entity-type handle draw-point-p point-layer label-p label-height label-layer / item vertex-no point previous-point first-point closed-p elevation flags)
  (setq vertex-no 1)
  (setq previous-point nil)
  (setq first-point nil)
  (setq elevation (cdr (assoc 38 entity-data)))
  (if (not elevation) (setq elevation 0.0))
  (setq flags (cdr (assoc 70 entity-data)))
  (if (not flags) (setq flags 0))
  (setq closed-p (= 1 (logand 1 flags)))
  (foreach item entity-data
    (if (= (car item) 10)
      (progn
        (setq point (cdr item))
        (if (not (caddr point)) (setq point (list (car point) (cadr point) elevation)))
        (if (not first-point) (setq first-point point))
        (setq records (cp:add-record records point-no layer entity-type handle vertex-no point draw-point-p point-layer label-p label-height label-layer))
        (setq segments (cp:add-segment segments previous-point point))
        (setq previous-point point)
        (setq point-no (+ point-no 1))
        (setq vertex-no (+ vertex-no 1))
      )
    )
  )
  (if closed-p
    (setq segments (cp:add-segment segments previous-point first-point))
  )
  (list records segments point-no)
)

(defun cp:collect-polyline (records segments point-no entity layer entity-type handle draw-point-p point-layer label-p label-height label-layer / vertex vertex-data vertex-no point previous-point first-point closed-p done)
  (setq vertex-no 1)
  (setq vertex (entnext entity))
  (setq done nil)
  (setq previous-point nil)
  (setq first-point nil)
  (setq closed-p nil)
  (while (and vertex (not done))
    (setq vertex-data (entget vertex))
    (cond
      ((= (cdr (assoc 0 vertex-data)) "VERTEX")
        (setq point (cdr (assoc 10 vertex-data)))
        (if (not first-point) (setq first-point point))
        (setq records (cp:add-record records point-no layer entity-type handle vertex-no point draw-point-p point-layer label-p label-height label-layer))
        (setq segments (cp:add-segment segments previous-point point))
        (setq previous-point point)
        (setq point-no (+ point-no 1))
        (setq vertex-no (+ vertex-no 1))
      )
      ((= (cdr (assoc 0 vertex-data)) "SEQEND")
        (setq done T)
      )
    )
    (setq vertex (entnext vertex))
  )
  (if (= 1 (logand 1 (cdr (assoc 70 (entget entity)))))
    (setq segments (cp:add-segment segments previous-point first-point))
  )
  (list records segments point-no)
)

(defun cp:default-columns ()
  "POINT_NAME:Bod;LAYER:Hladina;ENTITY_TYPE:Objekt;VERTEX_NO:Vrchol;Y_SJTSK:Y S-JTSK;X_SJTSK:X S-JTSK;Z:Z"
)

(defun cp:column-id (column)
  (car column)
)

(defun cp:column-label (column)
  (cdr column)
)

(defun cp:parse-column-token (token / index key label)
  (setq index (vl-string-search ":" token))
  (if index
    (progn
      (setq key (strcase (cp:trim (substr token 1 index))))
      (setq label (cp:trim (substr token (+ index 2))))
      (if (= label "") (setq label key))
      (cons key label)
    )
    (cons (strcase (cp:trim token)) (strcase (cp:trim token)))
  )
)

(defun cp:parse-columns (value / result token)
  (setq result '())
  (foreach token (cp:split value ";")
    (setq result (cons (cp:parse-column-token token) result))
  )
  (reverse result)
)

(defun cp:field-value (field-id record precision / point)
  (setq point (cp:record-value "POINT" record))
  (cond
    ((= field-id "POINT_NO") (itoa (cp:record-value "POINT_NO" record)))
    ((= field-id "POINT_NAME") (cp:record-value "POINT_NAME" record))
    ((= field-id "LAYER") (cp:record-value "LAYER" record))
    ((= field-id "ENTITY_TYPE") (cp:record-value "ENTITY_TYPE" record))
    ((= field-id "HANDLE") (cp:record-value "HANDLE" record))
    ((= field-id "VERTEX_NO") (itoa (cp:record-value "VERTEX_NO" record)))
    ((= field-id "Y_SJTSK") (cp:real-to-string (car point) precision))
    ((= field-id "X_SJTSK") (cp:real-to-string (cadr point) precision))
    ((= field-id "Z") (cp:real-to-string (cp:point-z point) precision))
    (T "")
  )
)

(defun cp:join-values (values separator / result)
  (setq result "")
  (foreach value values
    (if (= result "")
      (setq result value)
      (setq result (strcat result separator value))
    )
  )
  result
)

(defun cp:csv-row (record columns precision / values column)
  (setq values '())
  (foreach column columns
    (setq values (cons (cp:field-value (cp:column-id column) record precision) values))
  )
  (cp:join-values (reverse values) ";")
)

(defun cp:write-csv (file-path records columns precision / file record labels column)
  (setq file (open file-path "w"))
  (setq labels '())
  (foreach column columns
    (setq labels (cons (cp:column-label column) labels))
  )
  (write-line (cp:join-values (reverse labels) ";") file)
  (foreach record records
    (write-line (cp:csv-row record columns precision) file)
  )
  (close file)
)

(defun cp:max-point-x (records / max-x point)
  (setq max-x nil)
  (foreach record records
    (setq point (cp:record-value "POINT" record))
    (if (or (not max-x) (> (car point) max-x))
      (setq max-x (car point))
    )
  )
  max-x
)

(defun cp:max-point-y (records / max-y point)
  (setq max-y nil)
  (foreach record records
    (setq point (cp:record-value "POINT" record))
    (if (or (not max-y) (> (cadr point) max-y))
      (setq max-y (cadr point))
    )
  )
  max-y
)

(defun cp:min-z (records / min-value point)
  (setq min-value nil)
  (foreach record records
    (setq point (cp:record-value "POINT" record))
    (if (or (not min-value) (< (cp:point-z point) min-value))
      (setq min-value (cp:point-z point))
    )
  )
  min-value
)

(defun cp:max-z (records / max-value point)
  (setq max-value nil)
  (foreach record records
    (setq point (cp:record-value "POINT" record))
    (if (or (not max-value) (> (cp:point-z point) max-value))
      (setq max-value (cp:point-z point))
    )
  )
  max-value
)

(defun cp:sum-list (values / result value)
  (setq result 0.0)
  (foreach value values
    (setq result (+ result value))
  )
  result
)

(defun cp:column-width (column text-height / field-id label)
  (setq field-id (cp:column-id column))
  (setq label (cp:column-label column))
  (cond
    ((= field-id "POINT_NO") (* text-height 7.0))
    ((= field-id "POINT_NAME") (* text-height 14.0))
    ((= field-id "LAYER") (* text-height 18.0))
    ((= field-id "ENTITY_TYPE") (* text-height 17.0))
    ((= field-id "HANDLE") (* text-height 14.0))
    ((= field-id "VERTEX_NO") (* text-height 9.0))
    ((= field-id "Y_SJTSK") (* text-height 18.0))
    ((= field-id "X_SJTSK") (* text-height 18.0))
    ((= field-id "Z") (* text-height 12.0))
    (T (* text-height (max 8 (strlen label))))
  )
)

(defun cp:column-widths (columns text-height / widths column)
  (setq widths '())
  (foreach column columns
    (setq widths (cons (cp:column-width column text-height) widths))
  )
  (reverse widths)
)

(defun cp:row-values (record columns precision / values column)
  (setq values '())
  (foreach column columns
    (setq values (cons (cp:field-value (cp:column-id column) record precision) values))
  )
  (reverse values)
)

(defun cp:draw-grid-table (origin records columns precision text-height table-layer / headers widths row-height rows columns-count total-width total-height current-x current-y row-index column-index cell-value text-point)
  (cp:ensure-layer table-layer)
  (setq headers '())
  (foreach column columns
    (setq headers (cons (cp:column-label column) headers))
  )
  (setq headers (reverse headers))
  (setq widths (cp:column-widths columns text-height))
  (setq row-height (* text-height 2.0))
  (setq columns-count (length headers))
  (setq rows (+ (length records) 1))
  (setq total-width (cp:sum-list widths))
  (setq total-height (* row-height rows))

  (cp:add-text (list (car origin) (+ (cadr origin) (* text-height 1.2)) 0.0) "Tabulka bodu - S-JTSK" (* text-height 1.2) table-layer)

  (setq current-y (cadr origin))
  (repeat (+ rows 1)
    (cp:add-line (list (car origin) current-y 0.0) (list (+ (car origin) total-width) current-y 0.0) table-layer)
    (setq current-y (- current-y row-height))
  )

  (setq current-x (car origin))
  (repeat (+ columns-count 1)
    (cp:add-line (list current-x (cadr origin) 0.0) (list current-x (- (cadr origin) total-height) 0.0) table-layer)
    (if widths
      (progn
        (setq current-x (+ current-x (car widths)))
        (setq widths (cdr widths))
      )
    )
  )

  (setq widths (cp:column-widths columns text-height))
  (setq row-index 0)
  (setq column-index 0)
  (setq current-x (car origin))
  (foreach cell-value headers
    (setq text-point (list (+ current-x (* text-height 0.4)) (- (cadr origin) (* row-height row-index) (* text-height 1.35)) 0.0))
    (cp:add-text text-point cell-value text-height table-layer)
    (setq current-x (+ current-x (nth column-index widths)))
    (setq column-index (+ column-index 1))
  )

  (setq row-index 1)
  (foreach record records
    (setq current-x (car origin))
    (setq column-index 0)
    (foreach cell-value (cp:row-values record columns precision)
      (setq text-point (list (+ current-x (* text-height 0.4)) (- (cadr origin) (* row-height row-index) (* text-height 1.35)) 0.0))
      (cp:add-text text-point cell-value text-height table-layer)
      (setq current-x (+ current-x (nth column-index widths)))
      (setq column-index (+ column-index 1))
    )
    (setq row-index (+ row-index 1))
  )
)

(defun cp:draw-table-right (records columns precision offset text-height table-layer / max-x max-y origin)
  (setq max-x (cp:max-point-x records))
  (setq max-y (cp:max-point-y records))
  (if (and max-x max-y)
    (progn
      (setq origin (list (+ max-x offset) max-y 0.0))
      (cp:draw-grid-table origin records columns precision text-height table-layer)
    )
  )
)

(defun cp:contour-start-level (min-z interval / level)
  (setq level (* interval (fix (/ min-z interval))))
  (while (< level min-z)
    (setq level (+ level interval))
  )
  level
)

(defun cp:level-between-p (level z1 z2)
  (or
    (and (>= level z1) (<= level z2))
    (and (>= level z2) (<= level z1))
  )
)

(defun cp:segment-intersection-at-z (segment level / p1 p2 z1 z2 ratio x y)
  (setq p1 (car segment))
  (setq p2 (cadr segment))
  (setq z1 (cp:point-z p1))
  (setq z2 (cp:point-z p2))
  (if (and (/= z1 z2) (cp:level-between-p level z1 z2))
    (progn
      (setq ratio (/ (- level z1) (- z2 z1)))
      (setq x (+ (car p1) (* ratio (- (car p2) (car p1)))))
      (setq y (+ (cadr p1) (* ratio (- (cadr p2) (cadr p1)))))
      (list x y level)
    )
    nil
  )
)

(defun cp:sort-points-xy (points)
  (vl-sort points
    '(lambda (a b)
      (if (= (car a) (car b))
        (< (cadr a) (cadr b))
        (< (car a) (car b))
      )
    )
  )
)

(defun cp:draw-contours (records segments interval contour-layer as-spline-p / min-value max-value level points segment point count)
  (setq count 0)
  (if (and records segments (> interval 0.0))
    (progn
      (setq min-value (cp:min-z records))
      (setq max-value (cp:max-z records))
      (setq level (cp:contour-start-level min-value interval))
      (while (<= level max-value)
        (setq points '())
        (foreach segment segments
          (setq point (cp:segment-intersection-at-z segment level))
          (if point (setq points (cons point points)))
        )
        (setq points (cp:sort-points-xy points))
        (if (> (length points) 1)
          (progn
            (if as-spline-p
              (cp:add-spline points contour-layer)
              (cp:add-lwpolyline points contour-layer)
            )
            (setq count (+ count 1))
          )
        )
        (setq level (+ level interval))
      )
    )
  )
  count
)

(defun cp:settings-list ()
  (list
    (cons "LAYERS" (cp:getenv-default "LAYERS" "VYTYCENI,HRANICE,POTRUBI"))
    (cons "PRECISION" (cp:getenv-default "PRECISION" "3"))
    (cons "COLUMNS" (cp:getenv-default "COLUMNS" (cp:default-columns)))
    (cons "DRAWING_SCALE" (cp:normalize-scale (cp:getenv-default "DRAWING_SCALE" "100") "100"))
    (cons "POINT_NAME_PATTERN" (cp:getenv-default "POINT_NAME_PATTERN" ""))
    (cons "DRAW_POINTS" (cp:getenv-default "DRAW_POINTS" "1"))
    (cons "POINT_LAYER" (cp:getenv-default "POINT_LAYER" "CADPOINTS_POINTS"))
    (cons "LABELS" (cp:getenv-default "LABELS" "1"))
    (cons "LABEL_PAPER_HEIGHT" (cp:getenv-default "LABEL_PAPER_HEIGHT" "2.5"))
    (cons "LABEL_LAYER" (cp:getenv-default "LABEL_LAYER" "CADPOINTS_POINT_LABELS"))
    (cons "DRAW_TABLE" (cp:getenv-default "DRAW_TABLE" "1"))
    (cons "TABLE_SCALE" (cp:normalize-table-scale (cp:getenv-default "TABLE_SCALE" "100")))
    (cons "TABLE_OFFSET_PAPER" (cp:getenv-default "TABLE_OFFSET_PAPER" "50"))
    (cons "TABLE_TEXT_PAPER_HEIGHT" (cp:getenv-default "TABLE_TEXT_PAPER_HEIGHT" "2.5"))
    (cons "TABLE_LAYER" (cp:getenv-default "TABLE_LAYER" "CADPOINTS_TABLE"))
    (cons "DRAW_CONTOURS" (cp:getenv-default "DRAW_CONTOURS" "0"))
    (cons "CONTOUR_INTERVAL" (cp:getenv-default "CONTOUR_INTERVAL" "1000"))
    (cons "CONTOUR_LAYER" (cp:getenv-default "CONTOUR_LAYER" "CADPOINTS_CONTOURS"))
    (cons "CONTOUR_SPLINES" (cp:getenv-default "CONTOUR_SPLINES" "1"))
    (cons "SAMPLE_CURVES" (cp:getenv-default "SAMPLE_CURVES" "1"))
    (cons "CURVE_SAMPLE_INTERVAL" (cp:getenv-default "CURVE_SAMPLE_INTERVAL" "1000"))
  )
)

(defun c:CPSETTINGS (/ layers precision columns drawing-scale point-name-pattern draw-points point-layer labels label-paper-height label-layer draw-table table-scale table-offset-paper table-text-paper-height table-layer draw-contours contour-interval contour-layer contour-splines sample-curves curve-sample-interval)
  (setq layers (getstring T (strcat "\nHladiny oddelene carkou <" (cp:getenv-default "LAYERS" "VYTYCENI,HRANICE,POTRUBI") ">: ")))
  (if (/= layers "") (cp:setenv-value "LAYERS" layers))

  (setq precision (getint (strcat "\nPocet desetinnych mist <" (cp:getenv-default "PRECISION" "3") ">: ")))
  (if precision (cp:setenv-value "PRECISION" (itoa precision)))

  (setq columns (getstring T (strcat "\nSloupce tabulky/CSV <" (cp:getenv-default "COLUMNS" (cp:default-columns)) ">: ")))
  (if (/= columns "") (cp:setenv-value "COLUMNS" columns))

  (setq drawing-scale (getstring T (strcat "\nMeritko vykresu [25/50/100/500/1000] <" (cp:normalize-scale (cp:getenv-default "DRAWING_SCALE" "100") "100") ">: ")))
  (if (/= drawing-scale "")
    (if (cp:valid-scale-p drawing-scale)
      (cp:setenv-value "DRAWING_SCALE" drawing-scale)
      (princ "\nNeplatne meritko vykresu. Hodnota zustala beze zmeny.")
    )
  )

  (setq point-name-pattern (getstring T (strcat "\nPattern nazvu bodu, napr. A-SO01-###; prazdne = suffix hladiny <" (cp:getenv-default "POINT_NAME_PATTERN" "") ">: ")))
  (if (/= point-name-pattern "") (cp:setenv-value "POINT_NAME_PATTERN" point-name-pattern))

  (setq draw-points (getstring T (strcat "\nVykreslit generovane body do samostatne hladiny? [Ano/Ne] <" (cp:getenv-default "DRAW_POINTS" "1") ">: ")))
  (if (/= draw-points "") (cp:setenv-value "DRAW_POINTS" draw-points))

  (setq point-layer (getstring T (strcat "\nHladina generovanych bodu <" (cp:getenv-default "POINT_LAYER" "CADPOINTS_POINTS") ">: ")))
  (if (/= point-layer "") (cp:setenv-value "POINT_LAYER" point-layer))

  (setq labels (getstring T (strcat "\nVlozit popisy bodu textem ve vykresu? [Ano/Ne] <" (cp:getenv-default "LABELS" "1") ">: ")))
  (if (/= labels "") (cp:setenv-value "LABELS" labels))

  (setq label-paper-height (getreal (strcat "\nVyska textu popisku na papire v mm <" (cp:getenv-default "LABEL_PAPER_HEIGHT" "2.5") ">: ")))
  (if label-paper-height (cp:setenv-value "LABEL_PAPER_HEIGHT" (rtos label-paper-height 2 3)))

  (setq label-layer (getstring T (strcat "\nHladina popisku bodu <" (cp:getenv-default "LABEL_LAYER" "CADPOINTS_POINT_LABELS") ">: ")))
  (if (/= label-layer "") (cp:setenv-value "LABEL_LAYER" label-layer))

  (setq draw-table (getstring T (strcat "\nVlozit tabulku bodu do vykresu? [Ano/Ne] <" (cp:getenv-default "DRAW_TABLE" "1") ">: ")))
  (if (/= draw-table "") (cp:setenv-value "DRAW_TABLE" draw-table))

  (setq table-scale (getstring T (strcat "\nMeritko tabulky [25/50/100/500/1000] <" (cp:normalize-table-scale (cp:getenv-default "TABLE_SCALE" "100")) ">: ")))
  (if (/= table-scale "")
    (if (cp:valid-table-scale-p table-scale)
      (cp:setenv-value "TABLE_SCALE" table-scale)
      (princ "\nNeplatne meritko tabulky. Hodnota zustala beze zmeny.")
    )
  )

  (setq table-offset-paper (getreal (strcat "\nOdsazeni tabulky na papire v mm <" (cp:getenv-default "TABLE_OFFSET_PAPER" "50") ">: ")))
  (if table-offset-paper (cp:setenv-value "TABLE_OFFSET_PAPER" (rtos table-offset-paper 2 3)))

  (setq table-text-paper-height (getreal (strcat "\nVyska textu tabulky na papire v mm <" (cp:getenv-default "TABLE_TEXT_PAPER_HEIGHT" "2.5") ">: ")))
  (if table-text-paper-height (cp:setenv-value "TABLE_TEXT_PAPER_HEIGHT" (rtos table-text-paper-height 2 3)))

  (setq table-layer (getstring T (strcat "\nHladina tabulky <" (cp:getenv-default "TABLE_LAYER" "CADPOINTS_TABLE") ">: ")))
  (if (/= table-layer "") (cp:setenv-value "TABLE_LAYER" table-layer))

  (setq draw-contours (getstring T (strcat "\nVykreslit interpolovane vrstevnice podle Z? [Ano/Ne] <" (cp:getenv-default "DRAW_CONTOURS" "0") ">: ")))
  (if (/= draw-contours "") (cp:setenv-value "DRAW_CONTOURS" draw-contours))

  (setq contour-interval (getreal (strcat "\nInterval vrstevnic Z <" (cp:getenv-default "CONTOUR_INTERVAL" "1000") ">: ")))
  (if contour-interval (cp:setenv-value "CONTOUR_INTERVAL" (rtos contour-interval 2 3)))

  (setq contour-layer (getstring T (strcat "\nHladina vrstevnic <" (cp:getenv-default "CONTOUR_LAYER" "CADPOINTS_CONTOURS") ">: ")))
  (if (/= contour-layer "") (cp:setenv-value "CONTOUR_LAYER" contour-layer))

  (setq contour-splines (getstring T (strcat "\nKreslit vrstevnice jako SPLINE? [Ano/Ne] <" (cp:getenv-default "CONTOUR_SPLINES" "1") ">: ")))
  (if (/= contour-splines "") (cp:setenv-value "CONTOUR_SPLINES" contour-splines))

  (setq sample-curves (getstring T (strcat "\nVzorkovat oblouky, spliny a krivky po delce? [Ano/Ne] <" (cp:getenv-default "SAMPLE_CURVES" "1") ">: ")))
  (if (/= sample-curves "") (cp:setenv-value "SAMPLE_CURVES" sample-curves))

  (setq curve-sample-interval (getreal (strcat "\nKrok vzorkovani krivek ve vykresovych jednotkach <" (cp:getenv-default "CURVE_SAMPLE_INTERVAL" "1000") ">: ")))
  (if curve-sample-interval (cp:setenv-value "CURVE_SAMPLE_INTERVAL" (rtos curve-sample-interval 2 3)))

  (princ "\nCadPoints nastaveni ulozeno do profilu AutoCADu.")
  (princ)
)

(defun c:CPEXPORT (/ settings layers precision columns drawing-scale point-name-pattern draw-point-p point-layer label-p label-paper-height label-height label-layer draw-table-p table-scale table-offset-paper table-offset table-text-paper-height table-text-height table-layer draw-contours-p contour-interval contour-layer contour-splines-p sample-curves-p curve-sample-interval file-path ss index entity entity-data entity-type layer handle point-no exported-count records segments result contour-count)
  (setq settings (cp:settings-list))
  (setq layers (cp:split (cdr (assoc "LAYERS" settings)) ","))
  (setq precision (atoi (cdr (assoc "PRECISION" settings))))
  (setq columns (cp:parse-columns (cdr (assoc "COLUMNS" settings))))
  (setq drawing-scale (atof (cdr (assoc "DRAWING_SCALE" settings))))
  (setq point-name-pattern (cdr (assoc "POINT_NAME_PATTERN" settings)))
  (setq *cadpoints-point-name-pattern* point-name-pattern)
  (setq *cadpoints-point-name-counters* nil)
  (setq draw-point-p (cp:yes-value-p (cdr (assoc "DRAW_POINTS" settings))))
  (setq point-layer (cdr (assoc "POINT_LAYER" settings)))
  (setq label-p (cp:yes-value-p (cdr (assoc "LABELS" settings))))
  (setq label-paper-height (atof (cdr (assoc "LABEL_PAPER_HEIGHT" settings))))
  (setq label-height (* label-paper-height drawing-scale))
  (setq label-layer (cdr (assoc "LABEL_LAYER" settings)))
  (setq draw-table-p (cp:yes-value-p (cdr (assoc "DRAW_TABLE" settings))))
  (setq table-scale (atof (cdr (assoc "TABLE_SCALE" settings))))
  (setq table-offset-paper (atof (cdr (assoc "TABLE_OFFSET_PAPER" settings))))
  (setq table-offset (* table-offset-paper table-scale))
  (setq table-text-paper-height (atof (cdr (assoc "TABLE_TEXT_PAPER_HEIGHT" settings))))
  (setq table-text-height (* table-text-paper-height table-scale))
  (setq table-layer (cdr (assoc "TABLE_LAYER" settings)))
  (setq draw-contours-p (cp:yes-value-p (cdr (assoc "DRAW_CONTOURS" settings))))
  (setq contour-interval (atof (cdr (assoc "CONTOUR_INTERVAL" settings))))
  (setq contour-layer (cdr (assoc "CONTOUR_LAYER" settings)))
  (setq contour-splines-p (cp:yes-value-p (cdr (assoc "CONTOUR_SPLINES" settings))))
  (setq sample-curves-p (cp:yes-value-p (cdr (assoc "SAMPLE_CURVES" settings))))
  (setq curve-sample-interval (atof (cdr (assoc "CURVE_SAMPLE_INTERVAL" settings))))

  (setq file-path (getfiled "Ulozit CSV soubor" "cadpoints-export.csv" "csv" 1))

  (if file-path
    (progn
      (setq ss (ssget "_X" '((0 . "LINE,LWPOLYLINE,POLYLINE,ARC,CIRCLE,ELLIPSE,SPLINE"))))
      (setq point-no 1)
      (setq exported-count 0)
      (setq records '())
      (setq segments '())

      (if ss
        (progn
          (setq index 0)
          (while (< index (sslength ss))
            (setq entity (ssname ss index))
            (setq entity-data (entget entity))
            (setq entity-type (cdr (assoc 0 entity-data)))
            (setq layer (cdr (assoc 8 entity-data)))
            (setq handle (cdr (assoc 5 entity-data)))

            (if (member layer layers)
              (progn
                (setq exported-count (+ exported-count 1))
                (cond
                  ((= entity-type "LINE")
                    (setq result (cp:collect-line records segments point-no entity-data layer entity-type handle draw-point-p point-layer label-p label-height label-layer))
                  )
                  ((= entity-type "LWPOLYLINE")
                    (if (and sample-curves-p (cp:lwpolyline-has-bulge-p entity-data))
                      (setq result (cp:collect-sampled-curve records segments point-no entity entity-data layer entity-type handle curve-sample-interval draw-point-p point-layer label-p label-height label-layer))
                      (setq result (cp:collect-lwpolyline records segments point-no entity-data layer entity-type handle draw-point-p point-layer label-p label-height label-layer))
                    )
                  )
                  ((= entity-type "POLYLINE")
                    (if (and sample-curves-p (cp:polyline-curve-like-p entity-data))
                      (setq result (cp:collect-sampled-curve records segments point-no entity entity-data layer entity-type handle curve-sample-interval draw-point-p point-layer label-p label-height label-layer))
                      (setq result (cp:collect-polyline records segments point-no entity layer entity-type handle draw-point-p point-layer label-p label-height label-layer))
                    )
                  )
                  ((member entity-type '("ARC" "CIRCLE" "ELLIPSE" "SPLINE"))
                    (if sample-curves-p
                      (setq result (cp:collect-sampled-curve records segments point-no entity entity-data layer entity-type handle curve-sample-interval draw-point-p point-layer label-p label-height label-layer))
                      (setq result (list records segments point-no))
                    )
                  )
                )
                (setq records (car result))
                (setq segments (cadr result))
                (setq point-no (caddr result))
              )
            )
            (setq index (+ index 1))
          )
        )
      )

      (setq records (reverse records))
      (setq segments (reverse segments))
      (cp:write-csv file-path records columns precision)
      (if (and draw-table-p records columns)
        (cp:draw-table-right records columns precision table-offset table-text-height table-layer)
      )
      (if (and draw-contours-p records segments)
        (setq contour-count (cp:draw-contours records segments contour-interval contour-layer contour-splines-p))
        (setq contour-count 0)
      )

      (princ (strcat "\nCadPoints export dokoncen: " file-path))
      (princ (strcat "\nZpracovano objektu: " (itoa exported-count)))
      (princ (strcat "\nExportovano bodu: " (itoa (length records))))
      (if draw-table-p
        (princ (strcat "\nTabulka vlozena do hladiny: " table-layer))
      )
      (if draw-contours-p
        (princ (strcat "\nVykresleno vrstevnic: " (itoa contour-count) " do hladiny: " contour-layer))
      )
    )
  )
  (princ)
)

(defun c:CPHELP ()
  (princ (strcat "\nCadPoints " *cadpoints-version*))
  (princ "\nPrikazy:")
  (princ "\n  CPSETTINGS - nastaveni hladin, meritka vykresu, nazvu bodu, sloupcu, popisku, tabulky, vrstevnic a vzorkovani krivek")
  (princ "\n  CPEXPORT   - export bodu do CSV, vlozeni generovanych bodu/popisku, tabulky a volitelnych vrstevnic")
  (princ "\nPodporovane entity: LINE, LWPOLYLINE, POLYLINE, ARC, CIRCLE, ELLIPSE, SPLINE.")
  (princ "\nOblouky, kruznice, elipsy, spliny a obloukove polylines lze vzorkovat po nastavitelne delce; vychozi krok je 1000 mm.")
  (princ "\nVykres i tabulka maji samostatne meritko 1:25, 1:50, 1:100, 1:500 nebo 1:1000; papirni hodnoty se nasobi prislusnym meritkem do modelu v mm.")
  (princ "\nKonfigurace sloupcu: FIELD:Label;FIELD:Label. Dostupne FIELD: POINT_NAME, POINT_NO, LAYER, ENTITY_TYPE, HANDLE, VERTEX_NO, Y_SJTSK, X_SJTSK, Z.")
  (princ "\nVrstevnice: aproximace z pruseciku segmentu se zadanou urovni Z; nenahrazuje TIN interpolaci.")
  (princ "\nS-JTSK: hodnoty jsou prevzaty z aktualniho DWG souradneho systemu bez transformace.")
  (princ)
)

(princ (strcat "\nCadPoints " *cadpoints-version* " loaded. Commands: CPEXPORT, CPSETTINGS, CPHELP"))
(princ)
