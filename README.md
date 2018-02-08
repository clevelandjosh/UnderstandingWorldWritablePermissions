# UnderstandingWorldWritablePermissions

# This project will walk through some (hopefully) interesting concepts around world writable files. 

I will probably break this up into sub projects so each can shine the light on an individual idea. 

## An example for the parent directory and subdirectory execute bits impact

In this example we will have three users, each with their own directory and subdirectory, as well as a file in each. 

The users are root, alice, and bob.

```
[root@ip-172-31-33-3 testdir]# 
useradd alice
useradd bob
```
root already exists on the system ;)

We will create the directories first, then the files, we will then assign the newly created directories and files to their respective owners. 

```
[root@ip-172-31-33-3 tmp]# mkdir /tmp/testdir
[root@ip-172-31-33-3 tmp]# mkdir /tmp/testdir/alice_test_dir
[root@ip-172-31-33-3 tmp]# mkdir /tmp/testdir/bob_test_dir
[root@ip-172-31-33-3 tmp]# mkdir /tmp/testdir/root_test_dir
[root@ip-172-31-33-3 tmp]# mkdir /tmp/testdir/alice_test_dir/alice_test_subdir
[root@ip-172-31-33-3 tmp]# touch /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt
[root@ip-172-31-33-3 tmp]# touch /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt
[root@ip-172-31-33-3 tmp]# mkdir /tmp/testdir/bob_test_dir/bob_test_subdir
[root@ip-172-31-33-3 tmp]# touch /tmp/testdir/bob_test_dir/ww_bob_test_dir.txt
[root@ip-172-31-33-3 tmp]# touch /tmp/testdir/bob_test_dir/bob_test_subdir/ww_bob_test_subdir.txt
[root@ip-172-31-33-3 tmp]# mkdir /tmp/testdir/root_test_dir/root_test_subdir
[root@ip-172-31-33-3 tmp]# touch /tmp/testdir/root_test_dir/ww_root_test_dir.txt
[root@ip-172-31-33-3 tmp]# touch /tmp/testdir/root_test_dir/root_test_subdir/ww_root_test_subdir.txt
```

Then assign the directories to their owners.


```
[root@ip-172-31-33-3 tmp]# chown -r alice:alice /tmp/testdir/alice_test_dir
[root@ip-172-31-33-3 tmp]# chown -r bob:bob /tmp/testdir/bob_test_dir
```

Make a script that will run the content of each of the files in alice's directory. This would be analagous to a service or job from cron.d, though simplier.

vi testscript.sh

```
echo "#!/bin/bash

set -x
for i in `cat /tmp/testdir/alice_test_dir/test_ww_file.txt`
do
echo $i
done
       " > testscript.sh
```

