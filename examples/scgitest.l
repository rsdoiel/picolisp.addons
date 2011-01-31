#!/usr/bin/env p

(load "../lib/scgi.l")
(load "@lib/xhtml.l")

(de notfound (Url) 
   (setq *HTTPStatus "404 Not Found")
   (html 0 "Not found" NIL NIL
      (<h1> NIL "The page '" Url "' could not be found.") 
      (<pre> NIL
         (for V *CGIEnv
            (print V) (prinl)) (prinl)
         (pretty (read-request)) (prinl)
         (pretty (parse-query))) ) ) 

(de mainpage ()
   (html 0 "Hello" NIL NIL
      (<h1> NIL "OHAI WORLD!")) )

(de deepthought (Question)
   (html 0 "Deep Thought says" NIL NIL
      (if (= "answer-to-life" Question)
         (<h1> NIL "42")
         (<h2> NIL "I don't know.") ) ) )

(handle-url 'notfound @URL)
(handle-url 'mainpage "/")
(handle-url 'deepthought "/deepthought/" @Q)

(server 9001)