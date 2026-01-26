import json
import time
from http.server import BaseHTTPRequestHandler, HTTPServer


class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        print(f"[{time.time()}] Received GET request from {self.client_address[0]}:{self.client_address[1]}")
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response_data = {"status": "success", "message": "Hello from Upstream!"}
        self.wfile.write(json.dumps(response_data).encode('utf-8'))

    def do_POST(self):
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length)
        print(f"[{time.time()}] Received POST request from {self.client_address[0]}:{self.client_address[1]} with data: {post_data.decode('utf-8')}")
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response_data = {"status": "success", "message": "POST received!", "data": post_data.decode('utf-8')}
        self.wfile.write(json.dumps(response_data).encode('utf-8'))

def run(server_class=HTTPServer, handler_class=SimpleHandler, port=8080):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f"[{time.time()}] Starting upstream server on port {port}...")
    httpd.serve_forever()

if __name__ == '__main__':
    run()