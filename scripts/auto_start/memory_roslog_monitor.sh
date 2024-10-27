#!/bin/bash
source /opt/ros/noetic/setup.bash
export ROS_PACKAGE_PATH=~/rm_ws:$ROS_PACKAGE_PATH

log_dir=~/.ros/log

if [[ -d "$log_dir" ]]; then
  old_dirs=$(find "$log_dir" -type d -mtime +7)
  old_files=$(find "$log_dir" -type f -mtime +7)

  for dir in $old_dirs; do
    rm -rf "$dir"
  done
  for file in $old_files; do
    rm -f "$file"
  done
fi