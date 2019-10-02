#!/usr/bin/env bats

load bats-helper
source ../lib/"$(filename)"

@test "test has_map" {
    run has_map NO_MAP
    assert_failure
    assert_output ""

    local -A HAS_MAP=()
    HAS_MAP[has]=map
    run has_map HAS_MAP has
    assert_success
    assert_output ""
}

@test "test color_echo" {
    run color_echo "test"
    assert_success
    assert_match "$(printf '\x1B\[%sm' ${BASH_ANSI_COLOR[default]})"

    for color in "${!BASH_ANSI_COLOR[@]}"; do
        run color_echo $color "test"
        assert_success
        assert_match "$(printf '\x1B\[%sm' ${BASH_ANSI_COLOR[$color]})"
    done

    run color_echo red bold test
    assert_success
    assert_match "$(printf '\x1B\[%sm' "${BASH_ANSI_COLOR[red]};${BASH_ANSI_COLOR[bold]}")"
}

@test "test msg" {
    run msg test
    assert_success
    assert_match "$(printf '\x1B\[%sm' ${BASH_ANSI_COLOR[yellow]})"
}

@test "test warn" {
    run warn test
    assert_failure
    assert_match "$(printf '\x1B\[%sm' ${BASH_ANSI_COLOR[red]})"
}

@test "test die" {
    run die test
    assert_failure
    assert_match "$(printf '\x1B\[%sm' ${BASH_ANSI_COLOR[red]})"
}

@test "test defined" {
    run defined NOT_DEFINED
    assert_failure

    local DEFINED=""
    run defined DEFINED
    assert_success
}

@test "test definedf" {
    run definedf not_func
    assert_failure

    one() { true; }
    run definedf one
    assert_success
}

@test "test is_sourced" {
    echo "source ../lib/$(filename); is_sourced && echo yes || echo no" >"$PROJECT_TEST_DIR"/test_is_sourced.sh

    run source "$PROJECT_TEST_DIR"/test_is_sourced.sh
    assert_success
    assert_output yes

    run bash "$PROJECT_TEST_DIR"/test_is_sourced.sh
    assert_success
    assert_output no
}

@test "test is_array" {
    local var=""
    run is_array var
    assert_failure

    local array=()
    run is_array array
    assert_success

    local -A map=()
    run is_array map
    assert_failure
}

@test "test is_map" {
    local var=""
    run is_map var
    assert_failure

    local array=()
    run is_map array
    assert_failure

    local -A map=()
    run is_map map
    assert_success
}

@test "test has_tool" {
    run has_tool cmd_not_exist
    assert_failure
    run has_tool bash
    assert_success
}

@test "test ensure" {
    run ensure "[[ -d $PROJECT_TEST_DIR ]]" "$PROJECT_TEST_DIR is not a dir"
    assert_success
    run ensure "[[ -d xxxx ]]" "xxxx is not a dir"
    assert_failure
    assert_match 'xxxx is not a dir'
}

@test "test date_cmp" {
    run date_cmp '2019-10-01 10:00:00' '2019-10-01 10:00:00'
    assert_success
    assert_output 0
    run date_cmp '2019-10-01 10:00:00' '2019-10-01 10:00:01'
    assert_success
    assert_output -1
    run date_cmp '2019-10-01 10:00:01' '2019-10-01 10:00:00'
    assert_success
    assert_output 1
    run date_cmp '1970-01-01' '2019-10-01'
    assert_success
    run date_cmp '2019-10-01' '1970-01-01' 
    assert_success
}

@test "test pargs" {
    local -A opt=()
    local -A arg=()
    run pargs opt arg 'v'
    assert_success
    run eval pargs opt arg 'v' x '&&' '[[ ${opt[v]} == "" ]]'
    assert_success
    run eval pargs opt arg 'v' -v '&&' '[[ ${opt[v]} == 1 ]]'
    assert_success
    run eval pargs opt arg 'v:' -v v '&&' '[[ ${opt[v]} == 1 && ${arg[v]} == v ]]'
    assert_success

    # run eval pargs opt arg 'v:' a b -v v '&&' '[[ ${opt[v]} == 1 && ${arg[v]} == v ]]'
    # assert_success
    # run eval pargs opt arg 'hv:' a b -v v -h c '&&' '[[ ${opt[h]} == 1 && ${opt[v]} == 1 && ${arg[v]} == v ]]'
    # assert_success
    # run eval pargs opt arg 'hv:' a b -hv v '&&' '[[ ${opt[h]} == 1 && ${opt[v]} == 1 && ${arg[v]} == v ]]'
    # assert_success

    run pargs opt arg 'v' -x
    assert_failure
    run pargs opt arg 'v:' -v
    assert_failure
}

@test "test chkobj" {
    is_exist() { [[ -e $1 ]]; }
    run chkobj is_exist "file does not exist" xxx
    assert_failure
    assert_match 'file does not exist: xxx.'
    run chkobj is_exist "file does not exist" one two
    assert_match 'file does not exist: one.*two.'
    touch "$PROJECT_TEST_DIR"/chkobj_file
    run chkobj is_exist "file does not exist" "$PROJECT_TEST_DIR"/chkobj_file
    assert_success
}

@test "test chkvar" {
    local var=''
    run chkvar var
    assert_success
    run chkvar no_var
    assert_failure
    assert_match "no_var"
    run chkvar no_var1 no_var2
    assert_failure
    assert_match "no_var1.*no_var2"
}

@test "test chkfunc" {
    run chkfunc chkfunc
    assert_success
    run chkfunc no_func
    assert_failure
    assert_match no_func
    run chkfunc no_func1 no_func2
    assert_failure
    assert_match "no_func1.*no_func2"
}

@test "test chktool" {
    run chktool bash
    assert_success
    run chktool cmd_not_exist
    assert_failure
    assert_match "You need to install tools: cmd_not_exist."
    run chktool ONE TWO
    assert_failure
    assert_match "You need to install tools: ONE.*TWO."
}
