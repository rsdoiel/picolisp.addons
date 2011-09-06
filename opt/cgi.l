# 05sep11jir
# (c) Jose I. Romero
# *UrlHandlers

(de read-request ()
   (make
      (do (format (cgienv "CONTENT_LENGTH"))
         (link (char (rd 1))) ) ) )

(de querypack (Q)
   (ht:Pack (replace Q "+" " ")))

(de url-decode (Q)
   (mapcar
      '[(F)
        (let Field (split F "=")
           (cons
              (querypack (car Field))
              (querypack (cadr Field)) ) ) ] 
      (split (chop Q) ";" "&") ) )

(de parse-query ()
   (url-decode (cgienv "QUERY_STRING")) )

(de dh A
   (push '*UrlHandlers
      (cons
         (mapcan
            '[(X)
              (or (and (pat? X) (list @)) (chop X))] (car A) )
         (cdr A) ) ) )

(de req-handler () 
   (let URL (chop (cgienv "PATH_INFO") ) 
      (for Handler *UrlHandlers
         (T
            (if (match (car Handler) URL)
               (run (cdr Handler)) ) ) ) ) )

(de res-header (Stat Typ Upd . Prg)
   (prinl "Status: " (or Stat "200 OK") "^M")
   (prinl "Content-type: " (or Typ "text/plain") "^M")
   (when Upd
      (prinl "Cache-Control: max-age=" Upd "^M")
      (when (=0 Upd)
         (prinl "Cache-Control: private, no-store, no-cache^M") ) )
   (run Prg)
   (prinl "^M") )

(default cgienv sys) # CGI environment by default is the system environment

# http.l compatibility layer

(de httpHead (Typ Upd File Att)
   (res-header *HTTPStatus (or Typ "text/html; charset=utf-8") Upd) )

(def 'sesId prog) # Url sesId not implemented
(def 'baseHRef nil) # Not necessary, call depends on *Port and *Host
(def 'srcUrl prog) # Override this for another source URL

`*Doc
(document
   'req-handler "(req-handler)

Handle a CGI request. Go trough all '*UrlHandlers and execute the
first one that matches the URL in the request. The handler is
passed all parameters extracted from the URL pattern match, see
'dh for more information on them. Override this function for
custom request handling." )

(document
   'dh "(dh pat . prg)

Define a URL handler. When the default 'req-handler matches pat, the
prg body is executed. The format and behavior of this pattern is
similar to that of 'match (in fact it uses it internally). The URL
string only matches the whole pattern, variables can be specified with
symbols starting in @.

Examples:

  (dh (\"/\")
     (html 0 \"Hello\" NIL NIL
        (<h1> NIL \"Hello World!\") ) )

  (dh (\"/news/story/\" @S)
     (html 0 \"News \" NIL NIL
        (<h1> NIL \"Showing News Story: \" @S) ))

Notes:

* URL matching is done in the inverse order of which the handlers were
defined, and it stops trying as soon as the first handler succeeds.
Thus, to achieve correct behavior you should define the most general
handlers first and then register more specific ones.

* A successful handler must return non-NIL, otherwise the next one
will be tried." )