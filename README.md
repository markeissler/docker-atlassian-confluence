# Atlassian Confluence for Docker

__docker-atlassian-confluence__ provides [Atlassian Confluence](https://www.atlassian.com/software/confluence) in a [docker](https://www.docker.com/)
container to support team collaboration.

## Related Projects

You may also be interested in the following projects:

  * [Dockerized Atlassian Crowd](https://github.com/markeissler/docker-atlassian-crowd) - centralized identity management
  * [Dockerized Atlassian JIRA](https://github.com/markeissler/docker-atlassian-jira) - project tracking for software teams


## Overview

This revision of __docker-atlassian-confluence__ will install:

[Confluence 6.5.0](https://confluence.atlassian.com/doc/issues-resolved-in-6-5-0-939699975.html)

## Installation

This application is ready to launch on a Docker host:

```sh
prompt> docker run -d -p 8080:8080 -p 8443:8443 markeissler/atlassian-confluence:latest
```

## Usage

<a name="data-persistence"></a>

### Data Persistence

As configured, data on the following volumes will be created to persist data between container starts:

| Volume | Purpose                                                    |
|:-------|:-----------------------------------------------------------|
| /var/atlassian/confluence               | application configuration |
| /opt/atlassian/confluence/logs          | runtime logs              |

<a name="data-persistence-nfs"></a>

### Data Persistence over NFS

It may be desirable to configure data persistence over NFS, in which case NFS volumes are mounted at the locations
described in the [Data Persistence](#data-persistence) section above. NFS support requires that the underlying Docker
host supports NFS; if deploying to a [Docker swarm](https://docs.docker.com/engine/swarm/) a potential __boot2docker.iso__
candidate that supports NFS is the [boot2docker-nfs.iso](https://github.com/markeissler/boot2docker-nfs).

Certain JIRA directories are moved out of the application configuration directory and into an ephemeral runtime storage
area to prevent data corruption startup failures. Specfically, cache directories are moved so that clean re-starts
are possible; often, when an instance dies Tomcat will not be shutdown cleanly and data corruption is likely to occur
with regard to the _felix_ plugin cache).

| Directory | Purpose                                                        |
|:----------|:---------------------------------------------------------------|
| /var/atlassian/confluence_runtime | runtime storage for caches and indexes |

### SSL Support

You can enable SSL by simply copying a PKCS12 format certificate (`certificate.p12`) into the `CONF_HOME` directory
(`/var/atlassian/confluence`) and then restarting the container. The PKCS12 file format has been selected to make it
easier to generate certificates using `openssl`.

An example `openssl` command that will create a PKCS12 file from a private key (`server_key.pem`) and public certficate
(`server_cert.pem`) follows:

```sh
prompt> openssl pkcs12 -export -in server_cert.pem \
    -inkey server_key.pem -out certificate.p12 \
    -passout pass:changeit -name "confluence"
```

On container startup, the PCKS12 format certificate.p12 file will be converted and stored in the system JKS keystore.

## Docker Swarm Support

While __docker-atlassian-confluence__ does not support multi-node clustering it does support deployment to a cluster
with a failover configuration (where only a single Confluence instance is active at any time).

This configuration requires that [Data Persistence over NFS](#data-persistence-nfs) has been configured to share
Confluence configuration information among replicated instances.

## Redeployment Index Regeneration

Indexes are stored in ephemeral storage; consequently, when redeploying the application on top of existing persistent
storage (i.e. [Data Persistence over NFS](#data-persistence-nfs)) it will be necessary to manually trigger a rebuild of
all indexes. Log in as a user with administrative permissions, then navigate to:

`Cog > General Configuration > Administration > Content Indexing`

Click on the <kbd>rebuild</kbd> button.

## Troubleshooting

For general troubleshooting information check the [Troubleshoot](troubleshoot.md) document.

## Upstream Release Notes

Release notes for all versions of Confluence can be viewed online:

[Confluence Release Notes](https://confluence.atlassian.com/doc/confluence-release-notes-327.html)

## Authors

__docker-atlassian-confluence__ is the work of __Mark Eissler__.

## Attributions

__docker-atlassian-confluence__ was inspired by the work of [Martin Aksel Jensen](https://github.com/cptactionhank),
specifically his ongoing efforts to provide up-to-date _dockerized_ versions of other popular [Atlassian](https://www.atlassian.com/)
applications.

## License

__docker-atlassian-confluence__ is licensed under the MIT open source license.

---
Without open source, there would be no Internet as we know it today.
