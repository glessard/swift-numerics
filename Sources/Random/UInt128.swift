//===--- UInt128.swift ----------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

@usableFromInline
internal struct UInt128 {
  
  @usableFromInline @inline(__always)
  internal let words: (UInt64, UInt64)
  
  @_transparent
  public var low: UInt64 { return words.0 }
  
  @_transparent
  public var high: UInt64 { return words.1 }
  
  @_transparent
  public init() {
    words.0 = 0
    words.1 = 0
  }
  
  @_transparent
  public init(_ low: UInt64, _ high: UInt64) {
    words.0 = low
    words.1 = high
  }
}

extension UInt128 {
  @_transparent
  public static func &+(a: UInt128, b: UInt128) -> UInt128 {
    let (low, carry) = a.words.0.addingReportingOverflow(b.words.0)
    let high = a.words.1 &+ b.words.1 &+ (carry ? 1 : 0)
    return UInt128(low, high)
  }
  
  @_transparent
  public static func &+=(a: inout UInt128, b: UInt128) {
    a = a &+ b
  }
  
  @_transparent
  public static func &*(a: UInt128, b: UInt128) -> UInt128 {
    var (low, high) = a.words.0.multipliedFullWidth(by: b.words.0)
    high &+= a.words.0 &* b.words.1
    high &+= a.words.1 &* b.words.0
    return UInt128(low, high)
  }
}
