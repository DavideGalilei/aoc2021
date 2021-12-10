import os
import sets
import macros
import tables
import strutils
import sequtils

#[
 aaaa
b    c
b    c
 dddd
e    f
e    f
 gggg
]#

proc replaceIdents(node: NimNode, name, to: string): NimNode =
    result = node
    for i in 0 ..< len(result):
        if result[i].kind == nnkIdent and eqIdent(result[i], name):
            result[i] = ident(to)
        else:
            result[i] = result[i].replaceIdents(name, to)

macro with(head: untyped, body: untyped): untyped =
    head.expectKind(nnkInfix)
    let name = head[2].strVal
    let to = head[1].strVal
    result = body.replaceIdents(name, to)

proc intersect(a, b: string): int =
    return len(a.toHashSet() * b.toHashSet())

template `*`(a, b: string): int =
    intersect(a, b)

proc solution(filename: string): int =
    let values = filename.lines
        .toSeq()
        .filterIt(it != "")
        .mapIt(it.split("|"))
        .mapIt(@[
            it[0].strip().splitWhitespace(),
            it[1].strip().splitWhitespace()])

    # len -> actual number
    const knownDigits = {
        2: 1,
        4: 4,
        3: 7,
        7: 8,
    }.toTable()

    for value in values:
        let
            numbers = value[0]
            digits = value[1]

        var patterns: Table[int, string]

        # Find 1, 4, 7, 8
        for element in numbers:
            if len(element) in knownDigits:
                patterns[knownDigits[len(element)]] = element

        with patterns as p:
            p[0] = numbers.filterIt(it.len == 6).filterIt(it * p[1] == 2 and it * p[4] == 3 and it * p[7] == 3 and it * p[8] == 6)[0]
            p[2] = numbers.filterIt(it.len == 5).filterIt(it * p[1] == 1 and it * p[4] == 2 and it * p[7] == 2 and it * p[8] == 5)[0]
            p[3] = numbers.filterIt(it.len == 5).filterIt(it * p[1] == 2 and it * p[4] == 3 and it * p[7] == 3 and it * p[8] == 5)[0]
            p[5] = numbers.filterIt(it.len == 5).filterIt(it * p[1] == 1 and it * p[4] == 3 and it * p[7] == 2 and it * p[8] == 5)[0]
            p[6] = numbers.filterIt(it.len == 6).filterIt(it * p[1] == 1 and it * p[4] == 3 and it * p[7] == 2 and it * p[8] == 6)[0]
            p[9] = numbers.filterIt(it.len == 6).filterIt(it * p[1] == 2 and it * p[4] == 4 and it * p[7] == 3 and it * p[8] == 6)[0]

        #echo "PATTERNS:: ", patterns, "\n\n"
        #echo numbers.join(" "), " | ", digits

        # Reverse key: value -> value: key
        # let inversed = patterns.pairs.toSeq().mapIt((it[1], it[0])).toTable()

        var current: int
        for digit in digits:
            let asNumber = patterns.pairs
                .toSeq()
                .filterIt(it[1].toHashSet() == digit.toHashSet())

            #echo digit, " - ", asNumber
            current *= 10
            current += asNumber[0][0]
        
        #echo "CURRENT: ", current
        inc result, current


when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
