import os
import bitops
import strutils

type
    BitStream = object
        left: seq[uint8]
        pos: int

    Kind = enum
        Literal, Operation

    Expression = object
        case typeId: Kind
        of Literal:
            value: int
        of Operation:
            discard
        version: int
        subpackets: seq[Expression]

func hexToInt(c: char): uint8 =
    let x = if c in '0' .. '9': ord(c) - ord('0')
    else: ord(c) - ord('A') + 10
    return x.uint8

# func atEnd(self: BitStream): bool {.inline.} = self.pos >= self.left.len

proc read(self: var BitStream, bits: int): int =
    if (bits and 0xFFFF) == 0: return 0
    
    for i in 0 ..< bits:
        result = result shl 1 or int(self.left[self.pos])
        inc self.pos

proc toBitStream(source: string): BitStream =
    for c in source:
        var tmp = hexToInt(c)
        for i in countdown(3, 0):
            result.left.add tmp shr i and 0b1

proc sumVersions(tree: Expression): int =
    inc result, tree.version
    for children in tree.subpackets:
        inc result, sumVersions(children)

proc parse(bits: var BitStream): Expression =
    result = Expression(
        version: bits.read(3),
        typeId: if bits.read(3) == 4: Literal else: Operation,
    )

    if result.typeId == Literal:
        while true:
            let number = bits.read(5)
            # echo number.toBin(5)
            result.value = (result.value shl 4) or (number and 0b01111)
            if not number.testBit(4): # Checks 0b10000
                return
    else:
        # Operator
        let lengthTypeId = bits.read(1)
        if lengthTypeId == 0:
            let length = bits.read(15)
            let oldPos = bits.pos
            while bits.pos != (oldPos + length):
                result.subpackets.add(bits.parse())
        else:
            let subpacketsCount = bits.read(11)
            for i in 0 ..< subpacketsCount:
                result.subpackets.add(bits.parse())

proc solution(filename: string): int =
    var bits = filename.readFile().strip().toBitStream()
    return parse(bits).sumVersions()

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
