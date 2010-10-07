;;; -*- mode:lisp; package:oauth -*-

(eval-when (:compile-toplevel :load-toplevel :execute)
  (require 'cmu_loop)
  (require 'xml-http-request))

(defpackage :oauth
  (:use :lisp :editor))

(in-package "oauth")

(export '(auth-header
	  get-access-token))

;;; utility
(defmacro whenlet (var test &body body)
  `(let ((,var ,test)) (when ,var ,@body)))

(defun random-string (size)
  (make-random-state t)
  (map 'string #'(lambda (_) (char "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ\
abcdefghijklmnopqrstuvwxyz" (random 62)))
       (make-list size)))

(defun time-stamp ()
  (- (get-universal-time)
     #.(encode-universal-time 0 0 0 1 1 1970 0)))

(defun url-encode (str)
  (let ((utf8str (convert-encoding-from-internal *encoding-utf8n* str)))
    (si:www-url-encode utf8str nil "0-9A-Za-z-._~")))


;;; signature
(defun hmac-sha-1-bin (key str)
  (let ((h (si:hmac-sha-1 key str))
	(s (make-sequence 'string 20)))
    (dotimes (i 20 s)
      (setf (svref s i)
	    (code-char (parse-integer h :start (* i 2) :end (* (1+ i) 2)
				      :radix 16))))))

(defun signature (cred method apiurl params)
  (let* ((sorted (sort (loop for (k v) on params by #'cddr
			 collect
			 (list (format nil "~A" k)
			       (url-encode (format nil "~A" (or v "")))))
		       #'string<= :key #'car))
	 (key (format nil "~A&~@[~A~]"
		      (getf cred :consumer-secret)
		      (getf cred :token-secret)))
	 (doc (format nil "~:@(~A~)&~A&~A"
		      method
		      (url-encode apiurl)
		      (url-encode (format nil "~{~{~A=~A~}~^&~}" sorted)))))
    (remove #\LFD (si:base64-encode (hmac-sha-1-bin key doc)))))


;;; request
(defun make-params (cred)
  (list*
   :oauth_consumer_key (getf cred :consumer-key)
   :oauth_nonce (random-string 32)
   :oauth_signature_method "HMAC-SHA1"
   :oauth_timestamp (time-stamp)
   :oauth_version "1.0"
   (whenlet token (getf cred :token)
     (list :oauth_token token))))

(defun get-token (url cred &optional verifier)
  (let* ((auth (auth-header cred 'get url
			    (if verifier `(:oauth_verifier ,verifier))))
	 (query (format nil "~A~@[&oauth_verifier=~A~]"
		  (substitute-string (subseq auth 6) ", " "&")
		  verifier)))
    (multiple-value-bind (res status)
	(xhr:xhr-get url :query query :header `(:Authorization ,auth)
		     :key #'xhr:xhr-response-values)
      (if (= status 200)
	  (let ((token (and (string-match "oauth_token=\\([^&]+\\)" res)
			    (match-string 1)))
		(secret (and (string-match "oauth_token_secret=\\([^&]+\\)" res)
			     (match-string 1))))
	    (if (and token secret)
		(values (list :token token :token-secret secret) res)
	      (error (concat "failed getting token:\n" url))))
	(error (format nil "HTTP status: ~A" status))))))


;;; exports
(defun auth-header (cred method apiurl params)
  (let* ((oauth-params (make-params cred))
	 (all-params (append oauth-params params))
	 (sign (signature cred method apiurl all-params)))
    (format nil "OAuth ~{~A=~A, ~}oauth_signature=~A"
            oauth-params (url-encode sign))))


(defun get-access-token (consumer-key consumer-secret
			 request-token-url authorize-url access-token-url)
  (let ((cred (list :consumer-key consumer-key
		    :consumer-secret consumer-secret)))
    (whenlet req-tokens (get-token request-token-url cred)
      (shell-execute (concat authorize-url "?oauth_token=" (getf req-tokens :token)) t)
      (sit-for 1)
      (whenlet pin (read-string "PIN: ")
	(get-token access-token-url (append cred req-tokens) pin)))))
