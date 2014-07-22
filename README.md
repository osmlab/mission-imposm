mission-imposm
==============

Quick setup of an imposm3 database

- Create your instance
  - I'm using `ami-a6926dce` and `c3.4xlarge` for now
- `sudo apt-get install -y git`
- `git clone https://github.com/osmlab/mission-imposm.git`
- `cd mission-imposm`
- `sudo make install`
- download your pbf
- `./imposm3 import -connection postgis://postgres@localhost/osm -mapping mapping.json -read {your pbf} -write`
