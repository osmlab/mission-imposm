apt-get -y update
echo "- installing postgres + postgis"
apt-get install -y postgres-xc-client
apt-get install -y libpq-dev libgeos-c1 libgeos++-dev proj-bin mapnik-utils postgresql-9.3 postgresql-9.3-postgis-2.1 postgresql-contrib-9.3 unzip postgresql-client-9.3 postgresql-common postgresql-client-common postgresql-plpython-9.3
sudo apt-get install -y git vim htop bzip2 curl gdal-bin s3cmd

echo "- setting up postgres permissions + database"
chmod a+rx $HOME
sudo -u postgres createdb -U postgres -E UTF8 template_postgis
sudo -u postgres psql -U postgres -d postgres -c "UPDATE pg_database SET datistemplate='true' WHERE datname='template_postgis';"
sudo -u postgres psql -U postgres -d template_postgis -c "CREATE EXTENSION postgis;"
sudo -u postgres psql -U postgres -d template_postgis -c "GRANT ALL ON geometry_columns TO PUBLIC;"
sudo -u postgres psql -U postgres -d template_postgis -c "GRANT ALL ON geography_columns TO PUBLIC;"
sudo -u postgres psql -U postgres -d template_postgis -c "GRANT ALL ON spatial_ref_sys TO PUBLIC;"

sudo -u postgres createdb -U postgres -T template_postgis -E UTF8 osm

echo "- setting permissions"
sh -c 'echo "
local all postgres trust
local all all trust
host all all 127.0.0.1/32 trust
host all all ::1/128 trust
host replication postgres samenet trust
" > /etc/postgresql/9.3/main/pg_hba.conf'

echo "- restructing storage"
apt-get -y install lvm2
umount /dev/xvdb || echo "unmount /dev/xvdb no-op"
umount /dev/xvdc || echo "unmount /dev/xvdc no-op"

mkdir -p /mnt/data
pvcreate /dev/xvdb
pvcreate /dev/xvdc
vgcreate volgroup /dev/xvdb
vgextend volgroup /dev/xvdc
lvcreate -I64 -i2 -l +100%FREE volgroup -n lvoldata
mkfs.ext4 /dev/mapper/volgroup-lvoldata

mkdir -p /mnt/data/postgres
mount /dev/mapper/volgroup-lvoldata /mnt/data
mkdir /mnt/data/postgres
mv /var/lib/postgresql/9.3/main/ /mnt/data/postgres/
rm /var/lib/postgresql/9.3/main
cd /var/lib/postgresql/9.3
ln -s /mnt/data/postgres/main main

echo "- restarting postgres"
/etc/init.d/postgresql start

echo "- installing imposm3"
# this will have to change, I don't want to figure out building go applications right now
curl -O http://imposm.org/static/rel/imposm3-0.1dev-20140702-ced9f92-linux-x86-64.tar.gz
tar -zxvf imposm3-0.1dev-20140702-ced9f92-linux-x86-64.tar.gz
cd ~/mission-imposm/imposm3-0.1dev-20140702-ced9f92-linux-x86-64
# ./imposm3 is good to go
