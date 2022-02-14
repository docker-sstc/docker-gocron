# docker-gocron

## Usage

> Simple way: gocron and gocron-node in same container

```bash
# Step 1: Up
docker run -d --rm \
  -v /path/to/conf:/gocron/conf \
  -v /path/to/log:/gocron/log \
  -v /my/task-scripts:/app \
  -p 5920:5920 \
  sstc/gocron:all

# Step 2: Open 127.0.0.1:5920 to install
```

> Hard ways: gocron and gocron-node are in the different containers, but they're on same host

```bash
# Step 1: Up gocron
docker run -d --name gocron \
  -v /path/to/conf:/gocron/conf \
  -v /path/to/log:/gocron/log \
  --net host \
  sstc/gocron:latest

# Step 2: Open 127.0.0.1:5920 to install

# Step 3: Up gocron-node
docker run -d --name gocron-node \
  -v /path/to/my-task-scripts:/app \
  --net host \
  sstc/gocron:all gocron-node -allow-root
```

> Multiple nodes

```bash
# Step 1: Create certs for main node
docker run --rm \
  -v /path/to/out:/gocron/out \
  sstc/gocron:all ./init-cert.sh

# Step 2: Create certs for worker nodes, do it multiple times with all ips of nodes
docker run --rm \
  -v /path/to/out:/gocron/out \
  sstc/gocron:all ./init-cert.sh 1.2.3.4

# Step 3: Up main node
docker run -d --name gocron \
  -v /path/to/conf:/gocron/conf \
  -v /path/to/log:/gocron/log \
  -v /path/to/out:/gocron/out \
  -p 5920:5920 \
  sstc/gocron:latest

# Step 4: Open 127.0.0.1:5920 to install

# Step 5: Add those to /path/to/conf/app.ini
#   enable_tls = true
#   ca_file    = /gocron/out/Root_CA.crt
#   cert_file  = /gocron/out/127.0.0.1.crt
#   key_file   = /gocron/out/127.0.0.1.key

# Step 6: Restart main node
docker restart gocron

# Step 7: Copy necessary files in /path/to/out to hosts of worker nodes

# Step 6: Go to hosts and run, do this multiple times to up all worker nodes
docker run -d --name gocron-node \
  -v /path/to/out:/gocron/out \
  -v /path/to/my-task-scripts:/app \
  -p 5921:5921 \
  sstc/gocron:all gocron-node -allow-root \
  -enable-tls \
  -ca-file /gocron/out/Root_CA.crt \
  -cert-file /gocron/out/1.2.3.4.crt \
  -key-file /gocron/out/1.2.3.4.key
```
