#!/usr/bin/env bats

load bats-helper
source ../"$(filename)"

@test "test bash_precmd" {
    BASH_PRECMDS=()
    run bash_precmd
    assert_success

    BASH_PRECMDS=('echo yeah')
    run bash_precmd
    assert_success
    assert_output 'yeah'

    BASH_PRECMDS=('echo one' 'echo two')
    run bash_precmd
    assert_success
    assert_match 'one.*two'

    BASH_PRECMDS=(false)
    run bash_precmd
    assert_failure
}
