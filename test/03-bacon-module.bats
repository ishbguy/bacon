#!/usr/bin/env bats

load bats-helper
load bacon-helper

@test "test bacon_module_[start|end]" {
    shopt -s expand_aliases
    run eval '(bacon_module_start test; alias A=a; bacon_module_end; echo "${BACON_MODULE_TEST_ALIAS[@]}")'
    assert_output "A"
    run eval '(bacon_module_start test; alias A=a B=b; bacon_module_end; echo "${BACON_MODULE_TEST_ALIAS[@]}")'
    assert_output "A B"
    run eval '(bacon_module_start test; A() { :; }; bacon_module_end; echo "${BACON_MODULE_TEST_FUNCS[@]}")'
    assert_output "A"
    run eval '(bacon_module_start test; A() { :; }; B() { :; }; bacon_module_end; echo "${BACON_MODULE_TEST_FUNCS[@]}")'
    assert_output "A B"
    run eval '(bacon_module_start test; A=a; bacon_module_end; echo "${BACON_MODULE_TEST_VARS[@]}")'
    assert_match "A"
    run eval '(bacon_module_start test; A=a B=b; bacon_module_end; echo "${BACON_MODULE_TEST_VARS[@]}")'
    assert_match "A B"
}

@test "test bacon_module_export" {
    run eval '(bacon_module_export && [[ -n $BACON_MODULE_BATS_EXEC_TEST_ABS_SRC ]] && echo "${BACON_MODULE_BATS_EXEC_TEST_ABS_SRC}")'
    assert_match "bats-exec-test$"
    run bacon_module_export test
    assert_success
    run bacon_module_export one two
    assert_success
    
    run eval '(bacon_module_export TEST; [[ -n $BACON_MODULE_TEST_ABS_SRC && -n $BACON_MODULE_TEST_ABS_DIR ]])'
    assert_success
    run eval '(bacon_module_export test; [[ -n $BACON_MODULE_TEST_ABS_SRC && -n $BACON_MODULE_TEST_ABS_DIR ]])'
    assert_success
}
