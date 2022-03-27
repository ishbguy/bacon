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

@test "bacon_prompt_format_expand" {
    # test null string
    run bacon_prompt_format_expand ''
    assert_success
    assert_match '^$'
    run bacon_prompt_format_expand '#{test}'
    assert_success
    assert_match '^$'

    # test var expand
    BACON_PROMPT_INFO[one]='1'
    run bacon_prompt_format_expand '#{one}'
    assert_success
    assert_match '1'
    BACON_PROMPT_INFO[two]='2'
    run bacon_prompt_format_expand '#{one}#{two}'
    assert_success
    assert_match '12'
    run bacon_prompt_format_expand '#{one}xxx#{two}'
    assert_success
    assert_match '1xxx2'

    # test cmd expand
    run bacon_prompt_format_expand '#(echo 1)'
    assert_success
    assert_match '^1$'
    run bacon_prompt_format_expand '#(echo {1,2})'
    assert_success
    assert_match '^1 2$'
    run bacon_prompt_format_expand '#(echo $(echo 1))'
    assert_success
    assert_match '^1$'
    run bacon_prompt_format_expand '#(cmd-not-exist)'
    assert_success
    assert_match '^$'
    run bacon_prompt_format_expand 'x#((true)x'
    assert_success
    assert_equal 'x#((true)x' $output
    run bacon_prompt_format_expand 'x#(true))x'
    assert_success
    assert_equal 'x)x' $output

    # test color expand
    for color in "${!BACON_COLOR[@]}"; do
        run bacon_prompt_format_expand "#[$color]"
        assert_success
        assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[$color]}")"
    done

    # test mix expand
    BACON_PROMPT_INFO[test]='test'
    BACON_PROMPT_COLOR[test]='green'
    BACON_PROMPT_INFO[ONE]='ONE'
    BACON_PROMPT_COLOR[ONE]='green'
    run bacon_prompt_format_expand '0#{test}#{ONE}#(echo color)#[red]'
    assert_success
    assert_match "^0.*test.*ONE.*color.*$"
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[red]}")"
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[green]}")"

    run bacon_prompt_format_expand '#12'
    assert_success
    assert_match '^#12$'
    run bacon_prompt_format_expand '#12#{none}#'
    assert_success
    assert_match '^#12#$'
}

@test "bacon_prompt_ps1" {
    local -A BACON_PROMPT_INFO
    local -A BACON_PROMPT_COLOR
    local BACON_PROMPT_FORMAT
    BACON_PROMPT_INFO[one]="11"
    BACON_PROMPT_COLOR[one]="red"
    BACON_PROMPT_INFO[two]="#[green]22"
    BACON_PROMPT_INFO[three]='#(echo 3x3)'
    BACON_PROMPT_COLOR[three]="yellow"
    BACON_PROMPT_FORMAT='x#{one}#{two}#{three}#(echo cmd)x'
    run bacon_prompt_ps1
    assert_success
    assert_match "^x.*11.*22.*3x3.*cmdx$"
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[red]}")"
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[green]}")"
    assert_match "$(grep -oE '[0-9]+' <<<"${BACON_COLOR[yellow]}")"
}
