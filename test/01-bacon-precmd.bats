#!/usr/bin/env bats

load bats-helper
source ../lib/"$(filename)".sh

@test "test bacon_precmd" {
    BACON_PRECMDS=()
    run bacon_precmd
    assert_success

    BACON_PRECMDS=('echo yeah')
    run bacon_precmd
    assert_success
    assert_output 'yeah'

    BACON_PRECMDS=('echo one' 'echo two')
    run bacon_precmd
    assert_success
    assert_match 'one.*two'

    BACON_PRECMDS=(false)
    run bacon_precmd
    assert_failure
}
