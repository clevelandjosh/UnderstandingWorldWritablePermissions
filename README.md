# UnderstandingWorldWritablePermissions

## An example

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
[root@ip-172-31-33-3 tmp]# mkdir testdir
[root@ip-172-31-33-3 tmp]# mkdir testdir/alice_test_dir
[root@ip-172-31-33-3 tmp]# mkdir testdir/bob_test_dir
[root@ip-172-31-33-3 tmp]# mkdir testdir/root_test_dir
[root@ip-172-31-33-3 tmp]# mkdir testdir/alice_test_dir/alice_test_subdir
[root@ip-172-31-33-3 tmp]# mkdir testdir/bob_test_dir/bob_test_subdir
[root@ip-172-31-33-3 tmp]# mkdir testdir/root_test_dir/root_test_subdir

```
