#!/bin/bash
# turn on set x to watch the script functioning

set -x

function setupenv {
# set up the basic environment for our three users, alice, bob, and root
mkdir /tmp/testdir
mkdir /tmp/testdir/alice_test_dir
mkdir /tmp/testdir/bob_test_dir
mkdir /tmp/testdir/root_test_dir
mkdir /tmp/testdir/alice_test_dir/alice_test_subdir
touch /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt
touch /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt
mkdir /tmp/testdir/bob_test_dir/bob_test_subdir
touch /tmp/testdir/bob_test_dir/ww_bob_test_dir.txt
touch /tmp/testdir/bob_test_dir/bob_test_subdir/ww_bob_test_subdir.txt
mkdir /tmp/testdir/root_test_dir/root_test_subdir
touch /tmp/testdir/root_test_dir/ww_root_test_dir.txt
touch /tmp/testdir/root_test_dir/root_test_subdir/ww_root_test_subdir.txt

# change the ownership respectively
chown -R alice:alice /tmp/testdir/alice_test_dir
chown -R bob:bob /tmp/testdir/bob_test_dir
}

# This will create a script to be called that will act on the world writable files.
function testscript {
echo "#!/bin/bash
set -x
for i in \`cat /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt\`
do
echo from ww_alice_test_dir
echo $i
done
for j in \`/tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt\`
do
echo from ww_alice_test_subdir
echo $j
done
" > testscript.sh
}

function cleanup {
rm -rf /tmp/testdir
}

# This runs through each directory to give a listing of how the permissions look at any given point in testing
function verify_all_perms {
ls -al /tmp/testdir
ls -al /tmp/testdir/*
ls -al /tmp/testdir/*/*
}

## declare an array variable for each of the users
declare -a userarr=("alice" "bob" "root")

cleanup
setupenv
testscript

# lets get a listing of all these permissions as they currently stand
# so as we iterate through changes we have a baseline

verify_all_perms

# ok, now to start monkeying with permissions
# lets first make sure alice can write to her file in her directory, root should be able to too, but not bob



## we will loop through the above user array
for i in "${userarr[@]}"
do
sudo su "$i" -c whoami
sudo su "$i" -c pwd
sudo su "$i" -c 'echo `whoami`_writing >> /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt'
   # or do whatever with individual element of the array
done

chmod o+w /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt

# lets go through the same run through, this time noting that we are writing a world writable

for i in "${userarr[@]}"
do
sudo su "$i" -c whoami
sudo su "$i" -c pwd
sudo su "$i" -c 'echo `whoami`_writing_to_ww >> /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt'
   # or do whatever with individual element of the array
done

# lets verify the contents again
cat  /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt

# now we will take away the execute bit from the directory.

chmod o-x /tmp/testdir/alice_test_dir/

# again, verifying who can write to the file, this time the file is ww but the directories execute bit is off

for i in "${userarr[@]}"
do
sudo su "$i" -c whoami
sudo su "$i" -c pwd
sudo su "$i" -c 'echo `whoami`_writing_to_ww_dirxoff >> /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt'
   # or do whatever with individual element of the array
done

cat  /tmp/testdir/alice_test_dir/ww_alice_test_dir.txt

# so the directorys execute bit prevents writing to a file, as expected

# similar testing for the subdir, lets change the permission back on the alice_test_dir
# lets cleanup first
cleanup
# and reset our environment
setupenv

# lets verify the recreation went as planned
verify_all_perms

# now we will test writing to a similar file in the subdir
for i in "${userarr[@]}"
do
sudo su "$i" -c whoami
sudo su "$i" -c pwd
sudo su "$i" -c 'echo `whoami`_writing_subdir >> /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt'
   # or do whatever with individual element of the array
done

# we will also make it world writable
chmod o+w /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt

for i in "${userarr[@]}"
do
sudo su "$i" -c whoami
sudo su "$i" -c pwd
sudo su "$i" -c 'echo `whoami`_writing_subdir_wwfile >> /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt'
   # or do whatever with individual element of the array
done


# now, however, we will try changing the parent directories execute bit to see if the permissions cascade down.
chmod o-x /tmp/testdir/alice_test_dir
ls -al  /tmp/testdir/alice_test_dir

# again, not seeing anything different
for i in "${userarr[@]}"
do
sudo su "$i" -c whoami
sudo su "$i" -c pwd
sudo su "$i" -c 'echo `whoami`_writing_subdir_wwfile_parentdirnox >> /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt'
   # or do whatever with individual element of the array
done

# until you cd into the subdir, where execute IS permitted
cd /tmp/testdir/alice_test_dir/alice_test_subdir
sudo su bob -c 'echo bob_writing_subdir_wwfile_parentdirnox >> ww_alice_test_subdir.txt'
cat /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt

# This time we will write to /tmp/testdir/alice_test_dir/alice_test_subdir/ww_alice_test_subdir.txt as bob
# illustrating that a parent directories lack of execute does not roll down to child directories
#
