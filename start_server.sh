#!/bin/bash

# Set variables here
SERVER="purpur"
VERSION="1.20.4"
BUILD="latest"  # Only needed for Paper
NGROK_TOKEN="2R1U09GSE8wufj3OyCmyJWnMQjd_76yT61aRhpnYbB87cnH2j"

set -e
root=$PWD
mkdir -p server
cd server

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
CYAN="\033[0;36m"
NC="\033[0m"

display_title() {
    clear
    echo -e "${GREEN}====================================================================="
    echo ""
    echo -e "                        MCServerTemplate v0.2.0                     "
    echo ""
    echo -e "=====================================================================${NC}"
    echo ""
}

download() {
    display_title
    echo "By executing this script you agree to all the licenses of the packages"
    echo "used in this project."
    echo ""
    echo ""
    echo "Thank you for agreeing, the download will now begin."
    echo ""

    case "${SERVER,,}" in
    purpur)
        echo -e "${BLUE}Downloading Purpur...${NC}"
        echo ""
        wget -O server.jar "https://api.purpurmc.org/v2/purpur/$VERSION/latest/download"
        ;;
    paper)
        echo -e "${BLUE}Downloading Paper...${NC}"
        echo ""
        wget -O server.jar "https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds/$BUILD/downloads/paper-$VERSION-$BUILD.jar"
        ;;
    magma)
        echo -e "${BLUE}Downloading Magma...${NC}"
        echo ""
        wget -O server.jar "https://magma.c0d3m4513r.com/mirror/$VERSION/latest_server.jar"
        ;;
    esac

    serverName="$(echo "$SERVER" | awk '{print toupper(substr($0,1,1)) tolower(substr($0,2))}')"
    echo -e "${GREEN}${serverName} has been successfully downloaded.${NC}"
    echo "eula=true" >eula.txt
    echo ""
    echo -e "${BLUE}Downloading ngrok...${NC}"
    echo ""
    wget -O ngrok.zip "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip"
    unzip -o ngrok.zip >/dev/null 2>&1
    rm -f ngrok.zip >/dev/null 2>&1
    echo -e "${GREEN}ngrok has been successfully downloaded."
    echo ""
    echo -e "Downloads completed.${NC}"
    echo ""
}

require() {
    if [ ! $1 $2 ]; then
        download
    fi
}

requireFile() {
    require -f $1 "File $1 required but not found"
}

requireExec() {
    requireFile "$1"
    chmod +x "$1"
}

while true; do
    display_title
    requireFile "eula.txt"
    requireFile "server.jar"
    requireExec "ngrok"
    mkdir -p ./logs
    touch ./logs/temp
    rm ./logs/*
    if ! pgrep -x "ngrok" >/dev/null; then
        echo -e "${GREEN}Starting ngrok tunnel...${NC}"
        ./ngrok authtoken $NGROK_TOKEN >/dev/null 2>&1
        ./ngrok tcp --log=stdout 25565 >$root/status.log &
    fi
    echo ""
    echo -e "${CYAN}Minecraft server starting, please wait...${NC}"
    echo ""
    echo -e "${GREEN}=====================================================================${NC}"
    echo ""
    COMMON_JVM_FLAGS="-Xms128M -Xmx512M -XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+UnlockDiagnosticVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -XX:+UseStringDeduplication -XX:+UseAES -XX:+UseAESIntrinsics -XX:UseSSE=4 -XX:AllocatePrefetchStyle=1 -XX:+UseLoopPredicate -XX:+RangeCheckElimination -XX:+EliminateLocks -XX:+DoEscapeAnalysis -XX:+UseCodeCacheFlushing -XX:+OptimizeStringConcat -XX:+UseCompressedOops -XX:+UseThreadPriorities -XX:+TrustFinalNonStaticFields -XX:+UseInlineCaches -XX:+RewriteBytecodes -XX:+RewriteFrequentPairs -XX:+UseNUMA -XX:-DontCompileHugeMethods -XX:+UseFPUForSpilling -XX:+UseNewLongLShift -XX:+UseXMMForArrayCopy -XX:+UseXmmI2D -XX:+UseXmmI2F -XX:+UseXmmLoadAndClearUpper -XX:+UseXmmRegToRegMoveAll -Dfile.encoding=UTF-8 -Djava.security.egd=file:/dev/urandom"
    JAVA_CMD="java $COMMON_JVM_FLAGS -jar server.jar nogui"

    if [[ "$VERSION" =~ ^1\.(17|18|19|20|21)(\.|$) ]]; then
        JAVA_CMD="java $COMMON_JVM_FLAGS --add-modules jdk.incubator.vector -XX:UseAVX=2 -Xlog:async -jar server.jar nogui"
    elif [[ "$VERSION" =~ ^1\.(8|9|10|11|12|13|14|15|16)(\.|$) ]]; then
        JAVA_CMD="java $COMMON_JVM_FLAGS -XX:-UseBiasedLocking -XX:UseAVX=3 -jar server.jar nogui"
    fi

    $JAVA_CMD
done
