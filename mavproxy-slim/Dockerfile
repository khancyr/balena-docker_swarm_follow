FROM python:3-slim AS builder
################################################################################
### Install minimal build tools and remove cache. Don't do any update

RUN apt-get update && apt-get install --no-install-recommends -y \
    git \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV DISABLE_MAVNATIVE=True
RUN python3 -m pip install --user --no-deps future websockets pymavlink pyserial

RUN python3 -m pip install --user --no-deps git+https://github.com/khancyr/MAVProxy.git@test_cesium -U

# Second stage build
FROM python:3-slim

WORKDIR /mavproxy

ENV DISABLE_MAVNATIVE=True
# copy only the dependencies installation from the 1st stage image
COPY --from=builder /root/.local /root/.local

ENV PATH=/root/.local/bin:$PATH
################################################################################
#### Setup the entrypoint == application that will launch by default

COPY entrypoint.sh /bin/entrypoint
ENTRYPOINT ["entrypoint"]
