#!/usr/bin/env bats

load bats-helper
load bacon-helper

@test "test bacon_has_map" {
    run bacon_has_map NO_MAP
    assert_failure
    assert_output ""

    local -A HAS_MAP=()
    HAS_MAP[has]=map
    run bacon_has_map HAS_MAP has
    assert_success
    assert_output ""
}

@test "test bacon_color_echo" {
    run bacon_color_echo "test"
    assert_success
    assert_match "$(printf '\x1B\[%sm' ${BACON_ANSI_COLOR[default]})"

    for color in "${!BACON_ANSI_COLOR[@]}"; do
        run bacon_color_echo $color "test"
        assert_success
        assert_match "$(printf '\x1B\[%sm' ${BACON_ANSI_COLOR[$color]})"
    done

    run bacon_color_echo red bold test
    assert_success
    assert_match "$(printf '\x1B\[%sm' "${BACON_ANSI_COLOR[red]};${BACON_ANSI_COLOR[bold]}")"
}

@test "test bacon_msg" {
    run bacon_msg test
    assert_success
    assert_match "$(printf '\x1B\[%sm' ${BACON_ANSI_COLOR[yellow]})"
}

@test "test bacon_warn" {
    run bacon_warn test
    assert_failure
    assert_match "$(printf '\x1B\[%sm' ${BACON_ANSI_COLOR[red]})"
}

@test "test bacon_die" {
    run bacon_die test
    assert_failure
    assert_match "$(printf '\x1B\[%sm' ${BACON_ANSI_COLOR[red]})"
}

@test "test bacon_defined" {
    run bacon_defined NOT_DEFINED
    assert_failure

    local DEFINED=""
    run bacon_defined DEFINED
    assert_success
}

@test "test bacon_definedf" {
    run bacon_definedf not_func
    assert_failure

    one() { true; }
    run bacon_definedf one
    assert_success
}

@test "test bacon_is_sourced" {
    echo "source $(suitedir)/../lib/$(suitename).sh; bacon_is_sourced && echo yes || echo no" >"$PROJECT_TMP_DIR"/test_is_sourced.sh

    run source "$PROJECT_TMP_DIR"/test_is_sourced.sh
    assert_success
    assert_output yes

    run bash "$PROJECT_TMP_DIR"/test_is_sourced.sh
    assert_success
    assert_output no
}

@test "test bacon_is_array" {
    local var=""
    run bacon_is_array var
    assert_failure

    local array=()
    run bacon_is_array array
    assert_success

    local -A map=()
    run bacon_is_array map
    assert_failure
}

@test "test bacon_is_map" {
    local var=""
    run bacon_is_map var
    assert_failure

    local array=()
    run bacon_is_map array
    assert_failure

    local -A map=()
    run bacon_is_map map
    assert_success
}

@test "test bacon_has_cmd" {
    run bacon_has_cmd cmd_not_exist
    assert_failure
    run bacon_has_cmd bash
    assert_success
}

@test "test bacon_ensure" {
    run bacon_ensure "[[ -d $PROJECT_TMP_DIR ]]" "$PROJECT_TMP_DIR is not a dir"
    assert_success
    run bacon_ensure "[[ -d xxxx ]]" "xxxx is not a dir"
    assert_failure
    assert_match 'xxxx is not a dir'
}

@test "test bacon_date_cmp" {
    run bacon_date_cmp '2019-10-01 10:00:00' '2019-10-01 10:00:00'
    assert_success
    assert_output 0
    run bacon_date_cmp '2019-10-01 10:00:00' '2019-10-01 10:00:01'
    assert_success
    assert_output -1
    run bacon_date_cmp '2019-10-01 10:00:01' '2019-10-01 10:00:00'
    assert_success
    assert_output 1
    run bacon_date_cmp '1970-01-01' '2019-10-01'
    assert_success
    run bacon_date_cmp '2019-10-01' '1970-01-01' 
    assert_success
}

@test "test bacon_pargs" {
    local -A opt=()
    local -A arg=()
    run bacon_pargs opt arg 'v'
    assert_success
    run eval bacon_pargs opt arg 'v' x '&&' '[[ ${opt[v]} == "" ]]'
    assert_success
    run eval bacon_pargs opt arg 'v' -v '&&' '[[ ${opt[v]} == 1 ]]'
    assert_success
    run eval bacon_pargs opt arg 'v:' -v v '&&' '[[ ${opt[v]} == 1 && ${arg[v]} == v ]]'
    assert_success

    # run eval bacon_pargs opt arg 'v:' a b -v v '&&' '[[ ${opt[v]} == 1 && ${arg[v]} == v ]]'
    # assert_success
    # run eval bacon_pargs opt arg 'hv:' a b -v v -h c '&&' '[[ ${opt[h]} == 1 && ${opt[v]} == 1 && ${arg[v]} == v ]]'
    # assert_success
    # run eval bacon_pargs opt arg 'hv:' a b -hv v '&&' '[[ ${opt[h]} == 1 && ${opt[v]} == 1 && ${arg[v]} == v ]]'
    # assert_success

    run bacon_pargs opt arg 'v' -x
    assert_failure
    run bacon_pargs opt arg 'v:' -v
    assert_failure
}

@test "test bacon_require_base" {
    is_exist() { [[ -e $1 ]]; }
    run bacon_require_base is_exist "file does not exist" xxx
    assert_failure
    assert_match 'file does not exist: xxx.'
    run bacon_require_base is_exist "file does not exist" one two
    assert_match 'file does not exist: one.*two.'
    touch "$PROJECT_TMP_DIR"/bacon_require_base_file
    run bacon_require_base is_exist "file does not exist" "$PROJECT_TMP_DIR"/bacon_require_base_file
    assert_success
}

@test "test bacon_require_var" {
    local var=''
    run bacon_require_var var
    assert_success
    run bacon_require_var no_var
    assert_failure
    assert_match "no_var"
    run bacon_require_var no_var1 no_var2
    assert_failure
    assert_match "no_var1.*no_var2"
}

@test "test bacon_require_func" {
    run bacon_require_func bacon_require_func
    assert_success
    run bacon_require_func no_func
    assert_failure
    assert_match no_func
    run bacon_require_func no_func1 no_func2
    assert_failure
    assert_match "no_func1.*no_func2"
}

@test "test bacon_require_cmd" {
    run bacon_require_cmd bash
    assert_success
    run bacon_require_cmd cmd_not_exist
    assert_failure
    assert_match "You need to install cmds: cmd_not_exist."
    run bacon_require_cmd ONE TWO
    assert_failure
    assert_match "You need to install cmds: ONE.*TWO."
}
