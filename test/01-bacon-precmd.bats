#!/usr/bin/env bats

load bats-helper
load bacon-helper

@test "bacon_precmd" {
    BACON_PRECMD=()
    run bacon_precmd
    assert_success

    BACON_PRECMD=('echo yeah')
    run bacon_precmd
    assert_success
    assert_output 'yeah'

    BACON_PRECMD=('echo one' 'echo two')
    run bacon_precmd
    assert_success
    assert_match 'one.*two'

    # BACON_PRECMD=(false)
    # run bacon_precmd
    # assert_failure
}
