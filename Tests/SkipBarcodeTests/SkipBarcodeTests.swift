// SPDX-License-Identifier: MIT
import XCTest
@testable import SkipBarcode

final class SkipBarcodeTests: XCTestCase {
    func testCode128EncodesKnownLength() throws {
        // START(11) + 1 data symbol(11) + checksum(11) + STOP(13) = 46 modules.
        let bars = try XCTUnwrap(Code128.encode("A"))
        XCTAssertEqual(bars.count, 11 + 11 + 11 + 13)
        // Code 128 always begins and ends with a bar.
        XCTAssertTrue(bars.first == true)
        XCTAssertTrue(bars.last == true)
    }

    func testCode128EncodesBadgeFormat() throws {
        let bars = try XCTUnwrap(Code128.encode("12345678-01"))
        // 11 chars → START + 11 data + checksum + STOP.
        XCTAssertEqual(bars.count, 11 + (11 * 11) + 11 + 13)
    }

    func testCode128RejectsNonCodeBCharacters() {
        // Characters below ASCII 32 cannot be encoded in Code Set B.
        XCTAssertNil(Code128.encode("abc\u{01}"))
        XCTAssertFalse(Code128.canEncode("\u{7F}")) // DEL (127) is out of range
        XCTAssertTrue(Code128.canEncode("Helfer 1234-56"))
    }
}
