#!/bin/sh
cd impl/file
./build.sh
mv *.rock ../../target
cd ../udp
./build.sh
mv *.rock ../../target