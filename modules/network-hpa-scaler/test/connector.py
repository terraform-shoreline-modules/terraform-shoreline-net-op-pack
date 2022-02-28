#!/usr/bin/env python3

import random
import select
import socket
import sys
import time

def str_arg(idx, default):
  try:
    return sys.argv[idx]
  except:
    return default

def int_arg(idx, default):
  try:
    return int(sys.argv[idx])
  except:
    return default

def RunClient():
  conns = int_arg(2, 10)
  port = int_arg(3, 5555)
  addr = str_arg(4, '127.0.0.1')

  print("Opening client to ", addr, port, "with ", conns, " connections")

  connections = []
  for c in range(conns):
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.connect((addr, port))
    s.send(b'Hello, world')
    connections.append(s)

  while len(connections) > 0:
    readable, writable, errored = select.select(connections, [], [])
    for s in readable:
      try:
        data = s.recv(1024)
      except:
        data = None
      if data:
        #s.send(data)
        print('Received', repr(data))
      else:
        print('Peer closed', repr(s.getsockname()))
        s.close()
        connections.remove(s)
        # re-establish ...
        s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        s.connect((addr, port))
        s.send(b'Hello, world')
        connections.append(s)

def RunServer():
  port = int_arg(2, 5555)

  print("Opening server port ", port)
  server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
  server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
  server_socket.bind(('', port))
  server_socket.listen(5)
  print("Listening on port ", port)

  read_list = [server_socket]
  while True:
    readable, writable, errored = select.select(read_list, [], [], .1)
    for s in readable:
      if s is server_socket:
        client_socket, address = server_socket.accept()
        read_list.append(client_socket)
        print("Connection from", address)
      else:
        data = s.recv(1024)
        if data:
          s.send(data)
        else:
          s.close()
          read_list.remove(s)
    # randomly close some
    if (len(readable) == 0) and (len(read_list) > 40):
      to_close = random.choice(read_list)
      if to_close is not server_socket:
        to_close.close()
        read_list.remove(to_close)
   

def main():
  action = str_arg(1, 'server')
  if action == 'server':
    RunServer()
  elif action == 'client':
    RunClient()
  else:
    print("Unknown action (not client or server): ", action)

if __name__ == "__main__":
    main()

