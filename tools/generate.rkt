#lang racket

(require (only-in xml write-xexpr xexpr->string))
(require "data.rkt" "common.rkt" "blog.rkt")

(define (generate-main out)
  (fprintf out "<!doctype html>\n")
  (write-xexpr
   `(html
     (head
      (meta ([charset "utf-8"]))
       (title ,(~a *name*))
       (link ([rel "stylesheet"] [type "text/css"] [href "main.css"])))
     (body
      (div ([id "main-section"])
       (div ([id "header"])
        (h2 ([id "header-title"])
         ,(~a *name*)))
       (h3 "About Me")
       (div ([class "section-body"])
        (div ([class "clearfix"])
         (img ([id "personal-image"] [src "resources/bsaiki.jpg"] [alt "Brett Saiki"]))
         (p ,@(apply insert-links *self-description*))
         ,(insert-table "contact-info" *contact-info*)
         (p ([class "note"]) "* If you wish to contact me about my research, please use my UW email address.")
         ,(insert-table "contact-info" *personal-links*)))
       (h3 "Research")
       (div ([class "section-body"])
        ,@(for/list ([elem *research-projects*])
           `(p ,@(apply insert-links elem))))
       (h3 "Publications")
       (div ([class "section-body"])
        (table ([id "publication-table"])
          ,@(for/list ([entry *publications*])
              (let ([conf (dict-ref entry 'conf)]
                    [title (dict-ref entry 'title)]
                    [author (dict-ref entry 'author)]
                    [other (filter-not (compose (curry set-member? '(conf title author)) car) entry)])
                `(tr (td (b ,title)
                         (br ,author)
                         (i ,conf)
                         (br ,@(for/list ([elem other])
                                (first (insert-links (format "@~a@" (car elem)) (cdr elem)))))))))))
       (h3 "Side Projects")
       (div ([class "section-body"])
        ,@(for/list ([elem *side-projects*])
           `(p ,@(apply insert-links elem))))
       (h3 "Resources")
       (div ([class "section-body"])
        ,@(for/list ([elem *resource-links*])
           `(p ,@(apply insert-links elem))))
       (h3 "News")
       (div ([class "section-body"])
        ,@(for/list ([elem *news-entries*])
           `(div ([class "news-entry"])
             (h5 ,(car elem))
             (p ,@(apply insert-links (cdr elem))))))
      )))
    out))

(module+ main
  (printf "Generating website pages...\n")
  (printf "Rendering main page ... \n")
  (call-with-output-file (build-path *out-dir* *main-page*)
    #:exists 'replace
    (λ (out) (generate-main out)))
  (printf "Rendering blog ...\n")
  (call-with-output-file (build-path *out-dir* *blog-index*)
    #:exists 'replace
    (λ (out) (generate-index out)))
  (printf "Done\n")
  (exit 0))
