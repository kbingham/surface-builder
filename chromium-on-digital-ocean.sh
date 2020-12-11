#!/bin/bash

set -e
set -x

IMAGE_SIZE=c-2
IMAGE_SIZE=s-1vcpu-1gb
IMAGE_SIZE=c-32
IMAGE_SIZE=g-40vcpu-160gb


# Slug                  Memory    VCPUs    Disk    Price Monthly    Price Hourly
# s-1vcpu-1gb           1024      1        25      5.00             0.007440
# c-2                   4096      2        25      40.00            0.059520
# c-4                   8192      4        50      80.00            0.119050
# s-8vcpu-16gb          16384     8        320     80.00            0.119050
# c-8                   16384     8        100     160.00           0.238100
# c-16                  32768     16       200     320.00           0.476190
# Below here for building in RAM
# c-32                  65536     32       400     640.00           0.952380
# g-40vcpu-160gb        163840    40       500     1200.00          1.785710
# gd-40vcpu-160gb       163840    40       1000    1300.00          1.934520


SSH_KEYS=23435368 #XXX CHANGE ME XXX CHANGE ME XXX CHANGE ME

ssh_cmd() {
    ssh -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $*
}

scp_cmd() {
    scp -q -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null $*
}


droplet_id=$(doctl compute droplet create builder2 --ssh-keys $SSH_KEYS --image ubuntu-20-04-x64 --region lon1 --size $IMAGE_SIZE --format ID --no-header --volumes 780589de-3bc4-11eb-9953-0a58ac14c15f )

echo "creating droplet $droplet_id"
echo "waiting until droplet $droplet_id is reachable"

cleanup() {
	echo "destroying droplet $droplet_id"
	doctl compute droplet delete $droplet_id --force
	doctl compute droplet list
}

trap cleanup EXIT

while :
do
    ipaddr_status=$(doctl compute droplet get ${droplet_id} --no-header --format PublicIPv4,Status)
    if [[ $ipaddr_status == *"active"* ]]; then
        echo "got ip_addr $(echo $ipaddr_status)"
        break
    fi
    sleep 5
done

ipaddr=$(echo $ipaddr_status | awk '{print $1}')
echo "droplet $droplet_id is active with ipaddr $ipaddr"
echo "Connect with root@${ipaddr}"

echo "waiting until droplet $droplet_id is reachable via ssh"
while :
do
    ssh_cmd root@${ipaddr} id >/dev/null && break
    sleep 1
done

echo "Preparing machine:"

ssh_cmd root@${ipaddr} 'apt update; apt upgrade -y; apt install sudo;'

# Use TMPFS users
ssh_cmd root@${ipaddr} 'mount tmpfs -t tmpfs /home/'
ssh_cmd root@${ipaddr} 'useradd -s /bin/bash -m user; echo "user  ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user;'
ssh_cmd root@${ipaddr} 'cp -rav .ssh /home/user/; chown -R /home/user/.ssh --reference /home/user;'

ssh_cmd root@${ipaddr} 'mount /dev/sda /home/user'

echo "Connect with user@${ipaddr}"

echo "The machine will self-destruct when you exit this shell..."
ssh_cmd user@${ipaddr} -tC "bash"

## Cleanup through exit trap
