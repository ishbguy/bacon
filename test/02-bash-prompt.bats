#!/usr/bin/env bats

load bats-helper
source ../bash-utils
source ../bash-precmd
source ../"$(filename)"

@test "test bash_prompt_color" {
    run bash_prompt_color "test"
    assert_success
    assert_match "$(printf '%sm' ${BASH_ANSI_COLOR[default]})"

    for color in "${!BASH_ANSI_COLOR[@]}"; do
        run bash_prompt_color $color "test"
        assert_success
        assert_match "$(printf '%sm' ${BASH_ANSI_COLOR[$color]})"
    done

    run bash_prompt_color red bold test
    assert_success
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[red]};${BASH_ANSI_COLOR[bold]}")"
}

@test "test bash_prompt_last_status" {
    local LAST_STATUS=0
    run bash_prompt_last_status
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[green]}")"
    LAST_STATUS=1
    run bash_prompt_last_status
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[red]}")"

    local -A BASH_PROMPT_COLOR=()
    BASH_PROMPT_COLOR[last_ok]=blue
    LAST_STATUS=0
    run bash_prompt_last_status
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[blue]}")"
    BASH_PROMPT_COLOR[last_fail]=yellow
    LAST_STATUS=1
    run bash_prompt_last_status
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[yellow]}")"

    run bash_prompt_last_status
    assert_match '&'
    local -A BASH_PROMPT_CHARS=()
    BASH_PROMPT_CHARS[last_status]='@'
    run bash_prompt_last_status
    assert_match '@'
}

@test "test bash_prompt_time" {
    run bash_prompt_time
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[green]}")"
    assert_match 'A'

    local -A BASH_PROMPT_COLOR=()
    BASH_PROMPT_COLOR[time]=cyan
    run bash_prompt_time
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[cyan]}")"

    local -A BASH_PROMPT_CHARS=()
    BASH_PROMPT_CHARS[time]=B
    run bash_prompt_time
    assert_match 'B'
}

@test "test bash_prompt_location" {
    run bash_prompt_location
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[blue]}")"
    assert_match 'u.*h.*W'

    local -A BASH_ANSI_COLOR=()
    BASH_ANSI_COLOR[location]=green
    run bash_prompt_location
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[green]}")"

    local -A BASH_PROMPT_CHARS=()
    BASH_PROMPT_CHARS[location]=XXXXXX
    run bash_prompt_location
    assert_match 'XXXXXX'
}

@test "test bash_prompt_counter" {
    local BASH_PROMPT_COUNTERS=()
    run bash_prompt_counter
    assert_output ''
    BASH_PROMPT_COUNTERS=('echo 1')
    run bash_prompt_counter
    assert_match 'e1'
    BASH_PROMPT_COUNTERS=('echo 1' 'echo 2')
    run bash_prompt_counter
    assert_match 'e1ec2'
    BASH_PROMPT_COUNTERS=('echo 1' 'printf 2')
    run bash_prompt_counter
    assert_match 'e1p2'

    run bash_prompt_counter
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[yellow]}")"
    local -A BASH_ANSI_COLOR=()
    BASH_ANSI_COLOR[counter]=black
    run bash_prompt_counter
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[black]}")"
}

@test "test bash_prompt_dollar" {
    run bash_prompt_dollar
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[blue]}")"
    assert_match '\$'

    local -A BASH_PROMPT_COLOR=()
    BASH_PROMPT_COLOR[dollar]=cyan
    run bash_prompt_dollar
    assert_match "$(printf '%sm' "${BASH_ANSI_COLOR[cyan]}")"

    local -A BASH_PROMPT_CHARS=()
    BASH_PROMPT_CHARS[dollar]=D
    run bash_prompt_dollar
    assert_match 'D'
}

@test "test bash_prompt_PS1" {
    local BASH_PROMPT_PS1_LAYOUT=()
    run eval bash_prompt_PS1 '&&' '[[ $PS1 =~ \$ ]]'
    assert_success
    one() { echo one; }
    two() { echo two; }
    BASH_PROMPT_PS1_LAYOUT=(one two)
    run eval bash_prompt_PS1 '&&' '[[ $PS1 =~ onetwo ]]'
    assert_success
}
