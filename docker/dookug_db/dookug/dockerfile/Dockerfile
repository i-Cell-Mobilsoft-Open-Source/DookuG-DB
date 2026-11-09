ARG LIQUIBASE_INSTALL_DIR
ARG LIQUIBASE_INSTALL_COMMON_DIR
ARG DOCKER_RUNTIME_LIQUIBASE
FROM ${DOCKER_RUNTIME_LIQUIBASE}
ARG DOCKER_RUNTIME_LIQUIBASE


LABEL hu.icellmobilsoft.description="Hardened liquibase base image to apply service specific changelogs."
LABEL hu.icellmobilsoft.base.image="DOCKER_RUNTIME_LIQUIBASE=${DOCKER_RUNTIME_LIQUIBASE}"

ARG LIQUIBASE_INSTALL_DIR
ARG LIQUIBASE_INSTALL_COMMON_DIR

################################################################################
# Copy files
# APP_USER / APP_USER_GROUP / LIQUIBASE_HOME are inherited from the base image.
################################################################################
COPY --chown=${APP_USER}:${APP_USER_GROUP} $LIQUIBASE_INSTALL_DIR $LIQUIBASE_HOME/changelog
COPY --chown=${APP_USER}:${APP_USER_GROUP} $LIQUIBASE_INSTALL_COMMON_DIR $LIQUIBASE_HOME/common


################################################################################
# Finalize the image
################################################################################

CMD ["--changelog-file=changelog/dookug-master.xml", "update"]