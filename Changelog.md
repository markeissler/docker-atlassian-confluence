# 0.10.0 / 2017-06-20

Docker Swarm support! This version adds support for deployment to a cluster with a failover configuration. That is, only
one instance can be active at a time but the failover instance should startup without encountering errors stemming from
a corrupted _felix_ plugin cache.

Indexes have been moved out of the Docker host's persistence directory to improve performance in configurations that
enable data persistence over NFS volumes.

### Short list of commit messages

  * Update README for ephemeral storage and Swarm support.
  * Use ephemeral storage for caches
  * Update README for SSL support.

# 0.9.1 / 2017-06-18

Maintenance release.

## Short list of commit messages

  * Update README for v0.9.1. Fix app description.

# 0.9.0 / 2017-06-16

Initial release! A _dockerized_ [Atlassian Confluence](https://www.atlassian.com/software/confluence) install.

## Short list of commit messages

  * Update README for v0.9.0.
