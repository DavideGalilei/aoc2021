import os
import sugar
import strutils
import sequtils

type
    Point = object
        x, y: int

    Vector = object
        start, `end`: Point

    Canvas = seq[seq[uint8]]

proc parsePoint(source: string): Point =
    let coords = source.split(',').map(parseInt)
    return Point(x: coords[0], y: coords[1])

proc count(canvas: Canvas, element: uint8): int =
    for row in canvas:
        for number in row:
            if number > element - 1:
                inc result

proc `$`(canvas: Canvas): string =
    return (
        block: collect:
            for row in canvas:
                row.mapIt(if it != 0: $it else: "·").join("  ")
    ).join("\n")

func step(x: int): int =
    if x < 0: -1
    elif x > 0: 1
    else: 0

proc draw(canvas: var Canvas, vector: Vector, diagonals: bool = false) =
    var v: Vector = vector

    if vector.start.x == vector.`end`.x or vector.start.y == vector.`end`.y or diagonals:
        let
            x = step(vector.`end`.x - vector.start.x)
            y = step(vector.`end`.y - vector.start.y)

        while (v.start.x != v.`end`.x + x) or (v.start.y != v.`end`.y + y):
            inc canvas[v.start.y][v.start.x]
            v.start.x += x
            v.start.y += y
        # raise newException(ValueError, "a")

proc solution(filename: string): int =
    let lines: seq[Vector] = filename.lines
        .toSeq()
        .filterIt(it.strip() != "")
        .mapIt(it.split(" -> "))
        .mapIt(
            Vector(
                start: parsePoint(it[0]),
                `end`: parsePoint(it[1])
            )
        )

    const maxsize: int = 1000
    var canvas: Canvas

    # Resize
    canvas.setLen(maxsize)
    for i in 0 ..< len(canvas):
        canvas[i].setLen(maxsize)

    for vector in lines:
        canvas.draw(vector, diagonals = true)

    # echo canvas
    return canvas.count(2)

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
