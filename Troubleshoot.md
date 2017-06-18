# Troubleshoot Cloud to Server Migrations

## Sysadmin user is missing

When you generate a backup of your Confluence data in the Cloud, the system is
supposed to create a sysadmin user (password 'sysadmin'). The idea is that you
would login with those credentials after a restore to your Server, and then make
other necessary changes: change the sysadmin password, enable mail services so
that existing users can reset passwords, etc.

Once the restore process completes successfully you will be required to login.
The only account that will work is the sysadmin account:

| Account  | Password |
|:-------- |:---------|
| sysadmin | sysadmin |

If the sysadmin user is missing, you won't be able to login. So the first thing
to check is if the account exists.

Check if you have any users with administrative access:

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

If so, then we'll have to skip the "user_mapping" step below..

Add a sysadmin account if needed:

```sql
# succeeds
psql=> insert into cwd_user(id, user_name, lower_user_name, active, created_date, updated_date, first_name, lower_first_name, last_name, lower_last_name, display_name, lower_display_name, email_address, lower_email_address, directory_id, credential)
    values (1212121, 'sysadmin', 'sysadmin', 'T', '2009-11-26 17:42:08', '2009-11-26 17:42:08', 'System', 'system', 'Administrator', 'administrator', 'System Administrator', 'system administrator', 'sysadmin@localhost', 'sysadmin@localhost',
        (select id from cwd_directory where directory_name='Confluence Internal Directory'),
        '{PKCS5S2}R+BJAdk3nuzFdPM7xgH9f6dp1SvPCTa57Z4LZvMj4kKcpcBvOBoBsW5rMs/xoydN'
    );
```

Check if a user_mapping already exists for `sysadmin`:

```sql
pslq=> select * from user_mapping where username='sysadmin';
             user_key             | username | lower_username
----------------------------------+----------+----------------
 ff80808146bc07250146bc09a2ab0003 | sysadmin | sysadmin
(1 row)
```

In the above case, the record exists. If the query returns 0 rows, then run the following:

```sql
# fails: duplicate key value violates unique constraint "unq_lwr_username"
# fails: Key (lower_username)=(sysadmin) already exists
psql=> insert into user_mapping values ('2c9681954172cf560000000000000001', 'sysadmin', 'sysadmin');
```

Add new groups:

```sql
# delete from cwd_group where lower_group_name='confluence-administrators';
#
# fails: duplicate key value violates unique constraint "cwd_group_name_dir_id"
# fails: Key (lower_group_name, directory_id)=(confluence-administrators, 1) already exists
psql=> insert into cwd_group(id, group_name, lower_group_name, active, local, created_date, updated_date, description, group_type, directory_id)
    values ('888888','confluence-administrators','confluence-administrators','T','F','2011-03-21 12:20:29','2011-03-21 12:20:29',NULL,'GROUP',
        (select id from cwd_directory where directory_name='Confluence Internal Directory')
    );

# delete from cwd_group where lower_group_name='confluence-users';
#
# fails: duplicate key value violates unique constraint "cwd_group_name_dir_id"
# fails: Key (lower_group_name, directory_id)=(confluence-users, 1) already exists
psql=> insert into cwd_group(id, group_name, lower_group_name, active, local, created_date, updated_date, description, group_type, directory_id)
    values ('999999','confluence-users','confluence-users','T','F','2011-03-21 12:20:29','2011-03-21 12:20:29',NULL,'GROUP',
        (select id from cwd_directory where directory_name='Confluence Internal Directory')
    );
```

NOTE: If you get the error above, you need to find the id of the existing record and then use that id in the SQL
statement below where `cwd_membership = 999999`.

Find the existing record:

```sql
psql=> select id from cwd_group where lower_group_name='confluence-users' and directory_id='1';
   id
--------
 196622
(1 row)
```

Add group memberships into cwd_membership:

```sql
# delete from cwd_membership where id=888888;
psql=> insert into cwd_membership (id, parent_id, child_user_id)
    values (888888,
        (select id from cwd_group where group_name='confluence-users' and directory_id=
            (select id from cwd_directory where directory_name='Confluence Internal Directory')
        ), 1212121
    );

# delete from cwd_membership where id=999999;
psql=> insert into cwd_membership (id, parent_id, child_user_id)
    values (999999,
        (select id from cwd_group where group_name='confluence-administrators' and directory_id=
            (select id from cwd_directory where directory_name='Confluence Internal Directory')
        ), 1212121
    );
```

Alternatively...

```sql
psql=> insert into cwd_membership (id, parent_id, child_user_id)
    values (196622,
        (select id from cwd_group where group_name='confluence-administrators' and directory_id=
            (select id from cwd_directory where directory_name='Confluence Internal Directory')
        ), 1212121
    );
```
