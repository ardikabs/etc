import multiprocessing
import threading
import time

from flask import Flask, jsonify, request

app = Flask(__name__)
memory_hog = []
cpu_hog_processes = []
leak_running = False
cpu_running = False

def memory_leak_simulator():
    global memory_hog, leak_running
    while leak_running:
        memory_hog.append(" " * 10**6)  # Allocate 1MB
        time.sleep(1)  # Gradual allocation

def cpu_stress_simulator():
    while True:
        _ = 1 + 1  # Simple CPU loop

@app.route('/start', methods=['POST'])
def start():
    global leak_running, cpu_running, cpu_hog_processes

    resource = request.args.get('resource', 'memory').lower()
    if resource == "memory":
        if not leak_running:
            leak_running = True
            thread = threading.Thread(target=memory_leak_simulator)
            thread.start()
            return jsonify({"status": "Memory leak started"}), 200
        return jsonify({"status": "Memory leak already running"}), 400
    elif resource == "cpu":
        if not cpu_running:
            cpu_running = True
            cpu_hog_processes = [
                multiprocessing.Process(target=cpu_stress_simulator)
                for _ in range(multiprocessing.cpu_count())
            ]
            for process in cpu_hog_processes:
                process.start()
            return jsonify({"status": "CPU stress started"}), 200
        return jsonify({"status": "CPU stress already running"}), 400
    return jsonify({"error": "Invalid resource type"}), 400

@app.route('/stop', methods=['POST'])
def stop():
    global leak_running, cpu_running, memory_hog, cpu_hog_processes

    resource = request.args.get('resource', 'memory').lower()
    if resource == "memory":
        if leak_running:
            leak_running = False
            memory_hog = []  # Clear memory
            return jsonify({"status": "Memory leak stopped"}), 200
        return jsonify({"status": "No memory leak running"}), 400
    elif resource == "cpu":
        if cpu_running:
            cpu_running = False
            for process in cpu_hog_processes:
                process.terminate()
            cpu_hog_processes = []
            return jsonify({"status": "CPU stress stopped"}), 200
        return jsonify({"status": "No CPU stress running"}), 400
    return jsonify({"error": "Invalid resource type"}), 400

@app.route('/status', methods=['GET'])
def status():
    return jsonify({
        "memory_leak_running": leak_running,
        "cpu_stress_running": cpu_running,
        "memory_allocated_mb": len(memory_hog),
        "cpu_cores_stressed": len(cpu_hog_processes)
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)