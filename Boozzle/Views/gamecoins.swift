import SwiftUI

// MARK: - Data Models

struct CoinGridCell {
    let color: Color
    var hasCoin: Bool
}

struct CoinBlockItem: Identifiable {
    let id = UUID()
    var shape: [[Int]]
    let color: Color
    var isPlaced: Bool = false
    
    // Stores the exact coordinate (row, col) of the coin within this block
    var coinPosition: (r: Int, c: Int)? = nil
    
    mutating func rotate() {
        let rows = shape.count
        let cols = shape[0].count
        var newShape = Array(repeating: Array(repeating: 0, count: rows), count: cols)
        
        for r in 0..<rows {
            for c in 0..<cols {
                newShape[c][rows - 1 - r] = shape[r][c]
            }
        }
        self.shape = newShape
        
        // Rotate the coin position to match the new shape
        if let pos = coinPosition {
            self.coinPosition = (r: pos.c, c: rows - 1 - pos.r)
        }
    }
}

// MARK: - Shape Definitions
let COIN_SHAPES: [[[Int]]] = [
    [[1]], [[1, 1]], [[1], [1]], [[1, 1, 1]], [[1], [1], [1]],
    [[1, 1], [1, 1]], [[1, 1, 1], [0, 1, 0]], [[1, 1, 0], [0, 1, 1]],
    [[0, 1, 1], [1, 1, 0]], [[1, 0], [1, 0], [1, 1]], [[0, 1], [0, 1], [1, 1]]
]

struct GameCoins: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var vm: UpgradeVM
    
    // MARK: - Brand Colors
    private let brandPurple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let brandOrange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    
    private let colorShuffle = Color(red: 0x41/255, green: 0x22/255, blue: 0x5C/255)
    private let colorRotate  = Color(red: 0xF7/255, green: 0xCC/255, blue: 0x59/255)
    private let colorBomb    = Color(red: 0xA9/255, green: 0x3A/255, blue: 0x4E/255)
    
    private let boardBackground = Color(red: 0.95, green: 0.92, blue: 0.88)
    private let emptyCellColor = Color(white: 0.9, opacity: 0.6)
    
    static let pieceColors: [Color] = [
        Color(red: 247/255, green: 204/255, blue: 89/255),
        Color(red: 65/255, green: 35/255, blue: 92/255),
        Color(red: 176/255, green: 65/255, blue: 82/255)
    ]
    
    let rows = 10
    let cols = 10
    
    // MARK: - Game State
    @State private var grid: [[CoinGridCell?]] = Array(repeating: Array(repeating: nil, count: 10), count: 10)
    @State private var hand: [CoinBlockItem] = []
    @State private var collectedCoins: Int = 0
    @State private var isGameOver = false
    
    @State private var progressShuffle: Double = 1.0
    @State private var progressRotate: Double = 1.0
    @State private var progressBomb: Double = 1.0
    
    @State private var isBombActive: Bool = false
    @State private var isRotateActive: Bool = false
    
    @State private var gridFrame: CGRect = .zero
    @State private var cellSize: CGFloat = 0
    
    // Settings Sheet State
    @State private var showSettings = false
    
    init() {
        _hand = State(initialValue: GameCoins.generateHand(colors: GameCoins.pieceColors))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [brandPurple, brandOrange], startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    headerView
                    powerUpsRow
                    gridView
                    Spacer()
                    handView
                }
                
                if isGameOver {
                    gameOverView
                        .zIndex(20)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView(
                isMainMenu: false,
                resetAction: {
                    saveCoinsAndReset() // Save coins before restarting
                    showSettings = false
                },
                exitAction: {
                    saveCoinsAndExit() // Save coins before exiting
                    showSettings = false
                }
            )
            .presentationBackground(brandPurple)
            .interactiveDismissDisabled()
        }
    }
    
    // MARK: - UI Components
    
    private var headerView: some View {
        HStack {
            Button(action: { showSettings = true }) {
                Image("settings")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 44, height: 44)
                    .shadow(radius: 3)
            }
            Spacer()
            VStack(spacing: 2) {
                Image("coin")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 35, height: 35)
                    .shadow(radius: 2)
                
                Text("\(collectedCoins)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundColor(.white)
            }
            Spacer()
            // Placeholder to balance the layout
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
    
    private var powerUpsRow: some View {
        HStack(spacing: 30) {
            CoinPowerButton(iconName: "shuffle", color: colorShuffle, progress: progressShuffle, isActive: false, action: activateShuffle)
            CoinPowerButton(iconName: "rotate", color: colorRotate, progress: progressRotate, isActive: isRotateActive, action: { isRotateActive.toggle(); isBombActive = false })
            CoinPowerButton(iconName: "bomb", color: colorBomb, progress: progressBomb, isActive: isBombActive, action: { isBombActive.toggle(); isRotateActive = false })
        }
        .padding(.bottom, 20)
    }
    
    private var gridView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(boardBackground)
                .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            
            VStack(spacing: 2) {
                ForEach(0..<rows, id: \.self) { r in
                    HStack(spacing: 2) {
                        ForEach(0..<cols, id: \.self) { c in
                            CoinBoardCellView(cell: grid[r][c], emptyColor: emptyCellColor)
                        }
                    }
                }
            }
            .padding(8)
            .background(GeometryReader { boardGeo -> Color in
                DispatchQueue.main.async {
                    self.gridFrame = boardGeo.frame(in: .global)
                    self.cellSize = (gridFrame.width - 16) / CGFloat(cols)
                }
                return Color.clear
            })
        }
        .aspectRatio(1, contentMode: .fit)
        .padding(.horizontal, 20)
    }
    
    private var handView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.black.opacity(0.2))
                .frame(height: 100)
                .padding(.horizontal, 10)
            
            HStack(spacing: 25) {
                ForEach(hand.indices, id: \.self) { index in
                    if !hand[index].isPlaced {
                        CoinDraggableBlock(
                            block: hand[index],
                            cellSize: 30,
                            gridCellSize: cellSize,
                            isBombActive: isBombActive,
                            isRotateActive: isRotateActive,
                            onDragEnd: { location in
                                handleDrop(index: index, location: location)
                            },
                            onTap: { handleTap(index: index) }
                        )
                    } else {
                        Color.clear.frame(width: 90, height: 90)
                    }
                }
            }
        }
        .frame(height: 140)
        .padding(.bottom, 20)
    }
    
    private var gameOverView: some View {
        ZStack {
            Color.black.opacity(0.7).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("GAME OVER").font(.largeTitle).fontWeight(.heavy).foregroundColor(.white)
                
                Text("You Earned:")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Image("coin").resizable().frame(width: 30, height: 30)
                    Text("\(collectedCoins)").font(.largeTitle).fontWeight(.bold).foregroundColor(.yellow)
                }
                
                Button(action: {
                    saveCoinsAndReset()
                }) {
                    Text("Play Again")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Capsule().fill(Color.white))
                        .foregroundColor(brandPurple)
                }
                
                Button(action: {
                    saveCoinsAndExit()
                }) {
                    Text("Collect & Exit")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Capsule().fill(brandOrange))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    // MARK: - Logic
    
    // Helper to save coins before exiting
    func saveCoinsAndExit() {
        vm.addCoins(collectedCoins)
        dismiss()
    }
    
    // Helper to save coins before resetting
    func saveCoinsAndReset() {
        vm.addCoins(collectedCoins)
        resetGame()
    }
    
    static func generateHand(colors: [Color]) -> [CoinBlockItem] {
        var newHand: [CoinBlockItem] = []
        for _ in 0..<3 {
            var block = CoinBlockItem(shape: COIN_SHAPES.randomElement()!, color: colors.randomElement()!)
            
            // Probability of 20% to have a coin
            if Double.random(in: 0...1) < 0.20 {
                var validSpots: [(Int, Int)] = []
                for r in 0..<block.shape.count {
                    for c in 0..<block.shape[r].count {
                        if block.shape[r][c] == 1 {
                            validSpots.append((r, c))
                        }
                    }
                }
                if let spot = validSpots.randomElement() {
                    block.coinPosition = spot
                }
            }
            newHand.append(block)
        }
        return newHand
    }
    
    func activateShuffle() {
        if progressShuffle >= 1.0 {
            withAnimation {
                var newItems = GameCoins.generateHand(colors: GameCoins.pieceColors)
                for i in 0..<hand.count {
                    if !hand[i].isPlaced {
                        hand[i] = newItems[i]
                    }
                }
                progressShuffle = 0.0
            }
        }
    }
    
    func handleTap(index: Int) {
        if isRotateActive && progressRotate >= 1.0 {
            withAnimation(.spring()) {
                hand[index].rotate()
                progressRotate = 0.0
                isRotateActive = false
            }
        }
    }
    
    func handleDrop(index: Int, location: CGPoint) {
        let shape = hand[index].shape
        let blockRows = shape.count
        let blockCols = shape[0].count
        let offsetX = (CGFloat(blockCols) * cellSize) / 2
        let offsetY = (CGFloat(blockRows) * cellSize) / 2
        let relativeX = location.x - gridFrame.minX - offsetX
        let relativeY = location.y - gridFrame.minY - offsetY
        let c = Int(round(relativeX / cellSize))
        let r = Int(round(relativeY / cellSize))
        
        if isBombActive {
            if progressBomb >= 1.0 && r >= -1 && r <= rows && c >= -1 && c <= cols {
                triggerBomb(row: r + (blockRows/2), col: c + (blockCols/2))
                hand[index].isPlaced = true
                isBombActive = false
                progressBomb = 0.0
                checkRefill()
            }
        } else {
            if canPlace(shape: shape, row: r, col: c) {
                placeBlock(block: hand[index], row: r, col: c)
                hand[index].isPlaced = true
                checkLines()
                checkRefill()
            }
        }
    }
    
    func triggerBomb(row: Int, col: Int) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation {
            for i in -1...1 {
                for j in -1...1 {
                    let tr = row + i, tc = col + j
                    if tr >= 0 && tr < rows && tc >= 0 && tc < cols { grid[tr][tc] = nil }
                }
            }
        }
    }
    
    func canPlace(shape: [[Int]], row: Int, col: Int) -> Bool {
        for (ri, rowArr) in shape.enumerated() {
            for (ci, val) in rowArr.enumerated() where val == 1 {
                let tr = row + ri, tc = col + ci
                if tr < 0 || tr >= rows || tc < 0 || tc >= cols || grid[tr][tc] != nil { return false }
            }
        }
        return true
    }
    
    func placeBlock(block: CoinBlockItem, row: Int, col: Int) {
        withAnimation(.spring()) {
            for (ri, rowArr) in block.shape.enumerated() {
                for (ci, val) in rowArr.enumerated() where val == 1 {
                    var cellHasCoin = false
                    if let pos = block.coinPosition, pos.r == ri, pos.c == ci {
                        cellHasCoin = true
                    }
                    grid[row + ri][col + ci] = CoinGridCell(color: block.color, hasCoin: cellHasCoin)
                }
            }
        }
    }
    
    func checkLines() {
        var rClear: [Int] = [], cClear: [Int] = []
        for r in 0..<rows where grid[r].compactMap({$0}).count == cols { rClear.append(r) }
        for c in 0..<cols {
            var full = true
            for r in 0..<rows where grid[r][c] == nil { full = false; break }
            if full { cClear.append(c) }
        }
        
        if !rClear.isEmpty || !cClear.isEmpty {
            var coinsCollected = 0
            for r in rClear { for c in 0..<cols where grid[r][c]?.hasCoin == true { coinsCollected += 1 } }
            for c in cClear { for r in 0..<rows where !rClear.contains(r) && grid[r][c]?.hasCoin == true { coinsCollected += 1 } }
            
            // ✅ Updates collection (50 per coin)
            collectedCoins += (coinsCollected * 50)
            
            withAnimation {
                for r in rClear { for c in 0..<cols { grid[r][c] = nil } }
                for c in cClear { for r in 0..<rows { grid[r][c] = nil } }
            }
        }
    }
    
    func checkRefill() {
        if hand.allSatisfy({ $0.isPlaced }) {
            hand = GameCoins.generateHand(colors: GameCoins.pieceColors)
        }
        if checkLoss() { isGameOver = true }
    }
    
    func checkLoss() -> Bool {
        if progressBomb >= 1.0 || progressShuffle >= 1.0 { return false }
        for block in hand where !block.isPlaced {
            for r in 0..<rows {
                for c in 0..<cols where canPlace(shape: block.shape, row: r, col: c) { return false }
            }
        }
        return true
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: nil, count: 10), count: 10)
        collectedCoins = 0
        progressShuffle = 1.0; progressRotate = 1.0; progressBomb = 1.0
        isGameOver = false
        hand = GameCoins.generateHand(colors: GameCoins.pieceColors)
    }
}

// MARK: - Subviews

struct CoinBoardCellView: View {
    let cell: CoinGridCell?
    let emptyColor: Color
    var body: some View {
        ZStack {
            Rectangle().fill(cell?.color ?? emptyColor).cornerRadius(2)
            if cell?.hasCoin == true {
                Image("coin").resizable().padding(4)
            }
        }
    }
}

struct CoinPowerButton: View {
    let iconName: String, color: Color, progress: Double, isActive: Bool, action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().stroke(color.opacity(0.3), lineWidth: 5).frame(width: 60, height: 60)
                Circle().fill(isActive ? color : color.opacity(progress >= 1.0 ? 0.9 : 0.3)).frame(width: 50, height: 50)
                    .overlay(Image(iconName).resizable().renderingMode(.template).frame(width: 25, height: 25).foregroundColor(.white))
            }
        }
        .disabled(progress < 1.0)
    }
}

struct CoinDraggableBlock: View {
    let block: CoinBlockItem, cellSize: CGFloat, gridCellSize: CGFloat
    let isBombActive: Bool, isRotateActive: Bool
    let onDragEnd: (CGPoint) -> Void, onTap: () -> Void
    @State private var offset: CGSize = .zero
    @State private var isDragging: Bool = false
    var currentSize: CGFloat { isDragging ? gridCellSize : cellSize }
    
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<block.shape.count, id: \.self) { r in
                HStack(spacing: 2) {
                    ForEach(0..<block.shape[r].count, id: \.self) { c in
                        if block.shape[r][c] == 1 {
                            CoinBlockCellView(
                                color: block.color,
                                size: currentSize,
                                isBomb: isBombActive,
                                isDrag: isDragging,
                                isRotate: isRotateActive,
                                hasCoin: (block.coinPosition?.r == r && block.coinPosition?.c == c)
                            )
                        } else {
                            Color.clear.frame(width: currentSize, height: currentSize)
                        }
                    }
                }
            }
        }
        .offset(offset)
        .onTapGesture { onTap() }
        .gesture(DragGesture(coordinateSpace: .global).onChanged { isDragging = true; offset = $0.translation }.onEnded { onDragEnd($0.location); offset = .zero; isDragging = false })
    }
}

struct CoinBlockCellView: View {
    let color: Color, size: CGFloat, isBomb: Bool, isDrag: Bool, isRotate: Bool, hasCoin: Bool
    var body: some View {
        ZStack {
            Rectangle().fill(isBomb && isDrag ? .white : color).frame(width: size, height: size).cornerRadius(4)
            if hasCoin { Image("coin").resizable().frame(width: size * 0.6, height: size * 0.6) }
            if isRotate && !isDrag { Image(systemName: "arrow.triangle.2.circlepath").foregroundColor(.white).font(.caption) }
        }
    }
}

// MARK: - Preview Fix

struct GameCoins_Previews: PreviewProvider {
    static var previews: some View {
        GameCoins()
            .environmentObject(UpgradeVM()) // Inject VM for preview
    }
}
