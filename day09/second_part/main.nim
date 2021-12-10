import os
import math
import deques
import strutils
import sequtils
import algorithm


type
    Map = seq[seq[int]]
    Coord = object
        x, y: int

template push[T](self: Deque[T], x: T) = self.addLast(x)
template pop[T](self: Deque[T]): T = self.popLast()
template empty[T](self: Deque[T]): bool = self.len == 0

func `+`(a, b: Coord): Coord =
    result.x = a.x + b.x
    result.y = a.y + b.y

proc neighbours(self: Map, coord: Coord): seq[Coord] =
    for offset in [
        Coord(x: -1, y: 0),
        Coord(x: +1, y: 0),
        Coord(x: 0, y: -1),
        Coord(x: 0, y: +1),
    ]:
        var c = coord + offset
        if c.y in 0 ..< self.len and c.x in 0 ..< self[coord.y].len:
            result.add Coord(x: c.x, y: c.y)


template fill(self: var Map, where: Coord, with: int, queue: var Deque[Coord], until: untyped) =
    # Out of bounds check
    if where.y notin  0 ..< len(self) or where.x notin 0 ..< len(self[where.y]):
        continue

    let val {.inject.}: int = self[where.y][where.x]
    if until or val == with: # if not val == 9 or val == -1
        continue

    self[where.y][where.x] = with # fill
    queue.push(Coord(x: where.x, y: where.y))

func count(self: Map, what: int): int =
    for row in self:
        for element in row:
            if element == what:
                inc result

# Debug
import sugar
proc `$`(self: Map): string =
    return (block:
        collect newSeq:
            for row in self:
                row.mapIt(if it != -1: $it else: "+").join()
    ).join("\n")

proc solution(filename: string): int =
    let values: Map = filename.lines
        .toSeq()
        .filterIt(it != "")
        .mapIt(it.mapIt(ord(it) - ord('0')))

    var points: seq[Coord]

    for i in 0 ..< len(values):
        for j in 0 ..< len(values[i]):
            let neighbours = values.neighbours(Coord(x: j, y: i)).mapIt(values[it.y][it.x])
            # echo i, ", ", j, ", ", neighbours
            if values[i][j] < neighbours.min:
                points.add(Coord(x: j, y: i))

    var
        queue = initDeque[Coord]()
        finalFrames: seq[Map]

    for point in points:
        # echo point
        var map = values
        queue.push(point)

        while not queue.empty:
            let position = queue.pop()

            for neighbour in map.neighbours(position):
                map.fill(queue = queue,
                    where = neighbour,
                    with = -1,
                    until = (val == 9))
                # echo map, "\n"
                # Echoes a frame :)
                # I'm very proud of this solution
        
        finalFrames.add map
    
    var lengths: seq[int]
    for frame in finalFrames:
        lengths.add(frame.count(-1))
    
    # Get larger 3 frames
    lengths.sort()
    return prod(lengths[^3 .. ^1])

# Special thanks to this thread:
# https://answers.unity.com/questions/1668653/stack-overflow-with-recursive-floodfill-method.html

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
