import os
import tables
import sequtils
import heapqueue

type
    Grid = seq[seq[int]]
    Coord = object
        x, y: int
    Risk = Table[Coord, int]

func `<`(self, other: Coord): bool =
    return self.x < other.x and self.y < other.y

func `{}`(self: Risk, key: Coord): int =
    if key in self:
        return self[key]
    return int.high

func getRisk(grid: Grid, coord: Coord): int =
    return (grid[coord.x mod len(grid)][coord.y mod len(grid[0])] + coord.x div len(grid) + coord.y div len(grid[0]) - 1) mod 9 + 1

proc solution(filename: string): int =
    let grid: Grid = filename.lines
        .toSeq()
        .filterIt(it != "")
        .mapIt(it.mapIt(ord(it) - ord('0')))

    let deltas = [
        (0, 1),
        (0, -1),
        (1, 0),
        (-1, 0),
    ]

    var visit: HeapQueue[(int, Coord)]
    visit.push((0, Coord(x: 0, y: 0)))

    var risk: Risk
    risk[Coord(x: 0, y: 0)] = 0

    while visit.len != 0:
        var (r, coord) = visit.pop()

        for (dx, dy) in deltas:
            if coord.x + dx in 0 ..< len(grid) * 5 and coord.y + dy in 0 ..< len(grid[0]) * 5:
                let new_risk = r + getRisk(grid, Coord(x: coord.x + dx, y: coord.y + dy))
                if risk{Coord(x: coord.x + dx, y: coord.y + dy)} > new_risk:
                    risk[Coord(x: coord.x + dx, y: coord.y + dy)] = new_risk
                    visit.push((risk{Coord(x: coord.x + dx, y: coord.y + dy)}, Coord(x: coord.x + dx, y: coord.y + dy)))

    return risk[Coord(x: 5 * len(grid) - 1, y: 5 * len(grid[0]) - 1)]

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
