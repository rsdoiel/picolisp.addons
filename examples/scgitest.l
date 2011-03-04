#!/usr/bin/env p

(load "@opt/scgi.l")
(load "@lib/xhtml.l")

(dh ("/" @Url)
   (setq *HTTPStatus "404 Not Found")
   (html 0 "Not found" NIL NIL
      (<h1> NIL "The page '" @Url "' could not be found.") 
      (<pre> NIL
         (for V *CGIEnv
            (print V) (prinl)) (prinl)
         (pretty (read-request)) (prinl)
         (pretty (parse-query))) ) ) 

(dh ("/")
   (html 0 "Hello" NIL NIL
      (<h1> NIL "OHAI WORLD!")) )

(dh ("/deephought/" @Question)
   (html 0 "Deep Thought says" NIL NIL
      (if (= "answer-to-life" (pack @Question))
         (<h1> NIL "42")
         (<h2> NIL "I don't know.") ) ) )

(de go ()
   (server 9001) )

(load T)
(prinl "Type (go) to start the scgi server in port 9001")