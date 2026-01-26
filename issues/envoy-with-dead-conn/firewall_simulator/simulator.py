import os
import socket
import threading
import time

# This is the crucial idle timeout for the "firewall"
# Set to a low value for quick reproduction (e.g., 5 seconds)
# In a real scenario, this would be 350 seconds for AWS Network Firewall
FIREWALL_IDLE_TIMEOUT_SECONDS = int(os.getenv("FIREWALL_IDLE_TIMEOUT", "5"))

def handle_client(client_sock, upstream_host, upstream_port):
    upstream_sock = None
    try:
        upstream_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        upstream_sock.connect((upstream_host, upstream_port))
        print(f"[{time.time()}] Firewall: Connected client {client_sock.getpeername()} to upstream {upstream_host}:{upstream_port}")

        client_closed = threading.Event()
        upstream_closed = threading.Event()

        def transfer_data(src, dest, close_event):
            last_activity = time.time()
            while not close_event.is_set():
                try:
                    # Set a short timeout for select to check for inactivity
                    src.settimeout(1.0) # Check every 1 second
                    data = src.recv(4096)
                    if not data:
                        print(f"[{time.time()}] Firewall: Source {src.getpeername()} closed.")
                        close_event.set()
                        break
                    dest.sendall(data)
                    last_activity = time.time() # Reset activity on data transfer
                except socket.timeout:
                    if time.time() - last_activity > FIREWALL_IDLE_TIMEOUT_SECONDS:
                        print(f"[{time.time()}] Firewall: Idle timeout for connection between {src.getpeername()} and {dest.getpeername()}. Silently closing.")
                        close_event.set() # Signal to close the thread
                        break
                except Exception as e:
                    print(f"[{time.time()}] Firewall: Error during data transfer from {src.getpeername()}: {e}")
                    close_event.set()
                    break

        # Start two-way communication in separate threads
        client_to_upstream_thread = threading.Thread(target=transfer_data, args=(client_sock, upstream_sock, client_closed))
        upstream_to_client_thread = threading.Thread(target=transfer_data, args=(upstream_sock, client_sock, upstream_closed))

        client_to_upstream_thread.start()
        upstream_to_client_thread.start()

        # Wait for either side to close or idle timeout
        client_closed.wait()
        upstream_closed.wait()

    except Exception as e:
        print(f"[{time.time()}] Firewall: Error handling client connection: {e}")
    finally:
        if client_sock:
            try:
                client_sock.shutdown(socket.SHUT_RDWR) # Attempt graceful shutdown
                client_sock.close()
            except OSError as e:
                print(f"[{time.time()}] Firewall: Error closing client socket: {e}")
        if upstream_sock:
            try:
                upstream_sock.shutdown(socket.SHUT_RDWR) # Attempt graceful shutdown
                upstream_sock.close()
            except OSError as e:
                print(f"[{time.time()}] Firewall: Error closing upstream socket: {e}")

def run_firewall_simulator(listen_port, upstream_host, upstream_port):
    server_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server_sock.bind(('', listen_port))
    server_sock.listen(5)
    print(f"[{time.time()}] Firewall Simulator listening on port {listen_port}, proxying to {upstream_host}:{upstream_port} with idle timeout {FIREWALL_IDLE_TIMEOUT_SECONDS}s")

    while True:
        client_sock, addr = server_sock.accept()
        print(f"[{time.time()}] Firewall: Accepted connection from {addr}")
        threading.Thread(target=handle_client, args=(client_sock, upstream_host, upstream_port)).start()

if __name__ == '__main__':
    # The upstream host will be the Docker Compose service name 'upstream_server'
    run_firewall_simulator(8081, 'upstream_server', 8080)