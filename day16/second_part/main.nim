import os
import math
import tables
import bitops
import strutils
import sequtils

type
    BitStream = object
        left: seq[uint8]
        pos: int

    Kind = enum
        Literal, Operation

    OperationType = enum
        Sum, Prod, Min, Max, Invalid, Greater, Lesser, Equal

    Expression = object
        case typeId: Kind
        of Literal:
            value: int
        of Operation:
            operation: OperationType
        version: int
        subpackets: seq[Expression]

const operations = {
    Sum: proc(self: seq[int]): int = sum(self),
    Prod: proc(self: seq[int]): int = prod(self),
    Min: proc(self: seq[int]): int = min(self),
    Max: proc(self: seq[int]): int = max(self),
    Greater: proc(self: seq[int]): int =
        if self[0] > self[1]: return 1,
    Lesser: proc(self: seq[int]): int =
        if self[0] < self[1]: return 1,
    Equal: proc(self: seq[int]): int =
        if self[0] == self[1]: return 1,
}.toTable()

func hexToInt(c: char): uint8 =
    let x = if c in '0' .. '9': ord(c) - ord('0')
    else: ord(c) - ord('A') + 10
    return x.uint8

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

proc eval(tree: Expression): int =
    if tree.typeID == Literal: return tree.value
    
    return operations[tree.operation](
        tree.subpackets.map(eval)
    )

proc parse(bits: var BitStream): Expression =
    let
        version = bits.read(3)
        typeId = bits.read(3)

    result = Expression(
        version: version,
        typeId: if typeId == 4: Literal else: Operation,
    )

    if result.typeId == Literal:
        while true:
            let number = bits.read(5)
            result.value = (result.value shl 4) or (number and 0b01111)
            if not number.testBit(4): # Checks 0b10000
                return
    else:
        # Operator
        result.operation = OperationType(typeId)

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

# import json
proc solution(filename: string): int =
    var bits = filename.readFile().strip().toBitStream()
    
    let parsedTree = parse(bits)
    # echo pretty(%*(parsedTree))
    return eval(parsedTree)

when isMainModule:
    echo "Result: ", solution(currentSourcePath().parentDir / "../input.txt")
