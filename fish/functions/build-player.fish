function build-player
    pushd ~/GIT/c360-lead
    cargo build --release $argv
    popd
end
