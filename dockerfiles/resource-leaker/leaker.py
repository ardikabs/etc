import mmap
import multiprocessing
import os
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

@app.route('/v1/start', methods=['POST'])
def post_v1_start():
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

@app.route('/v1/stop', methods=['POST'])
def post_v1_stop():
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

@app.route('/v1/status', methods=['GET'])
def get_v1_status():
    return jsonify({
        "memory_leak_running": leak_running,
        "cpu_stress_running": cpu_running,
        "memory_allocated_mb": len(memory_hog),
        "cpu_cores_stressed": len(cpu_hog_processes)
    })

# Global status tracking
v2_status = {
    "cpu": "idle",
    "memory": "idle"
}

def cpu_spike(duration):
    """Simulate a CPU spike by performing intense computation."""
    global status
    status["cpu"] = f"active ({duration}s)"
    start_time = time.time()
    while time.time() - start_time < duration:
        sum(i * i for i in range(10_000))
    status["cpu"] = "idle"

def page_cache_spike(size_mb):
    """Simulate memory usage by filling the page cache with dummy data."""
    global status
    status["memory"] = f"active ({size_mb} MB)"
    temp_file = "/tmp/page_cache_spike.tmp"
    size_bytes = size_mb * 1024 * 1024

    with open(temp_file, "wb") as f:
        f.write(b"0" * size_bytes)

    # Memory-map the file to force it into the page cache
    with open(temp_file, "r+b") as f:
        with mmap.mmap(f.fileno(), length=0, access=mmap.ACCESS_WRITE) as mm:
            mm[:] = b"1" * len(mm)  # Modify the content to keep it "active" in the cache

    # Optionally delay before removing the file
    time.sleep(10)
    os.remove(temp_file)
    status["memory"] = "idle"

@app.route("/v2/start", methods=["POST"])
def post_v2_start():
    resource = request.args.get('resource', 'memory').lower()

    if resource == "cpu":
        """Endpoint to simulate a CPU spike."""
        duration = int(request.json.get("duration", 5))  # default to 5 seconds
        process = multiprocessing.Process(target=cpu_spike, args=(duration,))
        process.start()
        return jsonify({"status": "CPU spike initiated", "duration": duration}), 200

    elif resource == "memory":
        """Endpoint to simulate a memory spike via page cache."""
        size_mb = int(request.json.get("size_mb", 100))  # default to 100 MB
        process = multiprocessing.Process(target=page_cache_spike, args=(size_mb,))
        process.start()
        return jsonify({"status": "Memory (page cache) spike initiated", "size_mb": size_mb}), 200

    return jsonify({"error": "Invalid resource type"}), 400

@app.route("/v2/status", methods=["GET"])
def get_v2_status():
    """Endpoint to get the current status of spikes."""
    return jsonify(status), 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)