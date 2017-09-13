#!/bin/bash -v

# This script runs on instances with a node_type tag of "hadoop-edge"
# The base.sh script does not run on this instance type
# It mounts the disks and installs a salt master

# The pnda_env-<cluster_name>.sh script generated by the CLI should
# be run prior to running this script to define various environment
# variables
set -ex

echo $PNDA_CLUSTER-hadoop-edge > /etc/hostname
hostname $PNDA_CLUSTER-hadoop-edge

service salt-master restart

# The hadoop:role grain is used by the cm_setup.py (in platform-salt) script to
# place specific hadoop roles on this instance.
# The mapping of hadoop roles to hadoop:role grains is
# defined in the cfg_<flavor>.py.tpl files (in platform-salt)
cat >> /etc/salt/grains <<EOF
hadoop:
  role: EDGE
roles:
  - hadoop_edge
  - console_frontend
  - console_backend_data_logger
  - console_backend_data_manager
  - graphite
  - gobblin
  - deployment_manager
  - package_repository
  - data_service
  - hadoop_manager
  - platform_testing_cdh
  - mysql_connector
  - jupyter
  - elk
  - logserver
  - kibana_dashboard
  - impala-shell
  - yarn-gateway
  - hbase_opentsdb_tables
  - hdfs_cleaner
  - master_dataset
  - pnda_restart
EOF

cat >> /etc/salt/minion <<EOF
id: $PNDA_CLUSTER-hadoop-edge
EOF

cat >> /etc/salt/minion.d/beacons.conf <<EOF
  service_restart:
    interval: $PLATFORM_SALT_BEACON_TIMEOUT
    disable_during_state_run: True
EOF

service salt-minion restart
