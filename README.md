mission-imposm
==============

Quick setup of an imposm3 database

- Create your instance
  - I'm using `ami-a6926dce` and `c3.4xlarge` for now
- `sudo su && cd ~/`
- `apt-get install -y git make`
- `git clone https://github.com/osmlab/mission-imposm.git`
- `cd mission-imposm`
- `make install`
- download your pbf
- `./imposm3 import -connection postgis://postgres@localhost/osm -mapping mapping.json -read dc-baltimore.osm.pbf -write -deployproduction -appendcache`
