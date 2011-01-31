# 29jan11jir
# (c) Jose I. Romero
(setq *UrlHandlers)

(de server (P)
   (setq P (port P))
   (gc)
   (loop
	  (setq *Sock (listen P))
      (NIL (fork) (close P))
      (close *Sock) )
   (scgi *Sock)
   (bye) )

(de scgi (S)
   (in S
      (setq
         "Header" (split (make
                            (do (format (till ":" T))
                               (link (char (rd 1))) ) ) NIL )
         *CGIEnv (make
                    (while (car "Header")
                       (link (cons
                                (pack (pop '"Header"))
                                (pop '"Header") ) ) ) ) )
      (char) ) # Drop comma
   (out S (req-handler)) )

(de cgienv (Key)
   (cdr (assoc Key *CGIEnv)) )

(de read-request ()
   (make
      (do (format (pack (cgienv "CONTENT_LENGHT")))
         (link (char (rd 1))) ) ) )

(de querypack (Q)
   (ht:Pack (replace Q "+" " ")))

(de parse-query ()
   (let Q (split (chop (cgienv "QUERY_STRING")) ";" "&")
      (make
         (while (setq F (split (pop 'Q) "="))
            (link
               (cons
                  (querypack (car F))
                  (cadr F) ) ) ) ) ) )

(de handle-url (Fun . Pat)
   (push '*UrlHandlers
      (cons
         (mapcan '((X) (or
                          (and (pat? X) (list @))
                          (chop X) ) ) Pat ) 
         Fun
         (mapcar '((X) (or
                          (pre? '@* X)
                          (list 'pack X) ) ) 
            (filter pat? Pat) ) ) ) )

(de req-handler ()
   (let URL (chop (ht:Pack (cgienv "SCRIPT_URL")))
      (for Handler *UrlHandlers
         (T
            (if (match (car Handler) URL)
               (eval (cdr Handler)) ) ) ) ) )

(de res-header (Stat Typ Upd . Prg)
   (prinl "Status: " (or Stat "200 OK") "^M")
   (prinl "Content-type: " (or Typ "text/plain") "^M")
   (when Upd
      (prinl "Cache-Control: max-age=" Upd "^M")
      (when (=0 Upd)
         (prinl "Cache-Control: private, no-store, no-cache^M") ) )
   (run Prg)
   (prinl "^M") )

# http.l compatibility layer

(de httpHead (Typ Upd File Att)
   (res-header *HTTPStatus (or Typ "text/html; charset=utf-8") Upd) )

(def 'sesId prog) # Url sesId not implemented
(def 'baseHRef nil) # Not necessary, call depends on *Port and *Host
(def 'srcUrl prog) # Override this for another source URL

`*Doc

(document
   'server "(server 'Port)

Start a SCGI server in the specified port." )

(document
   'scgi "(scgi 'Socket)

Handle a SCGI connection. Read and parse the request header from the specified
socket, set '*CGIEnv with the environment variables passed in the request and
then call 'req-handler to process it." )

(document
   'req-handler "(req-handler)

Handle a SCGI request. Go trough all '*UrlHandlers and execute the first one
that matches the SCRIPT_URL in '*CGIEnv. The handler is passed all parameters
extracted from the URL pattern match, see 'handle-url for more information
on them. Override this function for custom request handling." )

(document
   'handle-url "(handle-url 'Fun 'Delim . 'Pat)

Register an URL handler. Fun specifies a function to be called when the default
'req-handler matches the pattern that follows. The format and behavior of this
pattern is similar to that of 'match (in fact it uses it internally). The URL
string only matches the whole pattern, variables can be specified with symbols
starting in @.

  (handle-url 'mainpage \"/\")
  (handle-url 'news-index \"/news\")
  (handle-url 'story \"/news/story/\" @S)

Notes:
* URL matching is done in the inverse order of which the handlers were
  registered, and it stops trying as soon as the first handler succeeds.
  Thus, to achieve correct behavior you should register the most general
  handlers first and then register more specific ones.
* A successful handler must return non-NIL, otherwise the next one will be
  tried." )