# Troubleshoot Cloud to Server Migrations

## Sysadmin user is missing

When you restore a Confluence Cloud site backup to a standalone (self-hosted) server a sysadmin account should become
available for subsequent login and setup. Most importantly, you will need to login and setup an email server so existing
users can recover their passwords (credentials for all accounts other than the sysadmin account will have been disabled
following a restore).

Once the system has restarted, following a restore, you should be able to login with the following credentials:

| Account  | Password |
|:-------- |:---------|
| sysadmin | sysadmin |

If you find you can't login then you will need to make manual corrections at the database.

> The instructions in this guide assume Postgres is the underlying database.

<a name="step-1"></a>

## Step 1: Check for users with administrative access

Verify that no users exist with administrative access:

```sql
psql=> select u.id, u.user_name, u.active from cwd_user u
    join cwd_membership m on u.id=m.child_user_id
    join cwd_group g on m.parent_id=g.id
    join cwd_directory d on d.id=g.directory_id
    where g.group_name = 'confluence-administrators' and d.directory_name='Confluence Internal Directory';

 id | user_name | active
----+-----------+--------
(0 rows)
```

If the query returns 0 rows, as it does above, proceed to [Step 2](#step-2). Otherwise, skip to [Step 3](#step-3).

<a name="step-2"></a>

## Step 2: Add a sysadmin account if needed

```sql
psql=> insert into cwd_user(id, user_name, lower_user_name, active, created_date, updated_date, first_name, lower_first_name, last_name, lower_last_name, display_name, lower_display_name, email_address, lower_email_address, directory_id, credential)
    values (1212121, 'sysadmin', 'sysadmin', 'T', '2009-11-26 17:42:08', '2009-11-26 17:42:08', 'System', 'system', 'Administrator', 'administrator', 'System Administrator', 'system administrator', 'sysadmin@localhost', 'sysadmin@localhost',
        (select id from cwd_directory where directory_name='Confluence Internal Directory'),
        '{PKCS5S2}R+BJAdk3nuzFdPM7xgH9f6dp1SvPCTa57Z4LZvMj4kKcpcBvOBoBsW5rMs/xoydN'
    );
```

Proceed to [Step 3](#step-3).

<a name="step-3"></a>

## Step 3: Add a user_mapping for sysadmin

Check if a user_mapping already exists for `sysadmin`:

```sql
pslq=> select * from user_mapping where username='sysadmin';
             user_key             | username | lower_username
----------------------------------+----------+----------------
 ff80808146bc07250146bc09a2ab0003 | sysadmin | sysadmin
(1 row)
```

If the record exists, as it does above, continue to [Step 4](#step-4). Otherwise,
add the record as follows:

```sql
psql=> insert into user_mapping values ('2c9681954172cf560000000000000001', 'sysadmin', 'sysadmin');
```

Proceed to [Step 4](#step-4).

<a name="step-4"></a>

## Step 4: Add a confluence-administrators group if needed

Check if we need to add the __confluence-administrators__ group:

```sql
psql=> select id from cwd_group where lower_group_name='confluence-administrators';
   id
--------
 196610
(1 row)
```

If the record exists, as it does above, continue to [Step 5](#step-5). Otherwise,
add the record as follows:

```sql
psql=> insert into cwd_group(id, group_name, lower_group_name, active, local, created_date, updated_date, description, group_type, directory_id)
    values ('888888','confluence-administrators','confluence-administrators','T','F','2011-03-21 12:20:29','2011-03-21 12:20:29',NULL,'GROUP',
        (select id from cwd_directory where directory_name='Confluence Internal Directory')
    );
```

Proceed to [Step 5](#step-5).

<a name="step-5"></a>

## Step 5: Add a confluence-users group if needed

Check if we need to add the __confluence-users__ group:

```sql
psql=> select id from cwd_group where lower_group_name='confluence-users' and directory_id='1';
   id
--------
 196622
(1 row)
```

If the record exists, as it does above, continue to [Step 6](#step-6). Otherwise,
add the record as follows:

```sql
psql=> insert into cwd_group(id, group_name, lower_group_name, active, local, created_date, updated_date, description, group_type, directory_id)
    values ('999999','confluence-users','confluence-users','T','F','2011-03-21 12:20:29','2011-03-21 12:20:29',NULL,'GROUP',
        (select id from cwd_directory where directory_name='Confluence Internal Directory')
    );
```

Proceed to [Step 6](#step-6).

<a name="step-6"></a>

## Step 6: Add the sysadmin account to the confluence-users group

Check if we need to add the __sysadmin__ account to the __confluence-users__ group:

```sql
psql=> select * from cwd_membership
    where parent_id=(select id from cwd_group where lower_group_name='confluence-users')
    and child_user_id=(select id from cwd_user where lower_user_name='sysadmin');
 id | parent_id | child_group_id | child_user_id
----+-----------+----------------+---------------
(0 rows)
```

If the record exists, continue to [Step 7](#step-7). Otherwise, add the record as follows:

```sql
psql=> insert into cwd_membership (id, parent_id, child_user_id)
    values (888888,
        (select id from cwd_group where group_name='confluence-users' and directory_id=
            (select id from cwd_directory where directory_name='Confluence Internal Directory')
        ), 1212121
    );
```

## Step 7: Add the sysadmin account to the confluence-administrators group:

Check if we need to add the __sysadmin__ account to the __confluence-administrators__ group:

```sql
psql=> select * from cwd_membership
    where parent_id=(select id from cwd_group where lower_group_name='confluence-administrators')
    and child_user_id=(select id from cwd_user where lower_user_name='sysadmin');
 id | parent_id | child_group_id | child_user_id
----+-----------+----------------+---------------
(0 rows)
```

If the record exists, continue to [Step 8](#step-8). Otherwise, add the record as follows:

```sql
# delete from cwd_membership where id=999999;
psql=> insert into cwd_membership (id, parent_id, child_user_id)
    values (999999,
        (select id from cwd_group where group_name='confluence-administrators' and directory_id=
            (select id from cwd_directory where directory_name='Confluence Internal Directory')
        ), 1212121
    );
```

<a name="step-8"></a>

## Step 8: Restart Confluence

After making changes as described above you will need to restart the Confluence container.
