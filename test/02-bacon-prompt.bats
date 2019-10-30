#!/usr/bin/env bats

load bats-helper
load bacon-helper

@test "bacon_promptc" {
    run bacon_promptc "test"
    assert_success
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[default]}")"
    assert_match '\['

    for color in "${!BACON_COLOR[@]}"; do
        run bacon_promptc $color "test"
        assert_success
        assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[$color]}")"
    done

    run bacon_promptc red bold test
    assert_success
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[red]}")"
}

@test "bacon_prompt_last_status" {
    local LAST_STATUS=0
    run bacon_prompt_last_status
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[green]}")"
    LAST_STATUS=1
    run bacon_prompt_last_status
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[red]}")"

    local -A BACON_PROMPT_COLOR=()
    BACON_PROMPT_COLOR[last_ok]=blue
    LAST_STATUS=0
    run bacon_prompt_last_status
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[blue]}")"
    BACON_PROMPT_COLOR[last_fail]=yellow
    LAST_STATUS=1
    run bacon_prompt_last_status
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[yellow]}")"

    run bacon_prompt_last_status
    assert_match '&'
    local -A BACON_PROMPT_CHARS=()
    BACON_PROMPT_CHARS[last_status]='@'
    run bacon_prompt_last_status
    assert_match '@'
}

@test "bacon_prompt_time" {
    run bacon_prompt_time
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[green]}")"
    assert_match 'A'

    local -A BACON_PROMPT_COLOR=()
    BACON_PROMPT_COLOR[time]=cyan
    run bacon_prompt_time
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[cyan]}")"

    local -A BACON_PROMPT_CHARS=()
    BACON_PROMPT_CHARS[time]=B
    run bacon_prompt_time
    assert_match 'B'
}

@test "bacon_prompt_location" {
    run bacon_prompt_location
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[bule]}")"
    assert_match 'u.*h.*W'

    local -A BACON_COLOR=()
    BACON_COLOR[location]=green
    run bacon_prompt_location
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[green]}")"

    local -A BACON_PROMPT_CHARS=()
    BACON_PROMPT_CHARS[location]=XXXXXX
    run bacon_prompt_location
    assert_match 'XXXXXX'
}

@test "bacon_prompt_counter" {
    local BACON_PROMPT_COUNTERS=()
    run bacon_prompt_counter
    assert_output ''
    BACON_PROMPT_COUNTERS=('echo 1')
    run bacon_prompt_counter
    assert_match 'e1'
    BACON_PROMPT_COUNTERS=('echo 1' 'echo 2')
    run bacon_prompt_counter
    assert_match 'e1ec2'
    BACON_PROMPT_COUNTERS=('echo 1' 'printf 2')
    run bacon_prompt_counter
    assert_match 'e1p2'

    run bacon_prompt_counter
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[yellow]}")"
    local -A BACON_COLOR=()
    BACON_COLOR[counter]=black
    run bacon_prompt_counter
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[black]}")"
}

@test "bacon_prompt_dollar" {
    run bacon_prompt_dollar
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[blue]}")"
    assert_match '\$'

    local -A BACON_PROMPT_COLOR=()
    BACON_PROMPT_COLOR[dollar]=cyan
    run bacon_prompt_dollar
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[cyan]}")"

    local -A BACON_PROMPT_CHARS=()
    BACON_PROMPT_CHARS[dollar]=D
    run bacon_prompt_dollar
    assert_match 'D'
}

@test "bacon_prompt_PS1" {
    local BACON_PROMPT_PS1_LAYOUT=()
    run eval bacon_prompt_PS1 '&&' '[[ $PS1 =~ \$ ]]'
    assert_success
    one() { echo one; }
    two() { echo two; }
    BACON_PROMPT_PS1_LAYOUT=(one two)
    run eval bacon_prompt_PS1 '&&' '[[ $PS1 =~ onetwo ]]'
    assert_success
}
