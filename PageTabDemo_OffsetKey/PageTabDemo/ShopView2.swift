//
//  ShopView2.swift
//  PageTabDemo
//
//  Created by CoderChan on 2025/6/16.
//

import SwiftUI


struct StoreView2: View {
    @State private var selectedCategory = 0
    @State private var showItemDetail: StoreItem? = nil
    @State private var playerCoins = 1250
    @State private var playerDiamonds = 35
    
    let categories = ["推荐", "泡泡皮肤", "游戏道具", "特效组件", "稀有装饰"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 顶部货币栏
                HStack {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                        Text("\(playerCoins)")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.95))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .foregroundColor(.blue)
                        Text("\(playerDiamonds)")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(white: 0.95))
                    .cornerRadius(20)
                    
                    Button(action: {}) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    .padding(.leading, 8)
                }
                .padding(.horizontal)
                .padding(.top, 8)
                
                // 分类选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(0..<categories.count, id: \.self) { index in
                            Button(action: {
                                withAnimation {
                                    selectedCategory = index
                                }
                            }) {
                                Text(categories[index])
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(selectedCategory == index ? Color.blue : Color(white: 0.95))
                                    .foregroundColor(selectedCategory == index ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                }
                
                // 今日特惠横幅
                if selectedCategory == 0 {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("今日特惠")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text("23:58:12")
                                .font(.caption)
                                .padding(6)
                                .background(Color.red.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(.red)
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing))
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("时间胶囊")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("+3秒游戏时间")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    HStack(spacing: 4) {
                                        Text("500")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.white)
                                        Image(systemName: "dollarsign.circle.fill")
                                            .foregroundColor(.white)
                                        
                                        Text("250")
                                            .font(.system(size: 18, weight: .bold))
                                            .strikethrough()
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .padding(.top, 4)
                                }
                                
                                Spacer()
                                
                                Image("time_capsule")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100)
                                    .shadow(radius: 10)
                            }
                            .padding()
                        }
                        .frame(height: 140)
                        .padding(.bottom, 10)
                    }
                    .padding(.horizontal)
                }
                
                // 商品网格
                ScrollView {
                    LazyVGrid(columns: [GridItem(.fixed(200)), GridItem(.fixed(200))]) {
                        ForEach(storeItems.filter {
                            selectedCategory == 0 || $0.category == categories[selectedCategory]
                        }) { item in
                            ItemCard(item: item, playerCoins: playerCoins, playerDiamonds: playerDiamonds)
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        showItemDetail = item
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("泡泡商店")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $showItemDetail) { item in
                ItemDetailView(item: item, playerCoins: playerCoins, playerDiamonds: playerDiamonds)
            }
        }
    }
}

struct ItemCard: View {
    let item: StoreItem
    let playerCoins: Int
    let playerDiamonds: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                // 商品图片
                RoundedRectangle(cornerRadius: 16)
                    .fill(item.color.opacity(0.2))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: item.icon)
                            .font(.system(size: 60))
                            .foregroundColor(item.color)
                    )
                
                // 标签
                if item.isNew {
                    Text("新品")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(8)
                } else if item.isSale {
                    Text("特惠")
                        .font(.caption)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(8)
                }
            }
            
            // 商品名称
            Text(item.name)
                .font(.system(size: 16, weight: .medium))
                .lineLimit(1)
            
            // 价格
            HStack(spacing: 4) {
                if item.priceGold > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("\(item.priceGold)")
                    }
                    .foregroundColor(playerCoins >= item.priceGold ? .blue : .gray)
                }
                
                if item.priceDiamond > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "sparkles")
                        Text("\(item.priceDiamond)")
                    }
                    .foregroundColor(playerDiamonds >= item.priceDiamond ? .blue : .gray)
                }
            }
            .font(.system(size: 14, weight: .bold))
            
            // 解锁条件
            if !item.unlockCondition.isEmpty {
                Text(item.unlockCondition)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding(10)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ItemDetailView: View {
    let item: StoreItem
    let playerCoins: Int
    let playerDiamonds: Int
    
    @Environment(\.presentationMode) var presentationMode
    @State private var previewActive = false
    
    var canAfford: Bool {
        if item.priceGold > 0 && item.priceGold <= playerCoins {
            return true
        }
        if item.priceDiamond > 0 && item.priceDiamond <= playerDiamonds {
            return true
        }
        return false
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部预览区域
            ZStack(alignment: .topLeading) {
                item.color.opacity(0.3)
                    .frame(height: 250)
                
                VStack {
                    Image(systemName: item.icon)
                        .font(.system(size: 120))
                        .foregroundColor(item.color)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            previewActive.toggle()
                        }
                    }) {
                        HStack {
                            Image(systemName: "play.circle.fill")
                            Text(previewActive ? "停止预览" : "预览效果")
                        }
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(previewActive ? Color.red : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .padding(.bottom, 20)
                    }
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            .frame(height: 250)
            
            // 详情内容
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(item.name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        HStack {
                            if item.isNew {
                                Text("新品")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            if item.isSale {
                                Text("特惠中")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.red)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    
                    Text(item.description)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("效果描述")
                            .font(.headline)
                        
                        Text(item.effect)
                            .padding(12)
                            .background(Color(white: 0.95))
                            .cornerRadius(12)
                    }
                    
                    if !item.unlockCondition.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("解锁条件")
                                .font(.headline)
                            
                            Text(item.unlockCondition)
                                .padding(12)
                                .background(Color(white: 0.95))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            
            // 底部购买栏
            HStack {
                if item.priceGold > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("\(item.priceGold)")
                    }
                    .font(.title2)
                    .foregroundColor(playerCoins >= item.priceGold ? .blue : .gray)
                    .padding(.horizontal, 16)
                }
                
                if item.priceDiamond > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("\(item.priceDiamond)")
                    }
                    .font(.title2)
                    .foregroundColor(playerDiamonds >= item.priceDiamond ? .blue : .gray)
                    .padding(.horizontal, 16)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Text(canAfford ? "立即购买" : "货币不足")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 120)
                        .background(canAfford ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .disabled(!canAfford)
            }
            .padding()
            .background(Color(.secondarySystemBackground))
        }
        .edgesIgnoringSafeArea(.top)
        .overlay(
            previewActive ? PreviewEffectOverlay(color: item.color) : nil
        )
    }
}

struct PreviewEffectOverlay: View {
    let color: Color
    
    var body: some View {
        ZStack {
            // 泡泡破碎效果
            ForEach(0..<15, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 10, height: 10)
                    .offset(x: CGFloat.random(in: -100...100),
                            y: CGFloat.random(in: -100...100))
                    .scaleEffect(CGFloat.random(in: 0.5...2))
                    .opacity(Double.random(in: 0.7...1))
                    .animation(.easeOut(duration: 0.5), value: UUID())
            }
            
            // 粒子效果
            ForEach(0..<30, id: \.self) { i in
                Circle()
                    .fill(color)
                    .frame(width: 4, height: 4)
                    .offset(x: CGFloat.random(in: -150...150),
                            y: CGFloat.random(in: -150...150))
                    .opacity(Double.random(in: 0.3...0.7))
                    .animation(.easeOut(duration: 1), value: UUID())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.3))
        .onTapGesture {
            // 点击后效果消失
        }
    }
}

// 数据模型
struct StoreItem: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let color: Color
    let description: String
    let effect: String
    let priceGold: Int
    let priceDiamond: Int
    let unlockCondition: String
    let isNew: Bool
    let isSale: Bool
}

// 示例数据
let storeItems = [
    StoreItem(
        name: "彩虹幻影皮肤",
        category: "泡泡皮肤",
        icon: "cloud.rainbow.half.fill",
        color: .purple,
        description: "泡泡破碎时产生彩虹粒子特效+水晶音效",
        effect: "每次点击泡泡会触发彩虹粒子效果，伴随清脆的水晶破裂声",
        priceGold: 1200,
        priceDiamond: 60,
        unlockCondition: "默认解锁基础皮肤",
        isNew: false,
        isSale: true
    ),
    StoreItem(
        name: "星空流光皮肤",
        category: "泡泡皮肤",
        icon: "sparkles",
        color: .blue,
        description: "深蓝底色+星光闪烁，破碎后化作流星动画",
        effect: "泡泡带有闪烁星光，破碎时化作流星划过屏幕",
        priceGold: 1200,
        priceDiamond: 0,
        unlockCondition: "累计游戏30局",
        isNew: false,
        isSale: false
    ),
    StoreItem(
        name: "软萌猫咪皮肤",
        category: "泡泡皮肤",
        icon: "cat.fill",
        color: .orange,
        description: "泡泡自带猫咪表情，破碎音效变为喵呜声",
        effect: "泡泡呈现可爱猫咪脸，破碎时发出喵呜声",
        priceGold: 1000,
        priceDiamond: 0,
        unlockCondition: "无",
        isNew: true,
        isSale: false
    ),
    StoreItem(
        name: "时间胶囊",
        category: "游戏道具",
        icon: "timer",
        color: .green,
        description: "使单局游戏时间延长至13秒",
        effect: "游戏开始时增加3秒时间，提升得分潜力",
        priceGold: 500,
        priceDiamond: 0,
        unlockCondition: "完成10次游戏",
        isNew: false,
        isSale: true
    ),
    StoreItem(
        name: "双倍得分卡",
        category: "游戏道具",
        icon: "2.circle.fill",
        color: .yellow,
        description: "10秒内点击泡泡积分×2",
        effect: "单局游戏内所有得分翻倍",
        priceGold: 600,
        priceDiamond: 30,
        unlockCondition: "单局得分破50解锁购买",
        isNew: false,
        isSale: false
    ),
    StoreItem(
        name: "黄金破碎动画",
        category: "特效组件",
        icon: "dollarsign.circle.fill",
        color: .yellow,
        description: "泡泡破碎时飞出金币特效",
        effect: "每次点击泡泡会飞出金币粒子效果",
        priceGold: 900,
        priceDiamond: 45,
        unlockCondition: "总点击数达1000",
        isNew: false,
        isSale: false
    ),
    StoreItem(
        name: "樱花雨特效包",
        category: "特效组件",
        icon: "leaf.fill",
        color: .pink,
        description: "背景飘落樱花，点击泡泡附加花瓣飞溅效果",
        effect: "游戏背景飘落樱花，点击泡泡时有花瓣飞溅",
        priceGold: 1100,
        priceDiamond: 55,
        unlockCondition: "春季限定",
        isNew: true,
        isSale: false
    ),
    StoreItem(
        name: "海底世界背景",
        category: "稀有装饰",
        icon: "water.waves",
        color: .blue,
        description: "游戏区域背景变为游动鱼群+气泡上升动态效果",
        effect: "动态海底背景，有鱼群游动和气泡上升效果",
        priceGold: 2000,
        priceDiamond: 100,
        unlockCondition: "成就系统达到银牌",
        isNew: false,
        isSale: false
    )
]

// 预览提供器
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView2()
            .preferredColorScheme(.light)
    }
}
