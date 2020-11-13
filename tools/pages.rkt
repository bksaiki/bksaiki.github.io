#lang racket

(require (only-in xml write-xexpr xexpr->string)
         "common.rkt" "data.rkt")
(provide generate-index)

(define (gather-pages dir)
  (define path (string->path dir))
  (cond
   [(directory-exists? path)
    (for/list ([fname (in-directory dir)]
                #:when (file-exists? fname)
                #:when (equal? (filename-extension fname) #"txt"))
      fname)]
   [else
    (printf "Pages directory does not exist!\n")
    (list)]))

(define (read-lines lines name)
  (unless (equal? (first lines) "###BEGIN HEADER###")
    (error 'read-lines "Expected a header at the top of '~a'" name))
  (define table (make-hash))
  (for ([line (cdr lines)] #:break (equal? line "###END HEADER###"))
    (define kv (string-split line ": "))
    (unless (> (length kv) 1)
      (error 'read-lines "Expected a '<key>: <value> ...' binding in '~a'" name))
    (define key (string->symbol (car kv)))
    (define vals
      (for/list ([v (cdr kv)])
        (if (and (string-prefix? v "\"") (string-suffix? v "\""))
            (substring v 1 (- (string-length v) 1))
            v)))
    (hash-set! table key vals))
  (values table (drop lines (+ (hash-count table) 2))))

(define (read-body lines name)
  (let loop ([lines lines] [strs '()])
    (cond
     [(null? lines)
      (if (null? strs)
          '()
          (list (string-join (reverse strs) " ")))]
     [else
      (if (zero? (string-length (car lines)))
          (cons (string-join (reverse strs) " ") (loop (cdr lines) '()))
          (loop (cdr lines) (cons (car lines) strs)))])))

(define (generate-page fname meta body)
  (define out (open-output-file (build-path *out-dir* fname) #:mode 'text #:exists 'replace))
  (define title (first (hash-ref meta 'title)))
  (define date (first (hash-ref meta 'date)))
  (define lines (read-body body fname))
  (fprintf out "<!doctype html>\n")
  (write-xexpr
   `(html
     (head
      (meta ([charset "utf-8"]))
       (title ,*name*)
       (link ([rel "stylesheet"] [type "text/css"] [href "../main.css"]))
       (link ([rel "stylesheet"] [type "text/css"] [href "../pages.css"])))
     (body
      (div ([id "main-section"])
       (div ([id "header"])
        (h2 ([id "header-title"])
         ,*name*))
       (div ([id "back-button"])
        (p ,@(insert-links "@< Back@" "../pages.html")))
       (h3 ,title)
       (div ([class "section-body"])
        (h4 ([class "pages-header"]) ,date)
        (div ([class "pages-body"])
         ,@(for/list ([line lines])
            (list 'p line)))))))
    out))

(define (generate-page-entry file)
  (define in (open-input-file file #:mode 'text))
  (define lines (port->lines in #:close? #t))
  (define fname (path->string file))
  (define fname* (string-replace fname ".txt" ".html"))
  (define-values (meta body) (read-lines lines fname))
  (hash-set! meta 'link fname*)
  (generate-page fname* meta body)
  meta)

(define (generate-index out)
  (define pages (gather-pages *pages-dir*))
  (define out-dir (build-path *out-dir* *pages-dir*))
  (unless (directory-exists? out-dir)
    (make-directory out-dir))
  (define entries
    (sort (map generate-page-entry pages) <
      #:key (λ (x) (string->number (string-replace (hash-ref x 'date) "-" "")))))
  (fprintf out "<!doctype html>\n")
  (write-xexpr
   `(html
     (head
      (meta ([charset "utf-8"]))
       (title ,*name*)
       (link ([rel "stylesheet"] [type "text/css"] [href "main.css"]))
       (link ([rel "stylesheet"] [type "text/css"] [href "../pages.css"])))
     (body
      (div ([id "main-section"])
       (div ([id "header"])
        (h2 ([id "header-title"])
         ,*name*))
       (div ([id "back-button"])
        (p ,@(insert-links "@< Back@" "index.html")))
       (h3 "Pages")
       (div ([class "section-body"])
        (table ([class "pages-table"])
         (tr
          (th ([style "font-weight: bold;"]) "Date")
          (td ([style "font-weight: bold;"]) "Title")
          (td ([style "font-weight: bold;"]) "Tags")))
       ,(insert-table "pages-table"
         (for/list ([entry entries])
          (let ([date (first (hash-ref entry 'date))]
                [title (first (hash-ref entry 'title))]
                [link (hash-ref entry 'link)]
                [tags (hash-ref entry 'tags)])
            `(,date ,@(insert-links (format "@~a@" title) link) ,@tags))))))))
    out))