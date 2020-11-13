#lang racket

(provide insert-links insert-table)

(define (insert-links str . links)
  (define splits
    (let loop ([splits (string-split str "@")])
      (cond
       [(null? splits) '()]
       [(= (length splits) 1) splits]
       [(= (length splits) 2)
        (define next (cadr splits))
        (if (zero? (string-length next))
            (list (string-append (car splits) "@"))
            (cons (car splits) (loop (cdr splits))))]
       [else
        (define next (cadr splits))
        (if (zero? (string-length next))
            (cons (string-append (car splits) "@" (caddr splits)) (loop (cdddr splits)))
            (cons (car splits) (loop (cdr splits))))])))
  (for/fold ([r '()] [link? (string-prefix? str "@")] [links links] #:result (reverse r))
            ([s splits])
    (cond
     [(zero? (string-length s))
      (values (cons "@" r) link? links)]
     [link?
      (values (cons `(a ([href ,(car links)]) ,s) r)
              #f (cdr links))]
     [else
      (values (cons s r) #t links)])))

(define (insert-table id data)
  `(table ([class ,id])
    ,@(for/list ([row data])
       `(tr (th ,(car row))
            ,@(for/list ([col (cdr row)]) `(td ,col))))))