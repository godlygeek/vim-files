if !exists(':Tabularize')
  finish " Tabular.vim wasn't loaded
endif

let s:save_cpo = &cpo
set cpo&vim

function! MakeOperatorLessThan(lines)
    let lines = a:lines
    let lines = map(lines, 'substitute(v:val, ";", "", "g")')
    let lines = map(lines, 'substitute(v:val, "\\s*$", "", "g")')
    let lines = map(lines, 'substitute(v:val, "\\s*\\([][]\\)\\s*", "\\1", "g")')
    let lines = map(lines, 'split(v:val)[-1]')
    let rv = []
    for line in lines
        let repeats = filter(split(line, '[][]'), '!empty(v:val)')
        let outlines = [ remove(repeats, 0) ]

        for repeat in repeats
            let outtmp = []
            for o in outlines
                for i in range(str2nr(repeat))
                    call add(outtmp, o . '[' . i . ']')
                endfor
            endfor
            let outlines = outtmp
        endfor

        call extend(rv, outlines)
    endfor
    let rv = map(rv, 'substitute(v:val, ".*",
                                 \ "lhs.& != rhs.& ? lhs.& < rhs.&", "")')
    let rv = map(rv, "'     : ' . v:val")
    call add(rv, '     : ' . 'false;')
    let rv[0] = substitute(rv[0], '     : ', 'return ', '')
    call tabular#TabularizeStrings(rv, '!=\|?\|<')
    return rv
endfunction

AddTabularPipeline! make_operator_less_than
    \ /[^}];/ MakeOperatorLessThan(a:lines)

let &cpo = s:save_cpo
unlet s:save_cpo
