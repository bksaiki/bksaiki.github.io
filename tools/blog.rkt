#lang racket

(require (only-in xml write-xexpr xexpr->string)
         (only-in markdown parse-markdown)
         "common.rkt" "data.rkt")

(provide generate-index)

(define (gather-pages dir)
  (define path (string->path dir))
  (cond
   [(directory-exists? path)
    (for/list ([fname (in-directory dir)]
                #:when (file-exists? fname)
                #:when (equal? (filename-extension fname) #"md"))
      fname)]
   [else
    (printf "Blog directory does not exist!\n")
    (list)]))

(define (read-lines lines name)
  (unless (equal? (first lines) "---")
    (error 'read-lines "Expected a header at the top of '~a'" name))
  (define table (make-hash))
  (for ([line (cdr lines)] #:break (equal? line "---"))
    (define kv (string-split line ": "))
    (unless (> (length kv) 1)
      (error 'read-lines "Expected a '<key>: <value> ...' binding in '~a'" name))
    (define key (string->symbol (string-downcase (car kv))))
    (define vals
      (for/list ([v (cdr kv)])
        (if (and (string-prefix? v "\"") (string-suffix? v "\""))
            (substring v 1 (- (string-length v) 1))
            v)))
    (hash-set! table key vals))
  (values table (filter non-empty-string? (drop lines (+ (hash-count table) 3)))))

(define (read-body lines)
  (for/list ([line lines])
    (car (parse-markdown line))))

(define (generate-page fname meta body)
  (define out (open-output-file (build-path *out-dir* fname) #:mode 'text #:exists 'replace))
  (define title (first (hash-ref meta 'title)))
  (define date (first (hash-ref meta 'date)))
  (define updated (first (hash-ref meta 'last)))
  (define lines (read-body body))
  (fprintf out "<!doctype html>\n")
  (write-xexpr
   `(html
     (head
      (meta ([charset "utf-8"]))
       (title ,*name*)
       (link ([rel "stylesheet"] [type "text/css"] [href "../main.css"]))
       (link ([rel "stylesheet"] [type "text/css"] [href "../blog.css"])))
     (body
      (div ([id "main-section"])
       (div ([id "header"])
        (h2 ([id "header-title"])
         ,*name*))
       (div ([id "back-button"])
        (p ,@(insert-links "@< Back@" "../blog.html")))
       (h3 ,title)
       (div ([class "section-body"])
        (h4 ([class "blog-header"]) ,date)
        (div ([class "blog-body"])
          ,@lines)
        (div ([id "postscript"])
          (p ,(format "Last updated: ~a" updated)))))))
    out))

(define (generate-page-entry file)
  (define in (open-input-file file #:mode 'text))
  (define lines (port->lines in #:close? #t))
  (define fname (path->string file))
  (define fname* (string-replace fname ".md" ".html"))
  (define-values (meta body) (read-lines lines fname))
  (hash-set! meta 'link fname*)
  (generate-page fname* meta body)
  meta)

(define (generate-index out)
  (define pages (gather-pages *blog-dir*))
  (define out-dir (build-path *out-dir* *blog-dir*))
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
       (link ([rel "stylesheet"] [type "text/css"] [href "blog.css"])))
     (body
      (div ([id "main-section"])
       (div ([id "header"])
        (h2 ([id "header-title"])
         ,*name*))
       (div ([id "back-button"])
        (p ,@(insert-links "@< Back@" "index.html")))
       (h3 "Blog")
       (div ([class "section-body"])
       ,(insert-table "blog-table"
         (cons
          (list "Date" "Title" "Tags")
          (for/list ([entry entries])
            (let ([date (first (hash-ref entry 'date))]
                  [title (first (hash-ref entry 'title))]
                  [link (hash-ref entry 'link)]
                  [tags (hash-ref entry 'tags)])
              `(,date ,@(insert-links (format "@~a@" title) link) ,@tags))))
         #:bold? #t)))))
    out))