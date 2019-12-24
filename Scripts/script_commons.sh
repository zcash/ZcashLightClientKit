export PATH="$HOME/.cargo/bin:$PATH"
export RUST_LIB_PATH="${PODS_TARGET_SRCROOT}/lib"
export ZCASH_POD_SCRIPTS="${PODS_TARGET_SRCROOT}/Scripts"
export ZCASH_LIB_RUST_BUILD_PATH="${PODS_TARGET_SRCROOT}/target"
export ZCASH_BUILD_TYPE_MAINNET_FLAG=".mainnet_build"
export ZCASH_BUILD_TYPE_TESTNET_FLAG=".testnet_build"
export ZCASH_LIB_RUST_NAME="libzcashlc.a"
export ZCASH_TESTNET="TESTNET"
export ZCASH_MAINNET="MAINNET"
export ZCASH_SRC_PATH="${PODS_TARGET_SRCROOT}/ZcashLightClientKit"
export ZCASH_SDK_RUST_LIB_PATH="${ZCASH_SRC_PATH}/zcashlc"
export ZCASH_SDK_GENERATED_SOURCES_FOLDER="${ZCASH_SRC_PATH}/Generated"
function clean {
    cargo clean
    if [ -d "${RUST_LIB_PATH}" ]; then 
        rm -rf "${RUST_LIB_PATH}"
    fi 
    if [ -d "${ZCASH_LIB_RUST_BUILD_PATH}" ]; then 
        rm -rf "${ZCASH_LIB_RUST_BUILD_PATH}"
    fi 
}

function check_environment {

    if [[ $ZCASH_NETWORK_ENVIRONMENT != $ZCASH_MAINNET ]] && [[ $ZCASH_NETWORK_ENVIRONMENT != $ZCASH_TESTNET ]]; then
        echo "No network environment. Set ZCASH_NETWORK_ENVIRONMENT to $ZCASH_MAINNET or $ZCASH_TESTNET"
        exit 1
    fi

    if [[ ! $ZCASH_SDK_GENERATED_SOURCES_FOLDER ]]; then
        echo "No 'ZCASH_SDK_GENERATED_SOURCES_FOLDER' variable present. delete Pods/ and run 'pod install --verbose'"
        exit 1
    fi
}

function is_mainnet {
    if [[ $ZCASH_NETWORK_ENVIRONMENT = $ZCASH_MAINNET ]]; then
        true
    else 
        false
    fi
}

function existing_build_mismatch {
    #if build exists check that corresponds to the current network environment
    if [ -d $ZCASH_LIB_RUST_BUILD_PATH ]; then
        if [ -f "$ZCASH_LIB_RUST_BUILD_PATH/$ZCASH_BUILD_TYPE_MAINNET_FLAG" ] && [[ "$ZCASH_NETWORK_ENVIRONMENT" = "$ZCASH_MAINNET" ]]
        then
            false
        elif [ -f "$ZCASH_LIB_RUST_BUILD_PATH/$ZCASH_BUILD_TYPE_TESTNET_FLAG" ] && [[ "$ZCASH_NETWORK_ENVIRONMENT" = "$ZCASH_TESTNET" ]]
        then
            warn_mismatch $ZCASH_BUILD_TYPE_MAINNET_FLAG $ZCASH_NETWORK_ENVIRONMENT
            false
        else
            echo "=== NO BUILD FLAG, CHECKING ENVIRONMENT ==="
            check_environment
            false
        fi
    fi
    false
}

function warn_mismatch {
    echo "*** WARNING: *** build mismatch. found ${0} but environment is ${1}"
}

function persist_environment {
    check_environment

    if [ $ZCASH_NETWORK_ENVIRONMENT = "$ZCASH_MAINNET" ]
    then 
        touch $ZCASH_LIB_RUST_BUILD_PATH/$ZCASH_BUILD_TYPE_MAINNET_FLAG
    elif [[ "$ZCASH_NETWORK_ENVIRONMENT" = "$ZCASH_TESTNET" ]]
    then
        touch $ZCASH_LIB_RUST_BUILD_PATH/$ZCASH_BUILD_TYPE_TESTNET_FLAG
    fi
}