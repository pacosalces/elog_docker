FROM debian:bookworm-slim

# Set environment to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies including git and cmake
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    make \
    gcc \
    g++ \
    libssl-dev \
    ca-certificates \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# Clone ELOG from the official repository
WORKDIR /tmp
RUN git clone https://bitbucket.org/ritt/elog --recursive

# Build ELOG using CMake
WORKDIR /tmp/elog
RUN mkdir build && \
    cd build && \
    cmake .. && \
    make && \
    cp elogd /usr/local/sbin/ && \
    cp elog /usr/local/bin/ && \
    mkdir -p /usr/local/share/elog && \
    if [ -d ../resources ]; then cp -r ../resources /usr/local/share/elog/; fi && \
    if [ -d ../themes ]; then cp -r ../themes /usr/local/share/elog/; fi && \
    if [ -d ../scripts ]; then cp -r ../scripts /usr/local/share/elog/; fi && \
    ls -la /usr/local/share/elog/ && \
    cd / && rm -rf /tmp/*

# Create elog user and group
RUN groupadd -r elog && \
    useradd -r -g elog -s /bin/false elog

# Create directories for ELOG data and config
# Note: You can remove the chown for the mounted directories, as the entrypoint will handle it.
RUN mkdir -p /var/elog/logbooks && \
    mkdir -p /etc/elog && \
    chown -R elog:elog /var/elog

# Copy the entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/

# Make the entrypoint executable
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set the USER to 'root' for the entrypoint to run the chown command
# The entrypoint script will drop to the 'elog' user using su-exec
USER root 

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# Set the default command for the entrypoint (not strictly necessary with exec in entrypoint)
CMD [""]