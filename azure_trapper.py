#!/usr/bin/python

"""
Save this file as server.py
>>> python server.py 0.0.0.0 8001
serving on 0.0.0.0:8001

or simply

>>> python server.py
Serving on localhost:8000

You can use this to test GET and POST methods.

"""

import SimpleHTTPServer
import SocketServer
import logging
import cgi
import re
import json
import sys

# port 
PORT = 8000
# interface
I = ""

class ServerHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):
    def do_GET(self):
        SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

    def do_POST(self):
	logging.basicConfig(level=logging.DEBUG, filename="trap_azu.log",format="%(asctime)s %(message)s", datefmt='%Y-%m-%d %H:%M:%S')
	form = cgi.FieldStorage(
            fp=self.rfile,
            headers=self.headers,
            environ={'REQUEST_METHOD':'POST',
                     'CONTENT_TYPE':self.headers['Content-Type'],
                     })
	result = re.sub('.*\'(.+?)\'.*', '\\1', form.value)
        j = json.loads(result)
        logging.debug(j['context']['resourceName']+" "+"["+j['context']['name']+"] "+"<description= "+j['context']['description']+"> "+"<status= "+j['status']+">")
	SimpleHTTPServer.SimpleHTTPRequestHandler.do_GET(self)

Handler = ServerHandler
httpd = SocketServer.TCPServer(("", PORT), Handler)
httpd.serve_forever()
