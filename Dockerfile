FROM --platform=linux/amd64 ubuntu:22.04

# Install dependencies for COOL compiler
# - build-essential: gcc, g++, make for building assignments
# - flex, bison: for lexer/parser generation
# - libc6-i386: 32-bit library support for the COOL binaries
# - lib32stdc++6: 32-bit C++ standard library
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      flex \
      bison \
      libc6-i386 \
      lib32stdc++6 && \
    rm -rf /var/lib/apt/lists/*

# Set up COOL environment
ENV COOL_DIR=/cool
ENV PATH="${COOL_DIR}/bin:${PATH}"

# Create symlink expected by COOL scripts
RUN mkdir -p /cool && \
    ln -s /cool /tmp/cool

# Work inside /cool by default
WORKDIR /cool

# Default command: open a shell
CMD ["/bin/bash"]
