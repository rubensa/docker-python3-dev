FROM python:3
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# extra dependencies (over what python already includes)
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    && rm -rf /var/lib/apt/lists/*

ARG USER=python3
ARG GROUP=python

# creates group $GROUP with GID 1000
# creates user $USER with UID 1000, home directory /home/$USER, and shell /bin/sh
RUN addgroup --gid 1000 $GROUP && \
    adduser --uid 1000 --ingroup $GROUP --home /home/$USER --shell /bin/sh --disabled-password --gecos "Docker image user" $USER && \
    echo "$USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USER && \
    chmod 0440 /etc/sudoers.d/$USER

# add fixuid
RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: $USER\ngroup: $GROUP\n" > /etc/fixuid/config.yml

# tell docker that all future commands should run as the user
USER $USER:$GROUP

# set up the user working directory as his home directory
WORKDIR /home/$USER

# run fixuid
ENTRYPOINT ["fixuid"]

# run python by default
CMD python

