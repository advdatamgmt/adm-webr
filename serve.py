from http.server import SimpleHTTPRequestHandler, HTTPServer

class CustomRequestHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path.startswith('/adm-webr'):
            self.path = self.path[len('/adm-webr'):]
            f = self.send_head()
            if f:
                try:
                    self.copyfile(f, self.wfile)
                finally:
                    f.close()
        elif self.path.endswith('/'):
            if not self.path.startswith("/adm-webr"):
                self.send_response(301)
                self.send_header('Location', 'http://localhost:8000/adm-webr' + self.path + 'index.html')
                self.end_headers()
                return
        else:
            self.send_error(404, "File not found")

def run(server_class=HTTPServer, handler_class=CustomRequestHandler, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Starting server on port', port)
    httpd.serve_forever()

run()
