import os
import sets
import strutils
import sequtils

type Coord = object
    x, y: int

proc fold(points: HashSet[Coord], where: Coord): HashSet[Coord] =
    for point in points:
        var point = point
        if where.x != 0 and point.x > where.x: point.x = 2 * where.x - point.x
        if where.y != 0 and point.y > where.y: point.y = 2 * where.y - point.y
        result.incl(point)

template maxitem*[T](self: HashSet[T], condition: untyped): T =
    var result: T
    
    for item {.inject.} in self:
        let last {.inject.} = result
        if condition:
            result = item
    result

proc solution(filename: string): string =
    var
        points: HashSet[Coord]
        folds: seq[Coord]

    for line in filename.lines:
        if line == "": continue
        elif line.startswith("fold"):
            let toParse = line.rsplit(maxsplit=1)[^1].split('=')
            let direction: Coord = block:
                case toParse[0]:
                    of "x": Coord(x: toParse[1].parseInt, y: 0)
                    of "y": Coord(x: 0, y: toParse[1].parseInt)
                    else: Coord(x: 0, y: 0) # Should never happen
            folds.add(direction)
        else:
            let point = line.split(',').map(parseInt)
            points.incl(Coord(x: point[0], y: point[1]))

    for fold in folds:
        points = points.fold(fold)
    
    let
        maxX = 1 + points.maxitem(item.x > last.x).x
        maxY = 1 + points.maxitem(item.y > last.y).y

    # echo maxX, " ", maxY

    var display = newSeqWith(maxY): newSeqWith[char](maxX, ' ')
    for point in points:
        display[point.y][point.x] = '#'
    
    return display.mapIt(it.join).join("\n")

when isMainModule:
    echo "Result:\n", solution(currentSourcePath().parentDir / "../input.txt")
