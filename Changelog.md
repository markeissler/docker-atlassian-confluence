# Changelog: docker-atlassian-confluence

## 1.11.0 / 2018-01-28

Update Confluence to 6.5.0.

### Minor version increment!

Since this is a Minor version increment be sure to review the release notes and upgrade notes:

  * [Confluence 6.5 upgrade notes] (https://confluence.atlassian.com/doc/confluence-6-5-upgrade-notes-938862633.html)
  * [Confluence 6.5 release notes] (https://confluence.atlassian.com/doc/confluence-6-5-release-notes-938862614.html)
  * [Confluence 6.5.0 issues resolved] (https://confluence.atlassian.com/doc/issues-resolved-in-6-5-0-939699975.html)

## 1.10.0 / 2017-11-05

Update Confluence to 6.4.3.

## 1.9.0 / 2017-11-05

Update Confluence to 6.4.2.

## 1.8.0 / 2017-11-05

Update Confluence to 6.4.1.

## 1.7.0 / 2017-09-14

Update Confluence to 6.4.0.

### Minor version increment!

Since this is a Minor version increment be sure to review the release notes and upgrade notes:

  * [Confluence 6.4 upgrade notes] (https://confluence.atlassian.com/doc/confluence-6-4-upgrade-notes-934721251.html)
  * [Confluence 6.4 release notes] (https://confluence.atlassian.com/doc/confluence-6-4-release-notes-934721238.html)
  * [Confluence 6.4.0 issues resolved] (https://confluence.atlassian.com/doc/issues-resolved-in-6-4-0-937165586.html)

> NOTE: Breaking tradition with Atlassian Minor version updates, this time the team did not skip the `.0` release.

## 1.6.0 / 2017-09-14

Update Confluence to 6.3.4.

## 1.5.0 / 2017-09-13

Update Confluence to 6.3.3.

## 1.4.0 / 2017-09-13

Update Confluence to 6.3.2.

## 1.3.0 / 2017-07-30

Update Confluence to 6.3.1.

### Minor version increment!

Since this is a Minor version increment be sure to review the release notes and upgrade notes:

  * [Confluence 6.3 upgrade notes] (https://confluence.atlassian.com/doc/confluence-6-3-upgrade-notes-909642703.html)
  * [Confluence 6.3 release notes] (https://confluence.atlassian.com/doc/confluence-6-3-release-notes-909642701.html)
  * [Confluence 6.3.1 issues resolved] (https://confluence.atlassian.com/doc/issues-resolved-in-6-3-1-931235734.html)

> NOTE: As is common with Atlassian Minor version updates, there is no 6.3.0 release.

### MySQL driver updated to 5.1.42

The included **MySQL** driver has been updated to `5.1.42` in conjunction with included support in this release:

[Updated database drivers](https://confluence.atlassian.com/doc/confluence-6-3-upgrade-notes-909642703.html#Confluence6.3UpgradeNotes-Updateddatabasedrivers)

Atlassian bundles the **Postgres** driver with each release. This release includes version `42.1.1` of the **Postgres** driver.

### Short list of commit messages

  * Update mysql driver to 5.1.42.
  * Update Confluence to 6.3.1.

## 1.2.0 / 2017-07-28

Update Confluence to 6.2.4.

### Short list of commit messages.

  * Update Confluence to 6.2.4.

## 1.1.0 / 2017-06-24

Update Confluence to 6.2.3.

### Short list of commit messages

  * Update README to include link to upstream release notes.
  * Update Confluence to 6.2.3.

## 1.0.0 / 2017-06-24

Update Confluence to 6.2.2.

### Short list of commit messages

  * Update README for redeployment indexing issues.
  * Update Confluence to 6.2.2.

## 0.10.0 / 2017-06-20

Docker Swarm support! This version adds support for deployment to a cluster with a failover configuration. That is, only
one instance can be active at a time but the failover instance should startup without encountering errors stemming from
a corrupted _felix_ plugin cache.

Indexes have been moved out of the Docker host's persistence directory to improve performance in configurations that
enable data persistence over NFS volumes.

### Short list of commit messages

  * Update README for ephemeral storage and Swarm support.
  * Use ephemeral storage for caches
  * Update README for SSL support.

## 0.9.1 / 2017-06-18

Maintenance release.

### Short list of commit messages

  * Update README for v0.9.1. Fix app description.

## 0.9.0 / 2017-06-16

Initial release! A _dockerized_ [Atlassian Confluence](https://www.atlassian.com/software/confluence) install.

### Short list of commit messages

  * Update README for v0.9.0.
