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

@test "test bacon_printc" {
    run bacon_printc "test"
    assert_success
    assert_match "$(printf '\x1B\[%sm' ${BACON_ANSI_COLOR[default]})"

    for color in "${!BACON_ANSI_COLOR[@]}"; do
        run bacon_printc $color "test"
        assert_success
        assert_match "$(printf '\x1B\[%sm' ${BACON_ANSI_COLOR[$color]})"
    done

    run bacon_printc red bold test
    assert_success
    assert_match "$(printf '\x1B\[%sm' "${BACON_ANSI_COLOR[red]};${BACON_ANSI_COLOR[bold]}")"
}

@test "test bacon_puts" {
    run bacon_puts
    assert_output ""
    run bacon_puts test
    assert_output "test"
}

@test "test bacon_debug" {
    run bacon_debug
    assert_success
    assert_output ""

    local BACON_DEBUG=yes
    run bacon_debug
    assert_success
    assert_match 'DEBUG'
    run bacon_debug test
    assert_match 'DEBUG: test'
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
    local -a array=()
    run bacon_defined array
    assert_success
    local -A map=()
    run bacon_defined map
    assert_success
    local -i int=0
    run bacon_defined int
    assert_success
    local -l low=low
    run bacon_defined low
    assert_success
    local -u upper=UPPER
    run bacon_defined upper
    assert_success
    local -n ar=array
    run bacon_defined ar
    assert_success
    local -r ro=ro
    run bacon_defined ro
    assert_success
    local -x xp=xxx
    run bacon_defined xp
    assert_success
}

@test "test bacon_definedf" {
    run bacon_definedf not_func
    assert_failure

    one() { true; }
    run bacon_definedf one
    assert_success
}

@test "test bacon_typeof" {
    run bacon_typeof
    assert_failure
    assert_output ""
    run bacon_typeof NOT_DEFINED
    assert_failure
    assert_output ""
    local var=""
    run bacon_typeof var NOTVAR
    assert_failure
    assert_output ""

    local DEFINED=""
    run bacon_typeof DEFINED
    assert_success
    assert_output "normal"
    local -a array=()
    run bacon_typeof array
    assert_success
    assert_output "array"
    local -A map=()
    run bacon_typeof map
    assert_success
    assert_output "map"
    local -i int=0
    run bacon_typeof int
    assert_success
    assert_output "integer"
    local -l low=low
    run bacon_typeof low
    assert_success
    assert_output "lower"
    local -u upper=UPPER
    run bacon_typeof upper
    assert_success
    assert_output "upper"
    local -n ar=array
    run bacon_typeof ar
    assert_success
    assert_output "reference"
    local -x xp=xxx
    run bacon_typeof xp
    assert_success
    assert_output "export"
    func() { true; }
    run bacon_typeof func
    assert_success
    assert_output "function"

    # local -r ro=ro
    # run bacon_typeof ro
    # assert_success
    # assert_output "readonly"
    # declare -g GLOBAL=""
    # run bacon_typeof GLOBAL
    # assert_success
    # assert_output "global"
}

@test "test bacon_is_sourced" {
    # echo "source $(suitedir)/../lib/$(suitename).sh; bacon_is_sourced && echo yes || echo no" >"$PROJECT_TMP_DIR"/test_is_sourced.sh
    cat <<EOF >"$PROJECT_TMP_DIR"/test_is_sourced.sh
    source $(suitedir)/../lib/$(suitename).sh
    bacon_is_sourced && echo yes || echo no
EOF

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

@test "test bacon_is_exist" {
    run bacon_is_exist
    assert_failure
    assert_output ""

    run bacon_is_exist "$PROJECT_TMP_DIR"
    assert_success
    assert_output ""

    run bacon_is_exist "$PROJECT_TMP_DIR/$RANDOM"
    assert_failure
    assert_output ""

    touch "$PROJECT_TMP_DIR/new-file"
    run bacon_is_exist "$PROJECT_TMP_DIR/new-file"
    assert_success
    assert_output ""
}

@test "test bacon_ensure" {
    run bacon_ensure "[[ -d $PROJECT_TMP_DIR ]]" "$PROJECT_TMP_DIR is not a dir"
    assert_success

    run bacon_ensure "[[ -d xxxx ]]" "xxxx is not a dir"
    assert_failure
    assert_match 'xxxx is not a dir'

    local BACON_NO_ENSURE=yes
    run bacon_ensure "[[ -d xxxx ]]" "xxxx is not a dir"
    assert_success
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

@test "test bacon_require" {
    run bacon_require NA
    assert_failure
    assert_match "No such files or dirs: NA."

    run bacon_require NA NB
    assert_failure
    assert_match "No such files or dirs: NA.*NB"

    touch "$PROJECT_TMP_DIR"/{A,B}
    run bacon_require "$PROJECT_TMP_DIR"/{A,B}
    assert_success
    assert_output ""
    run bacon_require "$PROJECT_TMP_DIR"/{A,B,N}
    assert_failure
    assert_match "No such files or dirs: $PROJECT_TMP_DIR/N."
}

@test "test bacon_abs_path" {
    run bacon_abs_path "$PROJECT_TMP_DIR/xxxx"
    assert_success
    assert_output "$PROJECT_TMP_DIR/xxxx"

    mkdir -p "$PROJECT_TMP_DIR/real-dir" && ln -s "$PROJECT_TMP_DIR/real-dir" "$PROJECT_TMP_DIR/link-dir"
    run bacon_abs_path "$PROJECT_TMP_DIR/link-dir"
    assert_success
    assert_output "$PROJECT_TMP_DIR/real-dir"

    touch "$PROJECT_TMP_DIR/real-file" && ln -s "$PROJECT_TMP_DIR/real-file" "$PROJECT_TMP_DIR/link-file"
    run bacon_abs_path "$PROJECT_TMP_DIR/link-file"
    assert_success
    assert_output "$PROJECT_TMP_DIR/real-file"
}

@test "test bacon_self" {
    cat <<EOF >"$PROJECT_TMP_DIR/test-bacon-self.sh"
    source $(suitedir)/../lib/$(suitename).sh
    bacon_self
EOF

    run eval "(cd $PROJECT_TMP_DIR; bash test-bacon-self.sh)"
    assert_success
    assert_match "$PROJECT_TMP_DIR/test-bacon-self.sh"

    run eval "(bash $PROJECT_TMP_DIR/test-bacon-self.sh)"
    assert_success
    assert_match "$PROJECT_TMP_DIR/test-bacon-self.sh"
}

@test "test bacon_lib" {
    run bacon_lib
    assert_success
    assert_output "$(readlink -f $(suitedir)/../lib)"
}

@test "test bacon_load" {
    run eval '[[ -z $BACON_LIB_PATH ]]'
    assert_success

    run bacon_load
    assert_failure
    run eval '(bacon_load; [[ -n $BACON_LIB_PATH ]])'
    assert_success
    run eval '(bacon_load; echo $BACON_LIB_PATH)'
    assert_output "$(bacon_lib)"

    run bacon_load "$(suitename)"
    assert_success
    run bacon_load no_mod
    assert_failure

    local libdir="$PROJECT_TMP_DIR/load-lib"
    mkdir -p "$libdir"
    local BACON_LIB_PATH="$libdir"
    run bacon_load "$(suitename)"
    assert_success
    echo "hello() { echo hello; }" >"$libdir/hello.sh"
    run eval '(bacon_load hello; hello)'
    assert_success
    assert_output "hello"
    
    local libdir2="$PROJECT_TMP_DIR/load-lib2"
    mkdir -p "$libdir2"
    BACON_LIB_PATH="$BACON_LIB_PATH:$libdir2"
    echo "world() { echo world; }" >"$libdir2/world.sh"
    run eval '(bacon_load world; world)'
    assert_success
    assert_output "world"

    cat <<EOF >"$libdir/count.sh"
    [[ -n \$BACON_LOAD_COUNT ]] || BACON_LOAD_COUNT=0
    echo "\$((++BACON_LOAD_COUNT))"
EOF
    run eval '(bacon_load count; bacon_load count; bacon_load count)'
    assert_match '^1$'
}

@test "test bacon_export" {
    run bacon_export
    assert_failure

    run bacon_export test
    assert_success
    run bacon_export one two
    assert_failure
    
    run eval '(bacon_export TEST; [[ -n $BACON_EXPORT_TEST_ABS_SRC && -n $BACON_EXPORT_TEST_ABS_DIR ]])'
    assert_success
    run eval '(bacon_export test; [[ -n $BACON_EXPORT_TEST_ABS_SRC && -n $BACON_EXPORT_TEST_ABS_DIR ]])'
    assert_success
}
