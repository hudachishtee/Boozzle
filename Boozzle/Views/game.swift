import SwiftUI
import UIKit

struct BlockItem: Identifiable {
    let id = UUID()
    var shape: [[Int]]
    let color: Color
    var isPlaced: Bool = false
    
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
    }
}

let SHAPES: [[[Int]]] = [
    [[1]], [[1, 1]], [[1], [1]], [[1, 1, 1]], [[1], [1], [1]],
    [[1, 1], [1, 1]], [[1, 1, 1], [0, 1, 0]], [[1, 1, 0], [0, 1, 1]],
    [[0, 1, 1], [1, 1, 0]], [[1, 0], [1, 0], [1, 1]], [[0, 1], [0, 1], [1, 1]]
]

struct Game: View {
    var onWin: () -> Void = {}
    @Binding var shouldPopToRoot: Bool
    
    @Environment(\.dismiss) var dismiss
    @State private var showSettings = false
    
    private let brandPurple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let brandOrange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    private let colorShuffle = Color(red: 0x41/255, green: 0x22/255, blue: 0x5C/255)
    private let colorRotate  = Color(red: 0xF7/255, green: 0xCC/255, blue: 0x59/255)
    private let colorBomb    = Color(red: 0xA9/255, green: 0x3A/255, blue: 0x4E/255)
    private let boardBackground = Color(red: 0.95, green: 0.92, blue: 0.88)
    private let emptyCellColor = Color(white: 0.9, opacity: 0.6)
    private let pieceColors: [Color] = [
        Color(red: 247/255, green: 204/255, blue: 89/255),
        Color(red: 65/255, green: 35/255, blue: 92/255),
        Color(red: 176/255, green: 65/255, blue: 82/255)
    ]
    
    let rows = 10; let cols = 10
    
    @State private var grid: [[Color?]] = Array(repeating: Array(repeating: nil, count: 10), count: 10)
    @State private var hand: [BlockItem] = []
    @State private var score: Int = 0
    @State private var isGameOver = false
    @State private var isGameWon = false
    @State private var levelProgress: Double = 0.0
    @State private var progressShuffle: Double = 1.0
    @State private var progressRotate: Double = 1.0
    @State private var progressBomb: Double = 1.0
    @State private var isBombActive: Bool = false
    @State private var isRotateActive: Bool = false
    @State private var gridFrame: CGRect = .zero
    @State private var cellSize: CGFloat = 0
    
    init(onWin: @escaping () -> Void = {}, shouldPopToRoot: Binding<Bool> = .constant(false)) {
        self.onWin = onWin
        self._shouldPopToRoot = shouldPopToRoot
        _hand = State(initialValue: Game.generateHand(colors: [
            Color(red: 247/255, green: 204/255, blue: 89/255),
            Color(red: 65/255, green: 35/255, blue: 92/255),
            Color(red: 176/255, green: 65/255, blue: 82/255)
        ]))
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                LinearGradient(colors: [brandPurple, brandOrange], startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Button(action: { showSettings = true }) {
                            Image("settings").resizable().aspectRatio(contentMode: .fit).frame(width: 44, height: 44).shadow(radius: 3)
                        }
                        Spacer()
                    }.padding(.horizontal, 20).padding(.top, 10)
                    
                    HStack(spacing: 10) {
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.black.opacity(0.3)).frame(height: 20)
                            Capsule()
                                .fill(LinearGradient(colors: [.white, .yellow], startPoint: .leading, endPoint: .trailing))
                                .frame(width: max(0, (geo.size.width * 0.7) * levelProgress), height: 20)
                                .animation(.spring(), value: levelProgress)
                        }
                        .frame(maxWidth: .infinity)
                        Image("ghostie").resizable().aspectRatio(contentMode: .fit).frame(width: 55, height: 55)
                    }.padding(.horizontal, 30).padding(.top, 5).padding(.bottom, 20)
                    
                    HStack(spacing: 30) {
                        PowerUpButton(iconName: "shuffle", color: colorShuffle, progress: progressShuffle, isActive: false, action: activateShuffle)
                        PowerUpButton(iconName: "rotate", color: colorRotate, progress: progressRotate, isActive: isRotateActive, action: { isRotateActive.toggle(); isBombActive = false })
                        PowerUpButton(iconName: "bomb", color: colorBomb, progress: progressBomb, isActive: isBombActive, action: { isBombActive.toggle(); isRotateActive = false })
                    }.padding(.bottom, 20)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 12).fill(boardBackground).shadow(color: .black.opacity(0.3), radius: 10, y: 5)
                        VStack(spacing: 2) {
                            ForEach(0..<rows, id: \.self) { r in
                                HStack(spacing: 2) {
                                    ForEach(0..<cols, id: \.self) { c in
                                        Rectangle().fill(grid[r][c] ?? emptyCellColor).cornerRadius(2)
                                    }
                                }
                            }
                        }.padding(8)
                            .background(GeometryReader { boardGeo -> Color in
                                DispatchQueue.main.async {
                                    self.gridFrame = boardGeo.frame(in: .global)
                                    self.cellSize = (gridFrame.width - 16) / CGFloat(cols)
                                }
                                return Color.clear
                            })
                    }.aspectRatio(1, contentMode: .fit).padding(.horizontal, 20)
                    
                    Spacer()
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 25).fill(Color.black.opacity(0.2)).frame(height: 100).padding(.horizontal, 10)
                        HStack(spacing: 25) {
                            ForEach(hand.indices, id: \.self) { index in
                                if !hand[index].isPlaced {
                                    DraggableBlock(
                                        block: hand[index], cellSize: 30, gridCellSize: cellSize,
                                        isBombMode: isBombActive, isRotateMode: isRotateActive,
                                        onDragEnd: { location in handleDrop(index: index, location: location) },
                                        onTap: { handleTap(index: index) }
                                    )
                                } else { Color.clear.frame(width: 90, height: 90) }
                            }
                        }
                    }.frame(height: 140).padding(.bottom, 20)
                }
                
                if isGameWon || isGameOver {
                    PuzzleResultView(
                        didWin: isGameWon,
                        resetAction: { resetGame() },
                        successAction: {
                            onWin()
                            shouldPopToRoot = false
                        }
                    )
                    .transition(.opacity).zIndex(100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showSettings) {
            SettingsSheetView(
                isMainMenu: false,
                resetAction: { showSettings = false; resetGame() },
                exitAction: { showSettings = false; dismiss() }
            )
            .presentationBackground(brandPurple)
            .interactiveDismissDisabled()
        }
    }
    
    static func generateHand(colors: [Color]) -> [BlockItem] {
        var newHand: [BlockItem] = []
        for _ in 0..<3 { newHand.append(BlockItem(shape: SHAPES.randomElement()!, color: colors.randomElement()!)) }
        return newHand
    }
    
    func activateShuffle() {
        if progressShuffle >= 1.0 {
            withAnimation {
                for i in 0..<hand.count {
                    if !hand[i].isPlaced { hand[i] = BlockItem(shape: SHAPES.randomElement()!, color: pieceColors.randomElement()!) }
                }
                progressShuffle = 0.0; if checkLoss() { isGameOver = true }
            }
        }
    }
    
    func handleTap(index: Int) {
        if isRotateActive && progressRotate >= 1.0 {
            withAnimation(.spring()) { hand[index].rotate(); progressRotate = 0.0; isRotateActive = false }
        }
    }
    
    func handleDrop(index: Int, location: CGPoint) {
        let shape = hand[index].shape
        let blockRows = shape.count; let blockCols = shape[0].count
        let offsetX = (CGFloat(blockCols) * cellSize) / 2
        let offsetY = (CGFloat(blockRows) * cellSize) / 2
        let relativeX = location.x - gridFrame.minX - offsetX
        let relativeY = location.y - gridFrame.minY - offsetY
        let c = Int(round(relativeX / cellSize)); let r = Int(round(relativeY / cellSize))
        if isBombActive {
            if progressBomb >= 1.0 && r >= -1 && r <= rows && c >= -1 && c <= cols {
                triggerBomb(row: r + (blockRows/2), col: c + (blockCols/2))
                hand[index].isPlaced = true; isBombActive = false; progressBomb = 0.0; checkRefill()
            }
        } else {
            if canPlace(shape: shape, row: r, col: c) {
                placeBlock(shape: shape, color: hand[index].color, row: r, col: c)
                hand[index].isPlaced = true; checkLines(); checkRefill()
            }
        }
    }
    
    func triggerBomb(row: Int, col: Int) {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        withAnimation(.easeIn(duration: 0.1)) {
            for i in -1...1 { for j in -1...1 {
                let tr = row + i; let tc = col + j
                if tr >= 0 && tr < rows && tc >= 0 && tc < cols { grid[tr][tc] = nil }
            }}
        }
    }
    
    func canPlace(shape: [[Int]], row: Int, col: Int) -> Bool {
        for (rowIndex, rowArr) in shape.enumerated() {
            for (colIndex, val) in rowArr.enumerated() {
                if val == 1 {
                    let targetR = row + rowIndex; let targetC = col + colIndex
                    if targetR < 0 || targetR >= rows || targetC < 0 || targetC >= cols { return false }
                    if grid[targetR][targetC] != nil { return false }
                }
            }
        }
        return true
    }
    
    func placeBlock(shape: [[Int]], color: Color, row: Int, col: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            for (rowIndex, rowArr) in shape.enumerated() {
                for (colIndex, val) in rowArr.enumerated() {
                    if val == 1 { grid[row + rowIndex][col + colIndex] = color }
                }
            }
        }
        score += 10
    }
    
    func checkLines() {
        var rowsToClear: [Int] = []; var colsToClear: [Int] = []
        for r in 0..<rows { if grid[r].compactMap({$0}).count == cols { rowsToClear.append(r) } }
        for c in 0..<cols {
            var isFull = true; for r in 0..<rows { if grid[r][c] == nil { isFull = false; break } }
            if isFull { colsToClear.append(c) }
        }
        if !rowsToClear.isEmpty || !colsToClear.isEmpty {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.easeOut(duration: 0.2)) {
                for r in rowsToClear { for c in 0..<cols { grid[r][c] = nil } }
                for c in colsToClear { for r in 0..<rows { grid[r][c] = nil } }
            }
            let lines = rowsToClear.count + colsToClear.count
            score += lines * 100; levelProgress += Double(lines) / 6.0
            if levelProgress >= 1.0 { isGameWon = true }
        }
    }
    
    func checkRefill() {
        if hand.allSatisfy({ $0.isPlaced }) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                hand = Game.generateHand(colors: pieceColors)
                if checkLoss() { isGameOver = true }
            }
        } else { if checkLoss() { isGameOver = true } }
    }
    
    func checkLoss() -> Bool {
        if progressBomb >= 1.0 || progressShuffle >= 1.0 { return false }
        for block in hand where !block.isPlaced {
            var possible = false
            for r in 0..<rows { for c in 0..<cols {
                if canPlace(shape: block.shape, row: r, col: c) { possible = true; break }
                if progressRotate >= 1.0 {
                    var rotatedBlock = block; rotatedBlock.rotate()
                    if canPlace(shape: rotatedBlock.shape, row: r, col: c) { possible = true; break }
                }
            }
            if possible { break } }
            if possible { return false }
        }
        return true
    }
    
    func resetGame() {
        grid = Array(repeating: Array(repeating: nil, count: rows), count: cols)
        score = 0; levelProgress = 0.0; progressShuffle = 1.0; progressRotate = 1.0; progressBomb = 1.0
        isGameOver = false; isGameWon = false; hand = Game.generateHand(colors: pieceColors)
    }
}

struct PowerUpButton: View {
    let iconName: String; let color: Color; let progress: Double; let isActive: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle().stroke(color.opacity(0.3), lineWidth: 5).frame(width: 60, height: 60)
                Circle().fill(isActive ? color : color.opacity(progress >= 1.0 ? 0.9 : 0.3)).frame(width: 50, height: 50)
                    .overlay(Image(iconName).resizable().renderingMode(.template).frame(width: 25, height: 25).foregroundColor(.white))
            }
        }.disabled(progress < 1.0)
    }
}

struct DraggableBlock: View {
    let block: BlockItem, cellSize: CGFloat, gridCellSize: CGFloat, isBombMode: Bool, isRotateMode: Bool
    let onDragEnd: (CGPoint) -> Void, onTap: () -> Void
    @State private var offset: CGSize = .zero; @State private var isDragging: Bool = false
    var currentCellSize: CGFloat { isDragging && gridCellSize > 0 ? gridCellSize : cellSize }
    var body: some View {
        VStack(spacing: 2) {
            ForEach(0..<block.shape.count, id: \.self) { r in
                HStack(spacing: 2) {
                    ForEach(0..<block.shape[r].count, id: \.self) { c in
                        if block.shape[r][c] == 1 {
                            Rectangle().fill(isBombMode && isDragging ? .white : block.color).frame(width: currentCellSize, height: currentCellSize).cornerRadius(4)
                        } else { Color.clear.frame(width: currentCellSize, height: currentCellSize) }
                    }
                }
            }
        }
        .offset(offset).onTapGesture { onTap() }
        .gesture(DragGesture(coordinateSpace: .global).onChanged { val in isDragging = true; offset = val.translation }.onEnded { val in onDragEnd(val.location); offset = .zero; isDragging = false })
        .zIndex(isDragging ? 100 : 1)
    }
}

struct SettingsSheetView: View {
    @Environment(\.dismiss) var dismissSheet
    var isMainMenu: Bool = false
    var resetAction: () -> Void = {}
    var exitAction: () -> Void = {}
    
    private let bgPurple = Color(red: 0x41/255, green: 0x23/255, blue: 0x5C/255)
    private let bgOrange = Color(red: 0xC2/255, green: 0x4D/255, blue: 0x32/255)
    private let cardPurple = Color(red: 0x58/255, green: 0x2A/255, blue: 0x54/255)
    private let iconGold = Color(red: 0xF2/255, green: 0xC8/255, blue: 0x4B/255)

    var body: some View {
        ZStack {
            LinearGradient(colors: [bgPurple, bgOrange], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Settings")
                    .font(.custom("Arial-Black", size: 32))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.5), radius: 4, y: 2)
                    .padding(.top, 40)
                
                VStack(spacing: 18) {
                    SettingsRow(title: "Sound", imageAsset: "sound", goldColor: iconGold, shadowColor: .orange)
                    
                    if !isMainMenu {
                        SettingsRow(title: "Restart", imageAsset: "restart", goldColor: iconGold, shadowColor: .orange, action: resetAction)
                    }
                    
                    Divider().background(Color.white.opacity(0.2))
                    
                    HStack {
                        Text("Credits").font(.custom("Arial-Black", size: 18)).foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("Assets by Freepik").font(.caption).bold().foregroundColor(iconGold)
                    }
                }
                .padding(25)
                .background(RoundedRectangle(cornerRadius: 30).fill(cardPurple.opacity(0.8)))
                .padding(.horizontal, 20)
                
                if isMainMenu {
                    SettingsBottomButton(title: "Exit", color: Color.red.opacity(0.6), action: exitAction)
                        .padding(.horizontal, 40)
                } else {
                    HStack(spacing: 15) {
                        SettingsBottomButton(title: "Exit", color: Color.red.opacity(0.6), action: exitAction)
                        SettingsBottomButton(title: "Continue", color: iconGold, action: { dismissSheet() })
                    }
                    .padding(.horizontal, 20)
                }
                
                Spacer()
            }
        }
    }
}

struct SettingsRow: View {
    let title: String; let imageAsset: String; let goldColor: Color; let shadowColor: Color
    var action: () -> Void = {}
    var body: some View {
        HStack {
            Text(title).font(.custom("Arial-Black", size: 20)).foregroundColor(.white.opacity(0.8))
            Spacer()
            Button(action: action) {
                ZStack {
                    Circle().fill(LinearGradient(colors: [goldColor, shadowColor], startPoint: .topLeading, endPoint: .bottomTrailing))
                    Image(imageAsset).resizable().aspectRatio(contentMode: .fit).frame(width: 30, height: 30)
                }.frame(width: 60, height: 60).shadow(radius: 3)
            }
        }
    }
}

struct SettingsBottomButton: View {
    let title: String; let color: Color; let action: () -> Void
    var body: some View {
        Button(action: action) {
            Text(title).font(.custom("Arial-Black", size: 20)).foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 16)
                .background(Capsule().fill(color.opacity(0.8))).overlay(Capsule().stroke(color, lineWidth: 2))
        }
    }
}
