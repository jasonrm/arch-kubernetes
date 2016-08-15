#!/bin/bash

# Boilerplate for loading variables
# > Source: http://stackoverflow.com/a/246128/31341
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
# > Source: http://stackoverflow.com/a/1423444/31341
for f in $DIR/conf.d/*; do source $f; done

REMOTE_DIR=$1
REMOTE_SCRIPT=$2
TO_EXEC=$(mktemp)
echo $TO_EXEC

cat > $TO_EXEC <<DELIM
#!/bin/bash
REMOTE=1
DELIM

for f in $DIR/conf.d/*; do
    cat $f >> $TO_EXEC
done

cat remote.d/$REMOTE_DIR/${REMOTE_SCRIPT}.sh >> $TO_EXEC

for _HOSTNAME in ${CLUSTER_NODE_HOSTNAMES[@]}; do
    echo ${_HOSTNAME}
    ssh root@${_HOSTNAME} "bash -s" -- < $TO_EXEC
done

rm $TO_EXEC
