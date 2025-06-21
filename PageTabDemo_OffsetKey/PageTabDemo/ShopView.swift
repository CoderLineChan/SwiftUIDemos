//
//  ShopView.swift
//  PageTabDemo
//
//  Created by CoderChan on 2025/6/16.
//

import SwiftUI

// 商品数据结构
struct ShopItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let price: Int
    let icon: String
    let category: Category
    let description: String
    let color: Color
    
    enum Category: String, CaseIterable {
        case basic = "基础道具"
        case skins = "泡泡外观"
        case effects = "特效皮肤"
        case themes = "背景主题"
    }
}

extension ShopItem.Category {
    var color: Color {
        switch self {
        case .basic: return .blue
        case .skins: return .purple
        case .effects: return .pink
        case .themes: return .green
        }
    }
}

// 新建分类按钮子视图
struct CategoryButton: View {
    let category: ShopItem.Category
    let isSelected: Bool
    
    var body: some View {
        Text(category.rawValue)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .background(
                isSelected ? category.color.opacity(0.3) : Color.gray.opacity(0.2)
            )
            .foregroundColor(
                isSelected ? category.color : .secondary
            )
            .font(.system(size: 16, weight: .semibold))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? category.color : .clear, lineWidth: 2)
            )
    }
}


// 主商店视图
struct ShopView: View {
    @State private var selectedCategory: ShopItem.Category = .basic
    @State private var playerCredits: Int = 3500
    @State private var showSuccessAnimation = false
    @State private var purchasedItem: ShopItem?
    @State private var showPreview = false
    @State private var previewItem: ShopItem?
    
    // 商品数据
    let items: [ShopItem] = [
        // 基础道具
        ShopItem(name: "时间延长卡", price: 300, icon: "hourglass", category: .basic,
                 description: "游戏时间增加3秒", color: .blue),
        ShopItem(name: "双倍积分券", price: 500, icon: "2.circle", category: .basic,
                 description: "5秒内积分翻倍", color: .green),
        ShopItem(name: "连击保护罩", price: 600, icon: "shield", category: .basic,
                 description: "防止连击中断", color: .orange),
        
        // 泡泡外观
        ShopItem(name: "动物系列", price: 600, icon: "pawprint", category: .skins,
                 description: "熊猫/猫咪/兔子", color: .brown),
        ShopItem(name: "节日限定", price: 800, icon: "gift", category: .skins,
                 description: "圣诞/春节/万圣节", color: .red),
        ShopItem(name: "镭射幻彩", price: 1000, icon: "sparkles", category: .skins,
                 description: "流光渐变效果", color: .purple),
        
        // 特效皮肤
        ShopItem(name: "星云爆破", price: 900, icon: "star", category: .effects,
                 description: "星系旋转破碎", color: .indigo),
        ShopItem(name: "烟花庆典", price: 1200, icon: "fireworks", category: .effects,
                 description: "多色烟花绽放", color: .pink),
        ShopItem(name: "彩虹粒子", price: 700, icon: "rainbow", category: .effects,
                 description: "七彩粒子飞溅", color: .mint),
        
        // 背景主题
        ShopItem(name: "海底世界", price: 700, icon: "water.waves", category: .themes,
                 description: "动态游鱼+气泡", color: .cyan),
        ShopItem(name: "宇宙星空", price: 950, icon: "moon.stars", category: .themes,
                 description: "旋转星云+流星", color: .black),
        ShopItem(name: "童话森林", price: 550, icon: "tree", category: .themes,
                 description: "萤火虫+发光植物", color: .green)
    ]
    
    // 当前分类的商品
    var filteredItems: [ShopItem] {
        items.filter { $0.category == selectedCategory }
    }
    
    // 分类按钮视图
    @ViewBuilder
    func categoryButtons() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(ShopItem.Category.allCases, id: \.self) { category in
                            Button(action: {
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }) {
                                CategoryButton(
                                    category: category,
                                    isSelected: selectedCategory == category
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 5)
    }
    
    // 商店顶部栏
    var shopHeader: some View {
        HStack {
            // 返回按钮
            Button(action: {}) {
                Image(systemName: "arrow.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(10)
                    .background(Color.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
            
            Spacer()
            
            // 商店标题
            Text("解压商店")
                .font(.title2.weight(.heavy))
                .foregroundColor(Color(UIColor.systemIndigo))
            
            Spacer()
            
            // 积分显示
            VStack(alignment: .trailing) {
                Text("积分")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(playerCredits)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(UIColor.systemOrange))
            }
            .padding(10)
            .background(Color.secondary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(.horizontal)
        .padding(.bottom, 5)
    }
    
    var body: some View {
        ZStack {
            // 主界面
            VStack(spacing: 0) {
                shopHeader
                categoryButtons()
                
                // 商品网格
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 20), count: 2), spacing: 25) {
                        ForEach(filteredItems) { item in
                            ShopItemView(item: item, credits: playerCredits) {
                                purchaseItem(item)
                            } previewAction: {
                                previewItem = item
                                showPreview = true
                            }
                        }
                    }
                    .padding(20)
                }
                .background(Color(UIColor.systemGroupedBackground))
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(UIColor.systemIndigo).opacity(0.05), .clear]),
                    startPoint: .top, endPoint: .bottom
                )
            )
            
            // 购买成功动画
            if showSuccessAnimation, let item = purchasedItem {
                SuccessAnimationView(item: item)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            showSuccessAnimation = false
                        }
                    }
            }
        }
        .overlay(
            // 积分随机获取小游戏
            BubbleBonusGame(credits: $playerCredits)
                .frame(width: 150, height: 150)
                .offset(x: 120, y: 300)
        )
        .sheet(isPresented: $showPreview) {
            if let previewItem = previewItem {
                ItemPreviewView(item: previewItem)
            }
        }
        .navigationBarHidden(true)
    }
    
    // 购买商品方法
    private func purchaseItem(_ item: ShopItem) {
        guard playerCredits >= item.price else {
            // 积分不足反馈
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            return
        }
        
        // 扣减积分
        playerCredits -= item.price
        purchasedItem = item
        
        // 购买成功反馈
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // 显示成功动画
        withAnimation(.spring()) {
            showSuccessAnimation = true
        }
        
        // 保存购买记录 (实际应用中这里应该持久化数据)
        print("已购买: \(item.name)")
    }
}

// 单个商品视图
struct ShopItemView: View {
    let item: ShopItem
    let credits: Int
    var buyAction: () -> Void
    var previewAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 商品图标和预览
            ZStack(alignment: .topTrailing) {
                Image(systemName: item.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [item.color, item.color.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: item.color.opacity(0.5), radius: 10, x: 0, y: 5)
                    )
                
                // 预览按钮
                Button(action: previewAction) {
                    Image(systemName: "eye")
                        .font(.system(size: 14))
                        .padding(7)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .foregroundColor(item.color)
                }
                .padding(8)
            }
            
            // 商品名称
            Text(item.name)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            // 商品描述
            Text(item.description)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(height: 35, alignment: .top)
            
            // 购买按钮
            Button(action: buyAction) {
                HStack {
                    Text("\(item.price)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(credits >= item.price ? .yellow : .white)
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(credits >= item.price ? .yellow : .white)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(credits >= item.price ? item.color : Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(credits < item.price)
            .padding(.top, 5)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(UIColor.secondarySystemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(UIColor.systemFill), lineWidth: 1)
        )
        .padding(2)
    }
}

// 成功购买动画视图
struct SuccessAnimationView: View {
    let item: ShopItem
    
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    @State private var particles: [CGPoint] = []
    
    var body: some View {
        ZStack {
            // 主要动画效果
            ZStack {
                Image(systemName: item.icon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .padding(30)
                    .background(item.color)
                    .clipShape(Circle())
                    .scaleEffect(scale)
                    .shadow(radius: 20)
                    .opacity(1 - opacity)
                
                // 粒子效果
                ForEach(0..<particles.count, id: \.self) { index in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .position(particles[index])
                        .opacity(opacity)
                }
            }
            .background(VisualEffectView(style: .systemUltraThinMaterial))
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .shadow(radius: 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                scale = 1.2
            }
            
            withAnimation(.easeIn(duration: 1.0).delay(0.4)) {
                opacity = 1
                scale = 0.5
                generateParticles()
            }
        }
    }
    
    private func generateParticles() {
        particles = (0..<15).map { _ in
            CGPoint(
                x: CGFloat.random(in: 50...200),
                y: CGFloat.random(in: 50...200)
            )
        }
    }
}

// 小积分奖励游戏
struct BubbleBonusGame: View {
    @Binding var credits: Int
    
    @State private var bubbles: [CGPoint] = []
    @State private var timer: Timer?
    
    var body: some View {
        ZStack {
            // 小气泡
            ForEach(0..<bubbles.count, id: \.self) { index in
                BubbleView(position: bubbles[index])
                    .onTapGesture {
                        credits += Int.random(in: 5...50)
                        bubbles.remove(at: index)
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
            }
        }
        .onAppear(perform: startGame)
        .onDisappear(perform: stopGame)
    }
    
    private func startGame() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            if bubbles.count < 3 {
                withAnimation(.spring()) {
                    bubbles.append(
                        CGPoint(x: CGFloat.random(in: 0...150),
                                y: CGFloat.random(in: 0...150))
                    )
                }
            }
        }
    }
    
    private func stopGame() {
        timer?.invalidate()
        timer = nil
    }
}

// 气泡视图
struct BubbleView: View {
    let position: CGPoint
    
    var body: some View {
        Circle()
            .fill(LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .frame(width: 30, height: 30)
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .position(position)
            .shadow(radius: 5)
            .transition(.opacity.combined(with: .scale))
    }
}

// 商品预览视图
struct ItemPreviewView: View {
    let item: ShopItem
    
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 20) {
                Image(systemName: item.icon)
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .padding(40)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [item.color, item.color.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                
                Text(item.name)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(item.color)
                
                Text(item.description)
                    .font(.system(size: 18))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
            }
            
            HStack(spacing: 20) {
                Button(action: {}) {
                    HStack {
                        Text("试用")
                            .font(.system(size: 18, weight: .semibold))
                        Image(systemName: "play.circle")
                    }
                    .frame(width: 120)
                    .padding(15)
                    .background(Color.green.opacity(0.1))
                    .foregroundColor(.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Button(action: {}) {
                    HStack {
                        Text("购买")
                            .font(.system(size: 18, weight: .bold))
                        Text("\(item.price)")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "star.fill")
                    }
                    .frame(width: 150)
                    .padding(15)
                    .background(item.color)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
    }
}

// 模糊效果视图
struct VisualEffectView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}

// 预览
struct ShopView_Previews: PreviewProvider {
    static var previews: some View {
        ShopView()
            .preferredColorScheme(.light)
        
        ShopView()
            .preferredColorScheme(.dark)
    }
}
