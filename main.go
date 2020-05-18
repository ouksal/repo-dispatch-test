package main

import (
	"crypto/tls"
	"fmt"
	"net/http"

	"golang.org/x/crypto/acme/autocert"
)

func main() {
	//mux := http.NewServeMux()
	//mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
	//  w.Write([]byte("Hello world"))
	//})
	http.Handle("/", http.FileServer(http.Dir("./static")))

	http.HandleFunc("/selam", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Selamun Aleykum")
	})

	certManager := autocert.Manager{
		Prompt: autocert.AcceptTOS,
		Cache:  autocert.DirCache("cert-cache"), //<-- 2nd version:  /cert-cache
		// Put your domain here:
		HostPolicy: autocert.HostWhitelist("uksal.com", "www.uksal.com"),
	}

	server := &http.Server{
		Addr: ":443",
		TLSConfig: &tls.Config{
			GetCertificate: certManager.GetCertificate,
		},
	}

	go http.ListenAndServe(":80", certManager.HTTPHandler(nil))
	server.ListenAndServeTLS("", "")
}
