FROM debian:bookworm

LABEL description="Run Resource Hacker (ResHacker) in a Wine-based Debian Bookworm container"

ENV DEBIAN_FRONTEND=noninteractive
ENV WINEPREFIX=/root/.wine
ENV WINEARCH=win32

# Enable i386 support and install dependencies with retry logic
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    max=5; count=0; \
    until apt-get install -y --no-install-recommends \
        gnupg \
        ca-certificates \
        debian-archive-keyring \
        wget \
        unzip \
        x11-utils \
        xvfb \
        cabextract \
        wine \
        wine32 \
	less \
        winbind ; do \
        count=$((count + 1)); \
        if [ "$count" -ge "$max" ]; then \
            echo "APT install failed after $count attempts."; \
            exit 1; \
        fi; \
        echo "APT failed, retrying in 10s... (attempt $count/$max)"; \
        sleep 10; \
    done; \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root

# Manual install of winetricks (latest upstream)
RUN wget -O /usr/local/bin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks && \
    chmod +x /usr/local/bin/winetricks

# Download Resource Hacker
RUN wget -O reshacker.zip https://www.angusj.com/resourcehacker/resource_hacker.zip && \
    unzip reshacker.zip && \
    rm reshacker.zip

# Initialize Wine (headless setup)
RUN wineboot --init && wineserver -w

# Default command (change as needed)
CMD ["wine", "/root/ResourceHacker.exe", "-help"]

