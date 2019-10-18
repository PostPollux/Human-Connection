FROM gitpod/workspace-full


ARG NEO4J_VERSION=3.5.12
ARG APOC_VERSION=3.5.0.4-all

ENV NEO4J_USERNAME=neo4j \
    NEO4J_PASSWORD=letmein


# change user to root so we don't have to use sudo for all commands
USER root

# Add Neo4j Debian repository to list of sources
RUN wget -O - https://debian.neo4j.org/neotechnology.gpg.key | apt-key add - \
    && echo 'deb https://debian.neo4j.org/repo stable/' | tee /etc/apt/sources.list.d/neo4j.list \
    && apt-get update

# Install Neo4J, download apoc plugin to the plugins directory, set initial password for the default "neo4j" user and change the data directory to "/workspace/neo4j-data" so it persits when shutting down the workspace.
RUN apt-get install -yq --no-install-recommends neo4j=1:$NEO4J_VERSION \
    && wget https://github.com/neo4j-contrib/neo4j-apoc-procedures/releases/download/3.5.0.4/apoc-$APOC_VERSION.jar -P /var/lib/neo4j/plugins/ \
    && /bin/neo4j-admin set-initial-password $NEO4J_PASSWORD \
    && mkdir -p /workspace/neo4j-data \
    && sed -i 's/dbms.directories.data=.*/dbms.directories.data=\/workspace\/neo4j-data/g' /etc/neo4j/neo4j.conf

# Allow Apoc procedures
RUN echo "dbms.security.procedures.unrestricted=apoc.*" >> /etc/neo4j/neo4j.conf

# make sure that neo4j can be started by the gitpod user
RUN chown -R gitpod:gitpod /var/run/neo4j /etc/neo4j /var/log/neo4j /var/lib/neo4j /bin/cypher-shell /bin/neo4j-admin /workspace/neo4j-data

# change user back to gitpod
USER gitpod