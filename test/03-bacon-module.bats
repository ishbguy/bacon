#!/usr/bin/env bats

load bats-helper
load bacon-helper

@test "bacon_cap_[start|end]" {
    shopt -s expand_aliases
    run eval '(bacon_cap_start test; alias A=a; bacon_cap_end; echo "${BACON_MODULE_TEST_ALIAS[@]}")'
    assert_output "A"
    run eval '(bacon_cap_start test; alias A=a B=b; bacon_cap_end; echo "${BACON_MODULE_TEST_ALIAS[@]}")'
    assert_output "A B"
    run eval '(bacon_cap_start test; A() { :; }; bacon_cap_end; echo "${BACON_MODULE_TEST_FUNCS[@]}")'
    assert_output "A"
    run eval '(bacon_cap_start test; A() { :; }; B() { :; }; bacon_cap_end; echo "${BACON_MODULE_TEST_FUNCS[@]}")'
    assert_output "A B"
    run eval '(bacon_cap_start test; A=a; bacon_cap_end; echo "${BACON_MODULE_TEST_VARS[@]}")'
    assert_match "A"
    run eval '(bacon_cap_start test; A=a B=b; bacon_cap_end; echo "${BACON_MODULE_TEST_VARS[@]}")'
    assert_match "A B"
}
