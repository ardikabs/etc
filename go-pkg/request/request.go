package request

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"time"
)

type Request struct {
	HTTPClient  *http.Client
	Timeout     int
	BaseURL     string
	Path        string
	Method      string
	QueryParams url.Values
	Headers     map[string]string
	Body        io.Reader
}

func (r *Request) setupHTTPCaller() (req *http.Request, err error) {
	u, _ := url.Parse(r.BaseURL)
	u.Path = r.Path

	req, err = http.NewRequest(
		r.Method,
		u.String(),
		r.Body,
	)

	if err != nil {
		return
	}

	for k, v := range r.Headers {
		req.Header.Add(k, v)
	}

	if r.QueryParams.Encode() != "" {
		if req.URL.RawQuery != "" {
			req.URL.RawQuery = req.URL.RawQuery + "&" + r.QueryParams.Encode()
		} else {
			req.URL.RawQuery = r.QueryParams.Encode()
		}
	}

	r.HTTPClient = &http.Client{
		Timeout: time.Duration(r.Timeout) * time.Second,
	}

	return
}

// Call is method to do an http call
func (r *Request) Call() (out []byte, err error) {
	req, err := r.setupHTTPCaller()
	if err != nil {
		errMsg := fmt.Sprintf("Failed to setup http caller")
		log.Fatalf(errMsg)
		return
	}

	res, err := r.HTTPClient.Do(req)
	if err != nil {
		errMsg := fmt.Sprintf("Failed requesting to the API server (%v)", r.BaseURL)
		log.Fatalf(errMsg)
		return
	}

	defer res.Body.Close()

	out, err = ioutil.ReadAll(res.Body)

	if err != nil {
		return
	}

	return
}

// CallWithJsonPayload is method to do an http call for json payload
func (r *Request) CallWithJsonPayload(jsonPayload interface{}) (out []byte, err error) {
	var buf []byte
	if jsonPayload != nil {
		json, _ := json.Marshal(jsonPayload)
		buf = json
	}
	r.Body = bytes.NewBuffer(buf)
	return r.Call()
}
