// SPDX-License-Identifier: Apache-2.0
#if !SKIP_BRIDGE
import Foundation

/// Pure-Swift **Code 128** barcode encoder (Code Set B).
///
/// Produces the bar/space pattern for an ASCII string so it can be rendered with
/// any drawing primitive (SwiftUI `Canvas`, `Path`, a bitmap, …). This works
/// identically on iOS and Android because it has no platform dependencies.
///
/// ```swift
/// if let bars = Code128.encode("12345678-01") {
///     // bars: [Bool] — true = black bar, false = white space (1 module each)
/// }
/// ```
public enum Code128 {

    /// Encodes an ASCII string using Code 128 **Code Set B** (printable ASCII 32–126).
    ///
    /// - Parameter data: The string to encode.
    /// - Returns: A module-level pattern where `true` is a black bar and `false`
    ///   a white space (each element is one module wide), including the start,
    ///   checksum and stop symbols. Returns `nil` if `data` contains a character
    ///   outside the Code Set B range.
    public static func encode(_ data: String) -> [Bool]? {
        // Work on UTF-8 bytes + plain Int arithmetic so the encoder transpiles
        // cleanly to Kotlin (Unicode.Scalar / Character ops don't).
        let bytes = Array(data.utf8)
        var bars: [Bool] = []

        // START B (104)
        bars.append(contentsOf: pattern(104))
        var checksum = 104

        for index in 0..<bytes.count {
            let value = Int(bytes[index]) - 32
            if value < 0 || value > 95 { return nil }
            bars.append(contentsOf: pattern(value))
            checksum += value * (index + 1)
        }

        // Checksum symbol
        checksum = checksum % 103
        bars.append(contentsOf: pattern(checksum))

        // STOP (106)
        bars.append(contentsOf: pattern(106))
        return bars
    }

    /// Returns true if every character of `data` can be encoded with Code Set B.
    public static func canEncode(_ data: String) -> Bool {
        for byte in Array(data.utf8) {
            let value = Int(byte)
            if value < 32 || value > 126 { return false }
        }
        return true
    }

    private static func pattern(_ index: Int) -> [Bool] {
        var result: [Bool] = []
        for byte in Array(patternStrings[index].utf8) {
            result.append(Int(byte) == 49) // '1'
        }
        return result
    }

    /// The canonical Code 128 symbol table (107 symbols, 11 modules each; the
    /// stop symbol is 13 modules). Index = symbol value.
    private static let patternStrings: [String] = [
        "11011001100", "11001101100", "11001100110", "10010011000", "10010001100",
        "10001001100", "10011001000", "10011000100", "10001100100", "11001001000",
        "11001000100", "11000100100", "10110011100", "10011011100", "10011001110",
        "10111001100", "10011101100", "10011100110", "11001110010", "11001011100",
        "11001001110", "11011100100", "11001110100", "11101101110", "11101001100",
        "11100101100", "11100100110", "11101100100", "11100110100", "11100110010",
        "11011011000", "11011000110", "11000110110", "10100011000", "10001011000",
        "10001000110", "10110001000", "10001101000", "10001100010", "11010001000",
        "11000101000", "11000100010", "10110111000", "10110001110", "10001101110",
        "10111011000", "10111000110", "10001110110", "11101110110", "11010001110",
        "11000101110", "11011101000", "11011100010", "11011101110", "11101011000",
        "11101000110", "11100010110", "11101101000", "11101100010", "11100011010",
        "11101111010", "11001000010", "11110001010", "10100110000", "10100001100",
        "10010110000", "10010000110", "10000101100", "10000100110", "10110010000",
        "10110000100", "10011010000", "10011000010", "10000110100", "10000110010",
        "11000010010", "11001010000", "11110111010", "11000010100", "10001111010",
        "10100111100", "10010111100", "10010011110", "10111100100", "10011110100",
        "10011110010", "11110100100", "11110010100", "11110010010", "11011011110",
        "11011110110", "11110110110", "10101111000", "10100011110", "10001011110",
        "10111101000", "10111100010", "11110101000", "11110100010", "10111011110",
        "10111101110", "11101011110", "11110101110", "11010000100", "11010010000",
        "11010011100", "1100011101011",
    ]
}
#endif
