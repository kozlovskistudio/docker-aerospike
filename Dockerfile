FROM debian:8
MAINTAINER Vladimir Kozlovski <inbox@vladkozlovski.com>
ENV DEBIAN_FRONTEND noninteractive

ENV AEROSPIKE_VERSION 3.10.0.3
ENV AEROSPIKE_SHA256 4fa55d0ee07bd593e39cbb6e3d8df981e8c7abde8ccffab5cae2ca1dc6f3e62d

ENV AEROSPIKE_TOOLS_VERSION 3.10.2
ENV AEROSPIKE_TOOLS_SHA256 5a1714b982bf5a01b299a2c686b484a53997ef6bc9619473fcb89eff93a22fef

# Install Aerospike
RUN \
  apt-get update -y \
  && apt-get install -y wget logrotate ca-certificates python --no-install-recommends \

  # download aerospike server
  && wget "http://artifacts.aerospike.com/aerospike-server-community/${AEROSPIKE_VERSION}/aerospike-server-community-${AEROSPIKE_VERSION}-debian8.tgz" -O aerospike-server.tgz \
  && echo "$AEROSPIKE_SHA256 *aerospike-server.tgz" | sha256sum -c - \
  && mkdir aerospike \
  && tar xzf aerospike-server.tgz --strip-components=1 -C aerospike \
  && dpkg -i aerospike/aerospike-server-*.deb \

  # download aerospike tools
  && wget "http://artifacts.aerospike.com/aerospike-tools/${AEROSPIKE_TOOLS_VERSION}/aerospike-tools-${AEROSPIKE_TOOLS_VERSION}-debian8.tgz" -O aerospike-tools.tgz \
  && echo "$AEROSPIKE_TOOLS_SHA256 *aerospike-tools.tgz" | sha256sum -c - \
  && mkdir aerospike-tools \
  && tar xzf aerospike-tools.tgz --strip-components=1 -C aerospike-tools \
  && dpkg -i aerospike-tools/aerospike-tools-*.deb \

  # cleanup
  && apt-get purge -y --auto-remove wget ca-certificates \
  && rm -rf aerospike-server.tgz aerospike aerospike-tools.tgz aerospike-tools /var/lib/apt/lists/*


# Add the Aerospike configuration specific to this dockerfile
COPY aerospike.conf /etc/aerospike/aerospike.conf
COPY entrypoint.sh /entrypoint.sh

# Mount the Aerospike data directory
VOLUME ["/opt/aerospike/data"]
# VOLUME ["/etc/aerospike/"]


# Expose Aerospike ports
#
#   3000 – service port, for client connections
#   3001 – fabric port, for cluster communication
#   3002 – mesh port, for cluster heartbeat
#   3003 – info port
#
EXPOSE 3000 3001 3002 3003

# Execute the run script in foreground mode
ENTRYPOINT ["/entrypoint.sh"]
CMD ["asd"]
