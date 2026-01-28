# Dummy Systemd Service

Belajar dasar-dasar systemd dengan membuat custom service yang berjalan di background.

Project reference: [roadmap.sh/projects/dummy-systemd-service](https://roadmap.sh/projects/dummy-systemd-service)

---

## Apa itu Systemd?

Systemd adalah **init system** dan **service manager** di Linux modern. Tugasnya:

- Menjalankan service saat boot
- Mengelola lifecycle service (start, stop, restart)
- Auto-restart service yang crash
- Logging via journald
- Dependency management antar service

---

## Project Structure

```
dummy-systemd-service/
├── dummy.sh          # Script yang akan dijalankan sebagai service
├── dummy.service     # Systemd service configuration
├── setup.sh          # Install script
├── uninstall.sh      # Uninstall script
└── README.md         # Documentation
```

---

## Quick Start

```bash
# Clone repository
git clone https://github.com/amirkurniawan/dummy-systemd-service.git
cd dummy-systemd-service

# Install service
chmod +x setup.sh
sudo ./setup.sh

# Check status
sudo systemctl status dummy

# View logs
sudo journalctl -u dummy -f
```

---

## Files Explanation

### dummy.sh

Script sederhana yang berjalan forever dan menulis log setiap 10 detik.

```bash
#!/bin/bash

LOG_FILE="/var/log/dummy-service.log"

while true; do
    echo "[$(date)] Dummy service is running..." >> "$LOG_FILE"
    sleep 10
done
```

**Features:**
- Graceful shutdown (trap SIGTERM)
- Iteration counter
- Timestamped logging

---

### dummy.service

Systemd unit file yang mendefinisikan bagaimana service dijalankan.

```ini
[Unit]
Description=Dummy Service - Background Application Simulator
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/dummy.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**Sections Explained:**

| Section | Purpose |
|---------|---------|
| `[Unit]` | Metadata dan dependencies |
| `[Service]` | Bagaimana service dijalankan |
| `[Install]` | Kapan service di-enable |

**Key Directives:**

| Directive | Value | Meaning |
|-----------|-------|---------|
| `Type` | simple | Proses utama langsung jalan |
| `ExecStart` | /usr/local/bin/dummy.sh | Command untuk start |
| `Restart` | always | Auto-restart jika crash |
| `RestartSec` | 5 | Tunggu 5 detik sebelum restart |
| `WantedBy` | multi-user.target | Start saat multi-user mode (normal boot) |

---

## Manual Setup

Jika ingin setup manual tanpa script:

### 1. Create the Script

```bash
sudo nano /usr/local/bin/dummy.sh
```

Paste isi `dummy.sh`, lalu:

```bash
sudo chmod +x /usr/local/bin/dummy.sh
```

### 2. Create Service File

```bash
sudo nano /etc/systemd/system/dummy.service
```

Paste isi `dummy.service`.

### 3. Reload Systemd

```bash
sudo systemctl daemon-reload
```

### 4. Start & Enable

```bash
sudo systemctl start dummy
sudo systemctl enable dummy
```

---

## Managing the Service

### Basic Commands

```bash
# Start service
sudo systemctl start dummy

# Stop service
sudo systemctl stop dummy

# Restart service
sudo systemctl restart dummy

# Check status
sudo systemctl status dummy

# Enable (start on boot)
sudo systemctl enable dummy

# Disable (don't start on boot)
sudo systemctl disable dummy
```

### View Logs

```bash
# Using journalctl (recommended)
sudo journalctl -u dummy -f

# Last 50 lines
sudo journalctl -u dummy -n 50

# Logs since today
sudo journalctl -u dummy --since today

# Using log file directly
sudo tail -f /var/log/dummy-service.log
```

---

## Testing Auto-Restart

Fitur `Restart=always` memastikan service restart otomatis jika crash.

```bash
# Cek PID service
sudo systemctl status dummy | grep "Main PID"
# Output: Main PID: 12345 (dummy.sh)

# Kill process untuk simulate crash
sudo kill -9 12345

# Cek status - akan restart otomatis setelah 5 detik
sudo systemctl status dummy
# Output: Active: active (running)... started Xs ago
```

---

## Sample Output

### systemctl status dummy

```
● dummy.service - Dummy Service - Background Application Simulator
     Loaded: loaded (/etc/systemd/system/dummy.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-01-15 10:30:00 WIB; 5min ago
       Docs: https://roadmap.sh/projects/dummy-systemd-service
   Main PID: 12345 (dummy.sh)
      Tasks: 2 (limit: 4567)
     Memory: 1.2M
        CPU: 50ms
     CGroup: /system.slice/dummy.service
             ├─12345 /bin/bash /usr/local/bin/dummy.sh
             └─12380 sleep 10

Jan 15 10:30:00 server systemd[1]: Started Dummy Service.
```

### Log Output

```
[2024-01-15 10:30:00] Dummy service STARTED (PID: 12345)
[2024-01-15 10:30:00] Dummy service is running... (iteration: 1)
[2024-01-15 10:30:10] Dummy service is running... (iteration: 2)
[2024-01-15 10:30:20] Dummy service is running... (iteration: 3)
```

---

## Systemd Cheat Sheet

### Service States

| State | Meaning |
|-------|---------|
| `active (running)` | Service sedang jalan |
| `active (exited)` | Service selesai sukses (oneshot) |
| `inactive (dead)` | Service tidak jalan |
| `failed` | Service crash/error |
| `enabled` | Start otomatis saat boot |
| `disabled` | Tidak start saat boot |

### Common Commands

```bash
# List semua service
systemctl list-units --type=service

# List service yang gagal
systemctl --failed

# Reload config tanpa restart
sudo systemctl reload dummy

# Show service dependencies
systemctl list-dependencies dummy

# Show service properties
systemctl show dummy

# Edit service file
sudo systemctl edit dummy --full
```

### Journalctl Tips

```bash
# Follow logs real-time
journalctl -u dummy -f

# Logs dengan priority error dan di atasnya
journalctl -u dummy -p err

# Logs dalam format JSON
journalctl -u dummy -o json

# Logs antara waktu tertentu
journalctl -u dummy --since "2024-01-15 10:00:00" --until "2024-01-15 12:00:00"

# Disk usage logs
journalctl --disk-usage

# Clear old logs
sudo journalctl --vacuum-time=7d
```

---

## Service Types

| Type | Description | Use Case |
|------|-------------|----------|
| `simple` | Default, langsung jalan | Foreground apps |
| `forking` | Parent exit, child jalan | Daemons (nginx, apache) |
| `oneshot` | Jalankan sekali lalu exit | Scripts, setup tasks |
| `notify` | Service notify systemd saat ready | Apps dengan startup delay |
| `idle` | Tunggu jobs lain selesai | Low priority tasks |

---

## Troubleshooting

### Service Won't Start

```bash
# Check detailed status
sudo systemctl status dummy -l

# Check journal for errors
sudo journalctl -u dummy -xe

# Verify script is executable
ls -la /usr/local/bin/dummy.sh

# Test script manually
sudo /usr/local/bin/dummy.sh
```

### Permission Denied

```bash
# Ensure correct permissions
sudo chmod +x /usr/local/bin/dummy.sh
sudo chmod 644 /etc/systemd/system/dummy.service

# Reload daemon
sudo systemctl daemon-reload
```

### Changes Not Applied

```bash
# Always reload after editing service file
sudo systemctl daemon-reload
sudo systemctl restart dummy
```

---

## Best Practices

1. **Always use absolute paths** in ExecStart
2. **Set appropriate Restart policy** (always, on-failure, etc)
3. **Use security directives** (NoNewPrivileges, ProtectSystem)
4. **Log to journald** instead of custom files when possible
5. **Test service manually** before creating systemd unit
6. **Use `systemctl daemon-reload`** after any changes

---

## Real-World Examples

Contoh service di production:

```bash
# Web server
sudo systemctl status nginx

# Database
sudo systemctl status mysql

# Container runtime
sudo systemctl status docker

# SSH daemon
sudo systemctl status ssh
```

---

## What I Learned

1. **Systemd basics** - Unit files, targets, dependencies
2. **Service lifecycle** - Start, stop, restart, enable, disable
3. **Logging** - journalctl dan log management
4. **Auto-restart** - Keeping services running
5. **Security** - Hardening service configurations

---

## References

- [systemd Documentation](https://systemd.io/)
- [DigitalOcean - Systemd Essentials](https://www.digitalocean.com/community/tutorials/systemd-essentials-working-with-services-units-and-the-journal)
- [Arch Wiki - systemd](https://wiki.archlinux.org/title/systemd)
- [Red Hat - Managing Services with systemd](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/chap-managing_services_with_systemd)

---

*Project completed as part of DevOps learning journey*
