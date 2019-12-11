//===--- PCG.swift --------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import Integers

@_frozen
public struct PCG128Random: RandomNumberGenerator {
  
  @usableFromInline @inline(__always)
  internal var state: UInt128
  
  @inlinable
  public init() {
    var g = SystemRandomNumberGenerator()
    let low = g.next()
    let high = g.next()
    state = UInt128(low, high)
  }
  
  @inlinable
  public init(seeds seedLow: UInt64, _ seedHigh: UInt64) {
    state = UInt128()
    step()
    state &+= UInt128(seedLow, seedHigh)
    step()
  }
  
  @usableFromInline @inline(__always)
  internal mutating func step() {
    let multiplier = UInt128(4865540595714422341, 2549297995355413924)
    let increment = UInt128(1442695040888963407, 6364136223846793005)
    state = state &* multiplier &+ increment
  }
  
  @usableFromInline @inline(__always)
  internal func output() -> UInt64 {
    let mixed = state.low ^ state.high
    let count = state.high >> 58
    return mixed.rotated(right: count)
  }
  
  @inlinable
  public mutating func next() -> UInt64 {
    let result = output()
    step()
    return result
  }
}

