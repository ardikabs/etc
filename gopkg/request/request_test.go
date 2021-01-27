package request

import (
	"encoding/json"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"net/url"
	"reflect"
	"testing"
)

func TestCall(t *testing.T) {
	expectedMethod := http.MethodGet
	expectedQueryParams := url.Values{}
	expectedQueryParams.Add("pod", "account")
	expectedQueryParams.Add("pod", "infra")

	handler := func(w http.ResponseWriter, r *http.Request) {

		if r.Method != "GET" {
			t.Errorf("expected with method %s, but got method %s", expectedMethod, r.Method)
		}

		if !reflect.DeepEqual(r.URL.Query(), expectedQueryParams) {
			t.Errorf("expected %v but got %v", expectedQueryParams.Encode(), r.URL.Query().Encode())
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{
			"statusCode": 200,
			"data": [
				{
					"id": 2,
					"createdAt": "2020-07-14T04:56:48.843411Z",
					"updatedAt": "2020-07-14T04:56:48.843411Z",
					"deletedAt": null,
					"publicKey": "ssh-rsa abc",
					"user": "fatih infra true",
					"pod": "infra",
					"sudo": true
				},
				{
					"id": 3,
					"createdAt": "2020-07-14T04:56:56.647569Z",
					"updatedAt": "2020-07-14T04:56:56.647569Z",
					"deletedAt": null,
					"publicKey": "ssh-rsa abc",
					"user": "fatih account true",
					"pod": "account",
					"sudo": true
				}
			]
		}`))
	}
	s := httptest.NewServer(http.HandlerFunc(handler))

	defer s.Close()

	type testRequest struct {
		Request
	}

	request := testRequest{}
	request.BaseURL = s.URL
	request.Path = "/hey"
	request.Method = http.MethodGet
	request.Timeout = 5
	request.QueryParams = expectedQueryParams

	_, err := request.Call()

	if err != nil {
		t.Errorf("expected to not get any error, but got %s", err)
	}

}

func TestCallWithJsonPayload(t *testing.T) {
	expectedMethod := http.MethodPost

	type payload struct {
		FirstName string `json:"first_name"`
		LastName  string `json:"last_name"`
	}

	expectedBody := payload{
		FirstName: "John",
		LastName:  "Smith",
	}

	handler := func(w http.ResponseWriter, r *http.Request) {

		if r.Method != "POST" {
			t.Errorf("expected with method %s, but got method %s", expectedMethod, r.Method)
		}

		reqbody, _ := ioutil.ReadAll(r.Body)
		var body payload
		json.Unmarshal(reqbody, &body)

		if !reflect.DeepEqual(body, expectedBody) {
			t.Errorf("expected %v but got %v", expectedBody, body)
		}

		w.Write([]byte(`{
			"createdAt": "2019-04-22T07:52:59.973Z",
			"first_name": "John",
			"last_name": "Smith"
		}`))
	}

	s := httptest.NewServer(http.HandlerFunc(handler))

	defer s.Close()

	type testRequest struct {
		Request
	}

	request := testRequest{}
	request.BaseURL = s.URL
	request.Path = "/hey"
	request.Method = http.MethodPost
	request.Timeout = 5

	_payload := payload{
		FirstName: "John",
		LastName:  "Smith",
	}

	request.CallWithJsonPayload(_payload)
}
