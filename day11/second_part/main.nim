import os
import strutils
import sequtils
import std/enumerate


type
    Map = seq[seq[int]]
    Coord = object
        x, y: int

func `+`(a, b: Coord): Coord =
    result.x = a.x + b.x
    result.y = a.y + b.y

proc neighbours(self: Map, coord: Coord): seq[Coord] =
    for offset in [
        Coord(x: +1, y: 0),
        Coord(x: -1, y: 0),
        Coord(x: 0, y: +1),
        Coord(x: 0, y: -1),
        Coord(x: +1, y: +1),
        Coord(x: +1, y: -1),
        Coord(x: -1, y: +1),
        Coord(x: -1, y: -1),
    ]:
        var c = coord + offset
        if c.y in 0 ..< self.len and c.x in 0 ..< self[coord.y].len:
            result.add Coord(x: c.x, y: c.y)

# Debug
import sugar
proc `$`(self: Map): string =
    return (block:
        collect newSeq:
            for row in self:
                row.mapIt(if it != -1: $it else: "+").join()
    ).join("\n")

func shouldFlash(self: Map): bool =
    for row in self:
        for value in row:
            if value > 9:
                return true

proc inGrid(self: Map, coord: Coord): bool =
    return coord.y in 0 ..< self.len and coord.x in 0 ..< self[coord.y].len

proc flash(self: var Map) =
    for y, row in enumerate(self):
        for x, value in enumerate(row):
            if value > 9:
                for neighbour in self.neighbours(Coord(x: x, y: y)):
                    if self.inGrid(neighbour):
                        if self[neighbour.y][neighbour.x] != -1:
                            inc self[neighbour.y][neighbour.x]
                    # else: echo neighbour
                self[y][x] = -1

proc resetOctopus(self: var Map): int =
    for y, row in enumerate(self):
        for x, value in enumerate(row):
            if value == -1:
                self[y][x] = 0
                inc result

proc solution(filename: string, times: int = 200): int =
    var map: Map = filename.lines
        .toSeq()
        .filterIt(it != "")
        .mapIt(it.mapIt(ord(it) - ord('0')))

    var i: int
    var synced: bool

    while not synced:
        inc i
        # echo "\n", map

        for y, row in enumerate(map):
            for x, value in enumerate(row):
                if value != -1:
                    inc map[y][x]

        while map.shouldFlash:
            map.flash()

        if map.resetOctopus() == 100:
            return i

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
