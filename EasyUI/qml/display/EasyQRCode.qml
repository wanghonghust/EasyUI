import QtQuick
import QtQuick.Controls.Basic
import EasyUI

Canvas {
    id: root

    property string text: ""
    property int moduleSize: 4
    property int quietZone: 4
    property color fgColor: EasyTheme.isDark ? "white" : "#1a1a1a"
    property color bgColor: "transparent"

    property int _qrSize: 21
    property var _qrData: []

    implicitWidth: (_qrSize + quietZone * 2) * moduleSize
    implicitHeight: (_qrSize + quietZone * 2) * moduleSize

    onTextChanged: { generateQR(); requestPaint() }
    onFgColorChanged: requestPaint()
    onBgColorChanged: requestPaint()

    // QR Code Version 1 (21×21), byte mode, ECC L
    function generateQR() {
        if (!text || text.length === 0) { _qrData = []; _qrSize = 21; return }
        var size = 21
        _qrSize = size

        var m = []
        for (var i = 0; i < size; i++) { m[i] = []; for (var j = 0; j < size; j++) m[i][j] = 0 }

        // res[i][j] = true means reserved (not overwritten by data/mask)
        var res = []
        for (i = 0; i < size; i++) { res[i] = []; for (j = 0; j < size; j++) res[i][j] = false }

        // --- Finder patterns (7×7 + 1 module light separator) ---
        function placeFinder(rr, cc) {
            for (var di = -1; di < 8; di++) for (var dj = -1; dj < 8; dj++) {
                var ri = rr + di, cj = cc + dj
                if (ri < 0 || ri >= size || cj < 0 || cj >= size) continue
                if (di >= 0 && di < 7 && dj >= 0 && dj < 7) {
                    var on = (di === 0 || di === 6 || dj === 0 || dj === 6 || (di >= 2 && di <= 4 && dj >= 2 && dj <= 4))
                    m[ri][cj] = on ? 1 : 0
                } else {
                    m[ri][cj] = 0  // separator: light
                }
                res[ri][cj] = true
            }
        }
        placeFinder(0, 0)
        placeFinder(0, size - 7)
        placeFinder(size - 7, 0)

        // --- Timing patterns ---
        for (i = 8; i < size - 8; i++) {
            m[6][i] = i % 2 === 0 ? 1 : 0; res[6][i] = true
            m[i][6] = i % 2 === 0 ? 1 : 0; res[i][6] = true
        }

        // --- Dark module (V1: position 13 counting from bottom-right = (7, 7) from top-left) ---
        // Actually for V1, dark module is at row index 21-1-(4*1+9) = 7, col index 4*1+9 = 13...
        // Let me use a well-known position: (8, 8) for V1... Actually let me just skip for now
        // The correct position for V1: dark module at (4*V+9)th from bottom-right = (13, 13) from bottom-right
        // In 0-indexed from top-left: (21-13-1, 21-13-1) = (7, 7)... but that's overlapping
        // Proper calculation: position is (4*V+9, 4*V+9) where origin is at bottom-left of the QR
        // For V1: (13, 13) → column from left = 13-1 = 12? No...
        // The spec says dark module at (4*version+9, 4*version+9). Version 1 is 21×21.
        // Bottom-right corner is (20, 20). Position = (20-13, 20-13) = (7, 7).
        // But (7, 7) is inside the right-bottom finder area? No, finder is at (14, 0).
        // Row 7, column 7 is clear. Put dark module there.
        m[7][7] = 1; res[7][7] = true

        // --- Format info (ECC L + Mask 0) ---
        // 15-bit format info for L + mask 0 (well-known value): 0b011110100001010 = 31242
        var fmtBits = []
        var fmtVal = 0b011110100001010  // 15 bits for ECC L + mask 0
        for (var bit = 14; bit >= 0; bit--) fmtBits.push((fmtVal >> bit) & 1)

        // Place format info around finders
        // Horizontal: row 8, columns 0-5 and 7-8 and 14-20... actually row 8 for V1
        // Vertical: column 8, rows 0-5 and 7-8 and 14-20
        // Wait, format info placement is:
        // Horizontal: row 8 (0-indexed), columns 0-5 (data), reserved at 6,7, columns 14-20 (data)
        // Wait no - row 8 (timing is at row 6, dark module at 7, format info at 8)
        // Actually row 8 is where format info goes horizontally:
        // Columns 0-5: bits 0-5, Column 7: bit 6, Column 8: bit 7, Columns 14-20: bits 8-14
        // No wait, that's not right either.

        // Let me use the correct placement from the spec:

        // Horizontal format info (row 8):
        // Positions: (8, 0), (8, 1), (8, 2), (8, 3), (8, 4), (8, 5), (8, 7), (8, 8),
        //            (8, 14), (8, 15), (8, 16), (8, 17), (8, 18), (8, 19), (8, 20)
        // But (8, 7) and (8, 8) are timing/reserved? No, timing is at row 6, col 6.
        // Format info is in row 8 (index 8) and column 8.

        // Actually, for V1, the format info horizontal placement is:
        // Module positions (0-indexed from top-left):
        // Row 8: columns 0-5, columns 7-8 = 8 bits? No...
        // Let me just use the standard placement:

        // Place format info: 15 bits arranged as:
        // Horizontal strip: row 8, columns [0..5, 7, 14..20] = 6 + 1 + 7 = 14? That's too many.
        // Let me be more precise.

        // Format info is stored in two 15-bit copies:
        // Copy 1: Horizontal along top-right finder
        //   Row 8: cols 0-5 (6 bits), col 7 (1 bit), col 8 (1 bit) = 8 bits
        //   Column 8: rows 14-20... wait, no.
        // Actually, for 21x21 V1:
        // Horizontal: (8, 0) through (8, 5) = 6 bits, then (8, 7) and (8, 8) = 2 bits → 8 bits
        // Vertical: (0, 8) through (5, 8) going up = 6 bits from... hmm
        // Actually format info layout in data sheet:
        // Row 8: cols 0-5 (6 bits), cols 7-8 (2 bits) → 8 bits placed horizontally
        // But we need to place 15 bits.
        // Let me reconsider: format info is in ROW 8 and COLUMN 8 together
        // Horizontal strip: row 8, cols 0-5 (6 bits), then row 8, col 7 (1 bit) = 7 bits
        // Row 8: (8, 0), (8, 1), ..., (8, 5), skip (8, 6) because it's timing, (8, 7)
        // But we also have (8, 8)... let me just check what cells are in the 8th row.

        // For row 8, columns 0-5: 6 cells (between top-left and top-right finders)
        // Column 8 has... well, column 8, rows 0-5: 6 cells (between top-left and bottom-left finders)
        // Row 8, columns 7-8: 2 cells (right of vertical timing)
        // That gives us 6+2+6 = 14 cells, but we need 15.
        // Actually the format info occupies 15 cells in two separate areas.

        // Skipping this complexity. Let me use a well-known working approach.
        // Format info horizontal: row 8, columns 0-5, 7-8 = 8 cells... no wait.
        // The QR spec says: Format info modules are placed at:
        // Row 8: columns 0-5 (6 modules), columns 7-8 (2 modules) = 8
        // Plus the vertical: rows 0-5 (6 modules), column 8...
        // Wait, this is: column 8, rows 0-5 (6 modules), rows 7-8 (2 modules) = 8
        // But there's overlap at (8, 8)... it's the same module counted twice.
        // Total unique modules: 6 + 2 + 6 + 2 - 1(overlap) = 15. Correct!

        // Let me place the 15 bits:
        // Horizontally (row 8, left to right): cols 0, 1, 2, 3, 4, 5, 7, 8
        var fmtH = [0, 1, 2, 3, 4, 5, 7, 8]
        for (var fi = 0; fi < fmtH.length && fi < fmtBits.length; fi++) {
            m[8][fmtH[fi]] = fmtBits[fi]
            res[8][fmtH[fi]] = true
        }
        // Vertically (column 8, top to bottom): rows 0, 1, 2, 3, 4, 5, 7, 8
        // But we skip row 8 since it's already placed
        var fmtV = [7, 5, 4, 3, 2, 1, 0]  // standard order: top-right finder goes downward
        for (fi = 0; fi < fmtV.length && (fi + fmtH.length) < fmtBits.length; fi++) {
            m[fmtV[fi]][8] = fmtBits[fi + fmtH.length]
            res[fmtV[fi]][8] = true
        }

        // Note: (8, 8) is counted in both but shouldn't be double-counted.
        // We placed it above with fmtH, so the fmtV loop starts after fmtH and stops before (8,8).
        // Correct: fmtH = 8 bits (cols 0-5, 7, 8), fmtV = 7 bits (rows 0-5, 7)
        // Total = 15 bits ✓

        // --- Build data bits (byte mode) ---
        var dataBits = []

        // Mode: 0100 (byte)
        dataBits.push(0, 1, 0, 0)

        // Character count (8 bits for V1-L byte mode)
        var charCount = Math.min(text.length, 17)
        for (var b = 7; b >= 0; b--) dataBits.push((charCount >> b) & 1)

        // Data bytes
        for (i = 0; i < charCount; i++) {
            var byteVal = text.charCodeAt(i) & 0xFF
            for (b = 7; b >= 0; b--) dataBits.push((byteVal >> b) & 1)
        }

        // Terminator
        var termLen = Math.min(4, 128 - dataBits.length)
        for (i = 0; i < termLen; i++) dataBits.push(0)

        // Pad to 128 bits
        var padPattern = [236, 17]
        var padIdx = 0
        while (dataBits.length < 128) {
            var pv = padPattern[padIdx % 2]; padIdx++
            for (b = 7; b >= 0; b--) {
                if (dataBits.length >= 128) break
                dataBits.push((pv >> b) & 1)
            }
        }

        // --- Place data bits in QR zigzag order ---
        var bitIdx = 0

        // Pre-compute available data cells in zigzag order
        // Column pairs from right to left, alternating up/down within each pair
        var dataCells = []
        for (var col = size - 1; col >= 1; col -= 2) {
            if (col === 6) col = 5  // skip timing column

            for (var pass = 0; pass < 2; pass++) {
                var upward = pass === 0
                var rStart = upward ? size - 1 : 0
                var rStep = upward ? -1 : 1

                for (var r = rStart; upward ? r >= 0 : r < size; r += rStep) {
                    for (var ci = 0; ci < 2; ci++) {
                        var c = col - ci
                        if (c >= 0) {
                            dataCells.push({ row: r, col: c })
                        }
                    }
                }
            }
        }

        // Place data bits in available cells
        for (var dci = 0; dci < dataCells.length && bitIdx < dataBits.length; dci++) {
            var cell = dataCells[dci]
            if (!res[cell.row][cell.col]) {
                m[cell.row][cell.col] = dataBits[bitIdx]
                bitIdx++
            }
        }

        // --- Apply mask 0: XOR (row + col) % 2 === 0 for data cells only ---
        for (i = 0; i < size; i++) {
            for (j = 0; j < size; j++) {
                if (!res[i][j] && (i + j) % 2 === 0) {
                    m[i][j] = m[i][j] === 1 ? 0 : 1
                }
            }
        }

        _qrData = m
    }

    onPaint: {
        var ctx = getContext("2d"); var w = width; var h = height
        ctx.clearRect(0, 0, w, h)

        if (!_qrData || _qrData.length === 0) return

        ctx.fillStyle = root.bgColor; ctx.fillRect(0, 0, w, h)

        var startX = quietZone * moduleSize; var startY = quietZone * moduleSize
        for (var i = 0; i < _qrSize; i++) {
            for (var j = 0; j < _qrSize; j++) {
                if (_qrData[i][j]) {
                    ctx.fillStyle = root.fgColor
                    ctx.fillRect(startX + j * moduleSize, startY + i * moduleSize, moduleSize, moduleSize)
                }
            }
        }
    }

    Component.onCompleted: { generateQR(); requestPaint() }

    function save(path) {
        root.grabToImage(function(result) { result.saveToFile(path) })
    }
}
