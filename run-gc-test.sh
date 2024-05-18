#!/bin/bash
testfile=$1
port=$2
if [ "$testfile" = "" ] ; then
    echo "Test file not found! Please run with './run-gc-test.sh test_file'"
    echo "For example,"
    echo "  $ ./run-gc-test.sh test/weak_list_gc_test.dart"
    exit 1
fi
echo "run $testfile";
dart run --enable-vm-service $testfile "$PWD/$testfile"
