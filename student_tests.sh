#!/usr/bin/env bats

# File: student_tests.sh
# 
# Create your unit tests suit in this file

@test "Example: check ls runs without errors" {
    run ./dsh <<EOF                
ls
EOF

    # Assertions
    [ "$status" -eq 0 ]
}

@test "Simple pipe: ls | grep dshlib" {
    run ./dsh <<EOF
ls | grep dshlib
EOF
    [ "$status" -eq 0 ]
    [[ "$output" == *"dshlib"* ]]
}


@test "Pipe with spaces: ls -l | grep dshlib" {
    run ./dsh <<EOF
ls -l | grep dshlib
EOF
    [ "$status" -eq 0 ]
    [[ "$output" =~ "dshlib" ]]
}

@test "Exit command handles multiple commands" {
    run ./dsh <<EOF
ls | grep dshlib
exit
EOF
    [ "$status" -eq 0 ]
}


@test "Pipe with environment command: env | grep USER" {
    run ./dsh <<EOF
env | grep USER
EOF
    [ "$status" -eq 0 ]
    [[ "$output" == *"USER"* ]]
}

@test "Handling direct pipe to ls" {
    run ./dsh <<EOF
| ls
EOF
    [ "$status" -eq 0 ]
}

@test "Pipe with changing directory: cd .. | pwd" {
    run ./dsh <<EOF
cd ..
pwd
EOF
    [ "$status" -eq 0 ]
}