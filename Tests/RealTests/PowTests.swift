//===--- PowerTests.swift -------------------------------------*- swift -*-===//
//
// This source file is part of the Swift Numerics open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Numerics project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

import XCTest
import Real



internal extension ElementaryFunctions where Self: BinaryFloatingPoint {
  static func testPowCommon() {
    // If x is -1, then the result is ±1 with sign chosen by parity of n.
    // Simply converting n to Real will flip parity when n is large, so
    // first check that we get those cases right.
    XCTAssertEqual(Self.pow(-1,  0),  1)
    XCTAssertEqual(Self.pow(-1,  1), -1)
    XCTAssertEqual(Self.pow(-1, -1), -1)
    XCTAssertEqual(Self.pow(-1,  2),  1)
    XCTAssertEqual(Self.pow(-1, -2),  1)
    XCTAssertEqual(Self.pow(-1,  Int.max - 1), 1)
    XCTAssertEqual(Self.pow(-1, -Int.max + 1), 1)
    XCTAssertEqual(Self.pow(-1,  Int.max), -1)
    XCTAssertEqual(Self.pow(-1, -Int.max), -1)
    XCTAssertEqual(Self.pow(-1,  Int.min),  1)
    // ±0 and ±infinity are similar.
    sanityCheck( .infinity, Self.pow(-0,  Int.min))
    sanityCheck(-.infinity, Self.pow(-0, -Int.max))
    sanityCheck( .infinity, Self.pow(-0, -2))
    sanityCheck(-.infinity, Self.pow(-0, -1))
    sanityCheck( 1,         Self.pow(-0,  0))
    sanityCheck(-0,         Self.pow(-0,  1))
    sanityCheck( 0,         Self.pow(-0,  2))
    sanityCheck( 0,         Self.pow(-0,  Int.max-1))
    sanityCheck(-0,         Self.pow(-0,  Int.max))
  }
}

extension Float {
  static func testPow() {
    testPowCommon()
    let u = Float(1).nextUp
    let d = Float(1).nextDown
    // Smallest exponents not exactly representable as Float.
    sanityCheck(-7.3890560989306677280287919329569359, Float.pow(-u, 0x1000001))
    sanityCheck(-0.3678794082804575860056608283059288, Float.pow(-d, 0x1000001))
    // Exponents close to overflow boundary.
    sanityCheck(-3.4028231352500001570898203463449749e38, Float.pow(-u, 744261161))
    sanityCheck( 3.4028235408981285772043562848249166e38, Float.pow(-u, 744261162))
    sanityCheck(-3.4028239465463053543440887892352174e38, Float.pow(-u, 744261163))
    sanityCheck( 3.4028233551634475284795244782720072e38, Float.pow(-d, -1488522190))
    sanityCheck(-3.4028235579875369356575053576685267e38, Float.pow(-d, -1488522191))
    sanityCheck( 3.4028237608116384320940078199368685e38, Float.pow(-d, -1488522192))
    // Exponents close to underflow boundary.
    sanityCheck( 7.0064936491761438872280296737844625e-46, Float.pow(-u, -872181048))
    sanityCheck(-7.0064928139371132951305928725186420e-46, Float.pow(-u, -872181049))
    sanityCheck( 7.0064919786981822712727285793333389e-46, Float.pow(-u, -872181050))
    sanityCheck(-7.0064924138100205091278464932003585e-46, Float.pow(-d, 1744361943))
    sanityCheck( 7.0064919961905290625123586120258840e-46, Float.pow(-d, 1744361944))
    sanityCheck(-7.0064915785710625079583096856510544e-46, Float.pow(-d, 1744361945))
    // Just hammer max/min exponents, these always saturate, but this will reveal
    // errors in some implementations that one could try.
    sanityCheck( .infinity, Self.pow(-u,  Int.max - 1))
    sanityCheck( 0.0,       Self.pow(-d,  Int.max - 1))
    sanityCheck( 0.0,       Self.pow(-u, -Int.max + 1))
    sanityCheck( .infinity, Self.pow(-d, -Int.max + 1))
    sanityCheck(-.infinity, Self.pow(-u,  Int.max))
    sanityCheck(-0.0,       Self.pow(-d,  Int.max))
    sanityCheck(-0.0,       Self.pow(-u, -Int.max))
    sanityCheck(-.infinity, Self.pow(-d, -Int.max))
    sanityCheck( 0.0,       Self.pow(-u,  Int.min))
    sanityCheck( .infinity, Self.pow(-d,  Int.min))
  }
}

extension Double {
  static func testPow() {
    testPowCommon()
    // Following tests only make sense (and are only necessary) on 64b platforms.
#if arch(arm64) || arch(x86_64)
    let u: Double = 1.nextUp
    let d: Double = 1.nextDown
    // Smallest exponent not exactly representable as Double.
    sanityCheck(-7.3890560989306502272304274605750685, Double.pow(-u, 0x20000000000001))
    sanityCheck(-0.1353352832366126918939994949724833, Double.pow(-u, -0x20000000000001))
    sanityCheck(-0.3678794411714422603312898889458068, Double.pow(-d, 0x20000000000001))
    sanityCheck(-2.7182818284590456880451484776630468, Double.pow(-d, -0x20000000000001))
    // Exponents close to overflow boundary.
    sanityCheck( 1.7976931348623151738531864721534215e308, Double.pow(-u, 3196577161300664268))
    sanityCheck(-1.7976931348623155730212483790972209e308, Double.pow(-u, 3196577161300664269))
    sanityCheck( 1.7976931348623159721893102860411089e308, Double.pow(-u, 3196577161300664270))
    sanityCheck( 1.7976931348623157075547244136070910e308, Double.pow(-d, -6393154322601327474))
    sanityCheck(-1.7976931348623159071387553670790721e308, Double.pow(-d, -6393154322601327475))
    sanityCheck( 1.7976931348623161067227863205510754e308, Double.pow(-d, -6393154322601327476))
    // Exponents close to underflow boundary.
    sanityCheck( 2.4703282292062334560337346683707907e-324, Double.pow(-u, -3355781687888880946))
    sanityCheck(-2.4703282292062329075106789791206172e-324, Double.pow(-u, -3355781687888880947))
    sanityCheck( 2.4703282292062323589876232898705654e-324, Double.pow(-u, -3355781687888880948))
    sanityCheck(-2.4703282292062332640976590913373022e-324, Double.pow(-d, 6711563375777760775))
    sanityCheck( 2.4703282292062329898361312467121758e-324, Double.pow(-d, 6711563375777760776))
    sanityCheck(-2.4703282292062327155746034020870799e-324, Double.pow(-d, 6711563375777760777))
    // Just hammer max/min exponents, these always saturate, but this will reveal
    // errors in some implementations that one could try.
    sanityCheck( .infinity, Self.pow(-u,  Int.max - 1))
    sanityCheck( 0.0,       Self.pow(-d,  Int.max - 1))
    sanityCheck( 0.0,       Self.pow(-u, -Int.max + 1))
    sanityCheck( .infinity, Self.pow(-d, -Int.max + 1))
    sanityCheck(-.infinity, Self.pow(-u,  Int.max))
    sanityCheck(-0.0,       Self.pow(-d,  Int.max))
    sanityCheck(-0.0,       Self.pow(-u, -Int.max))
    sanityCheck(-.infinity, Self.pow(-d, -Int.max))
    sanityCheck( 0.0,       Self.pow(-u,  Int.min))
    sanityCheck( .infinity, Self.pow(-d,  Int.min))
#endif
  }
}

final class PowTests: XCTestCase {
  
  func testFloat() {
    Float.testPow()
  }
  
  func testDouble() {
    Double.testPow()
  }
  
  #if (arch(i386) || arch(x86_64)) && !os(Windows) && !os(Android)
  func testFloat80() {
    Float80.testPowCommon()
  }
  #endif
}
