# 05sep11jir
# (c) Jose I. Romero
# *CGIEnv

(de server (P)
   (setq P (port P))
   (gc)
   (loop
      (setq *Sock (listen P))
      (and reload (reload))
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
                                (pack (pop '"Header")) ) ) ) ) )
      (char) ) # Drop comma
   (out S (req-handler)) )

(de cgienv (Key)
   (cdr (assoc Key *CGIEnv)) )

`*Doc

(document
   'server "(server 'Port)

Start a SCGI server in the specified port." )

(document
   'scgi "(scgi 'Socket)

Handle a SCGI connection. Read and parse the request header from the
specified socket, set '*CGIEnv with the environment variables passed
in the request and then call 'req-handler to process it." )