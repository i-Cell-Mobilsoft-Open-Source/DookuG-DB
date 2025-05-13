# comes from docker-compose
ARG LIQUIBASE_BASE_IMAGE
ARG PG_TOOLS_IMAGE

################################################################################
# Default image customization
################################################################################
FROM ${LIQUIBASE_BASE_IMAGE} as base
FROM ${PG_TOOLS_IMAGE} AS partman

# Any spec. modification can be executed here... 

################################################################################
# Create production image
################################################################################
FROM base as prod

ARG LIQUIBASE_INSTALL_DIR
ARG LIQUIBASE_INSTALL_COMMON_DIR

COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP $LIQUIBASE_INSTALL_DIR $DOCKER_LIQUIBASE_CHANGELOG
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP $LIQUIBASE_INSTALL_COMMON_DIR $DOCKER_LIQUIBASE_CHANGELOG/common
COPY --from=partman --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP $HOME/ $DOCKER_LIQUIBASE_CHANGELOG/partman/

COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP /etc/release/liquibase.docker.properties $LIQUIBASE_HOME/liquibase.docker.properties

COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP /etc/release/before-liquibase.sh $LIQUIBASE_HOME/bash/before-liquibase.sh
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP /etc/release/postgresql $LIQUIBASE_HOME/postgresql
COPY --chown=$SYSTEM_USER:$SYSTEM_USER_GROUP /etc/release/oracle $LIQUIBASE_HOME/oracle