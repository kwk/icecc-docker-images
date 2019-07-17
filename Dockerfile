FROM fedora:29 AS base

LABEL maintainer="Konrad Kleine <kkleine@redhat.com>"
LABEL author="Konrad Kleine <kkleine@redhat.com>"
LABEL description="An icecream image based on Fedora 29 that I use for distributed compilation of LLVM"
ENV LANG=en_US.utf8

RUN dnf install -y \
    icecream \
    htop \
   && yum clean all

ENV HOME=/home/icecc
RUN mkdir -p /home/icecc && \
    chown icecc:icecc /home/icecc -Rv

# ------------------------------------------------------------------------------

FROM base AS scheduler
ENTRYPOINT [\
  "icecc-scheduler", \
  "--port", "8765", \
  "--user-uid", "icecc", \
  "-vvv" \
]
CMD [\
  "--netname", "llvm" \
]
EXPOSE 8765/tcp

# https://docs.docker.com/engine/reference/builder/#healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
  CMD curl -f http://0.0.0.0:8765/ || exit 1

# ------------------------------------------------------------------------------

FROM base AS daemon

# Define how to start icecc by default
# (see "man icecc" for more information)
ENTRYPOINT [\
  "iceccd", \
  "--user-uid", "icecc", \
  "--cache-limit", "200", \
  "-vvv" \
]
#  "--scheduler-host tofu.yyz.redhat.com", \
 #"--env-basedir", "/home/icecc/envs", \
CMD [\
  "--nice", "5", \
  "--netname", "llvm", \
  "--max-processes", "5" \
]

EXPOSE \
  10245/tcp \
  8766/tcp

VOLUME /home/icecc/envs

# https://docs.docker.com/engine/reference/builder/#healthcheck
HEALTHCHECK --interval=5m --timeout=3s \
   CMD curl -f http://0.0.0.0:10245/ || exit 1
