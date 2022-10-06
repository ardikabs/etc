# k8s-health-monitor

## Usage
```bash
$ mv health-monitor.sh /usr/local/bin/
$ cp health-monitor@.service /etc/systemd/system/
$ sudo systemctl daemon-reload

# Enable health-monitor
$ sudo systemctl enable health-monitor@docker
$ sudo systemctl enable health-monitor@kubelet

# Starting health-monitor
$ sudo systemctl start health-monitor@docker
$ sudo systemctl start health-monitor@kubelet
```