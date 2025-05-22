#!/bin/bash
PID=`ps aux | grep '/root/executor/executor/bin/executor' | grep -v grep | awk '{print $2}' | wc -l`

echo $PID

#if[ $PID="" ]; then
if [ "$PID" = "0" ]; then
  echo "BRN没启动"
  /root/runBRN.sh
else
  echo "BRN启动着"
fi
