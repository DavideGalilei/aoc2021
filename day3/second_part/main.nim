import os
import tables
import strutils
import sequtils

proc solution(filename: string): int =
    var
        lines = filename.lines.toSeq()
        oxygenNumbers = lines
            .filterIt(it.strip() != "")
            .map(parseBinInt)
        co2Numbers = oxygenNumbers

    let length = len(lines[0])

    for shift in countdown(length - 1, 0):
        let
            oxygenCount = oxygenNumbers.mapIt((it shr shift) and 1).toCountTable()
            mostCommon = if oxygenCount[0] == oxygenCount[1]: 1 else: oxygenCount.largest()[0]

            co2Count = co2Numbers.mapIt((it shr shift) and 1).toCountTable()
            lessCommon = if co2Count[0] == co2Count[1]: 0 else: co2Count.smallest()[0]

        oxygenNumbers = oxygenNumbers.filterIt(
            if len(oxygenNumbers) > 2: ((it shr shift) and 1) == mostCommon
            else: (it and 1) == 1
        )

        co2Numbers = co2Numbers.filterIt(
            if len(co2Numbers) > 2: ((it shr shift) and 1) == lessCommon
            else: (it and 1) == 0
        )
    
    return oxygenNumbers[0] * co2Numbers[0]

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
