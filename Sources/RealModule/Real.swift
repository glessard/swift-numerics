//===--- Real.swift -------------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

/// A type that models the real numbers.
///
/// Types conforming to this protocol provide the arithmetic and utility operations defined by
/// the `FloatingPoint` protocol, and provide all of the math functions defined by the
/// `ElementaryFunctions` and `RealFunctions` protocols. This protocol does not
/// add any additional conformances itself, but is very useful as a protocol against which to
/// write generic code. For example, we can naturally write a generic version of the a sigmoid
/// function:
/// ```
/// func sigmoid<T: Real>(_ x: T) -> T {
///   return 1/(1 + .exp(-x))
/// }
/// ```
/// See Also:
/// -
/// - `ElementaryFunctions`
/// - `RealFunctions`
/// - `AlgebraicField`
public protocol Real: FloatingPoint, RealFunctions, AlgebraicField {
}

//  While `Real` does not provide any additional customization points,
//  it does allow us to default the implementation of a few operations,
//  and also provides `signGamma`.
extension Real {
  
  @_transparent
  public static func cos(piTimes x: Self) -> Self {
    // Cosine is even, so all we need is the magnitude.
    let x = x.magnitude
    // If x is not finite, the result is nan.
    guard x.isFinite else { return .nan }
    // If x is finite and at least .radix / .ulpOfOne, it is an even
    // integer, which means that cos(piTimes: x) is 1.0
    if x >= Self(Self.radix) / .ulpOfOne { return 1 }
    // Break x up as x = n/2 + f where n is an integer. In binary, the
    // following computation is always exact, and trivially gives the
    // correct result.
    // TODO: analyze and fixup for decimal types
    let n = (2*x).rounded(.toNearestOrEven)
    let f = x.addingProduct(-1/2, n)
    // Because cosine is 2π-periodic, we don't actually care about
    // most of n; we only need the two least significant bits of n
    // represented as an integer:
    let quadrant = n._lowWord & 0x3
    switch quadrant {
    case 0: return  cos(.pi * f)
    case 1: return -sin(.pi * f)
    case 2: return -cos(.pi * f)
    case 3: return  sin(.pi * f)
    default: fatalError()
    }
  }
  
  @_transparent
  public static func sin(piTimes x: Self) -> Self {
    // If x is not finite, the result is nan.
    guard x.isFinite else { return .nan }
    // If x.magnitude is finite and at least 1 / .ulpOfOne, it is an
    // integer, which means that sin(piTimes: x) is ±0.0
    if x.magnitude >= 1 / .ulpOfOne {
      return Self(signOf: x, magnitudeOf: 0)
    }
    // Break x up as x = n/2 + f where n is an integer. In binary, the
    // following computation is always exact, and trivially gives the
    // correct result.
    // TODO: analyze and fixup for decimal types
    let n = (2*x).rounded(.toNearestOrEven)
    let f = x.addingProduct(-1/2, n)
    // Because sine is 2π-periodic, we don't actually care about
    // most of n; we only need the two least significant bits of n
    // represented as an integer:
    let quadrant = n._lowWord & 0x3
    switch quadrant {
    case 0: return  sin(.pi * f)
    case 1: return  cos(.pi * f)
    case 2: return -sin(.pi * f)
    case 3: return -cos(.pi * f)
    default: fatalError()
    }
  }
  
  @_transparent
  public static func tan(piTimes x: Self) -> Self {
    // If x is not finite, the result is nan.
    guard x.isFinite else { return .nan }
    // TODO: choose policy for exact 0, 1, infinity cases and implement as
    // appropriate.
    // If x.magnitude is finite and at least .radix / .ulpOfOne, it is an
    // even integer, which means that sin(piTimes: x) is ±0.0 and
    // cos(piTimes: x) is 1.0.
    if x.magnitude >= Self(Self.radix) / .ulpOfOne {
      return Self(signOf: x, magnitudeOf: 0)
    }
    // Break x up as x = n/2 + f where n is an integer. In binary, the
    // following computation is always exact, and trivially gives the
    // correct result.
    // TODO: analyze and fixup for decimal types
    let n = (2*x).rounded(.toNearestOrEven)
    let f = x.addingProduct(-1/2, n)
    // Because tangent is π-periodic, we don't actually care about
    // most of n; we only need the least significant bit of n represented
    // as an integer:
    let sector = n._lowWord & 0x1
    switch sector {
    case 0: return    tan(.pi * f)
    case 1: return -1/tan(.pi * f)
    default: fatalError()
    }
  }
  
  @_transparent
  public static func exp10(_ x: Self) -> Self {
    return pow(10, x)
  }
  
  #if !os(Windows)
  public static func signGamma(_ x: Self) -> FloatingPointSign {
    // Gamma is strictly positive for x >= 0.
    if x >= 0 { return .plus }
    // For negative x, we arbitrarily choose to assign a sign of .plus to the
    // poles.
    let integralPart = x.rounded(.towardZero)
    if x == integralPart { return .plus }
    // Otherwise, signGamma is .minus if the integral part of x is even.
    return integralPart.isEven ? .minus : .plus
  }
  
  //  Determines if this value is even, assuming that it is an integer.
  @inline(__always)
  private var isEven: Bool {
    if Self.radix == 2 {
      // For binary types, we can just check if x/2 is an integer. This works
      // because x/2 is always computed exactly.
      let half = self/2
      return half == half.rounded(.towardZero)
    } else {
      // For decimal types, it's not quite that simple, because x/2 is not
      // necessarily computed exactly. As an example, suppose that we had a
      // decimal type with a one digit significand, and self = 7. Then self/2
      // would round to 4, and we would (wrongly) conclude that it was an
      // integer, and hence that self was even.
      //
      // Instead, for decimal types, we check if 2*trunc(self/2) == self,
      // using an FMA; this is always correct; this approach works for any
      // radix, but the previous method is more efficient for radix == 2.
      let half = self/2
      return self.addingProduct(-2, half.rounded(.towardZero)) == 0
    }
  }
  #endif
  
  @_transparent
  public static func sqrt(_ x: Self) -> Self {
    return x.squareRoot()
  }
  
  @inlinable
  public var reciprocal: Self? {
    let recip = 1/self
    if recip.isNormal || isZero || !isFinite {
      return recip
    }
    return nil
  }
}

// MARK: Implementation details
extension Real where Self: BinaryFloatingPoint {
  @_transparent
  public var _lowWord: UInt {
    // If magnitude is small enough, we can simply convert to Int64 and then
    // wrap to UInt.
    if magnitude < 0x1.0p63 {
      return UInt(truncatingIfNeeded: Int64(self.rounded(.down)))
    }
    precondition(isFinite)
    // Clear any bits above bit 63; the result of this expression is
    // strictly in the range [0, 0x1p64). (Note that if we had not eliminated
    // small magnitudes already, the range would include tiny negative values
    // which would then produce the wrong result; the branch above is not
    // only for performance.
    let cleared = self - 0x1p64*(self * 0x1p-64).rounded(.down)
    // Now we can unconditionally convert to UInt64, and then wrap to UInt.
    return UInt(truncatingIfNeeded: UInt64(cleared))
  }
}