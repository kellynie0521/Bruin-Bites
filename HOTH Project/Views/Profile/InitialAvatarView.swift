//
//  InitialAvatarView.swift
//  HOTH Project
//
//  Created by Assistant
//

import SwiftUI

struct InitialAvatarView: View {
    let username: String
    let size: CGFloat
    
    private var initial: String {
        String(username.prefix(1).uppercased())
    }
    
    private var backgroundColor: Color {
        // 根据用户名生成一致的颜色
        let colors: [Color] = [
            .uclaBlue,
            .uclaGold,
            .uclaDarkBlue,
            Color(red: 0.3, green: 0.6, blue: 0.9),  // 浅蓝
            Color(red: 0.9, green: 0.6, blue: 0.3),  // 橙色
            Color(red: 0.6, green: 0.4, blue: 0.8),  // 紫色
            Color(red: 0.4, green: 0.7, blue: 0.5),  // 绿色
            Color(red: 0.9, green: 0.4, blue: 0.5),  // 粉红
        ]
        
        // 使用用户名的哈希值来选择颜色（确保同一用户名总是得到相同颜色）
        let hash = abs(username.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            backgroundColor,
                            backgroundColor.opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: size, height: size)
            
            Text(initial)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// 或者使用 Emoji 头像
struct EmojiAvatarView: View {
    let username: String
    let size: CGFloat
    
    private var emoji: String {
        let emojis = [
            "🐻", "🦁", "🐯", "🦊", "🐼", "🐨", "🐸", "🐵",
            "🦄", "🐙", "🦋", "🐝", "🐞", "🌸", "🌺", "🌻",
            "🌈", "⭐️", "✨", "🔥", "💫", "🌟", "🎨", "🎭",
            "🎪", "🎨", "🎯", "🎲", "🎸", "🎺", "🎷", "🎹"
        ]
        
        // 使用用户名的哈希值来选择 emoji
        let hash = abs(username.hashValue)
        return emojis[hash % emojis.count]
    }
    
    private var backgroundColor: Color {
        let colors: [Color] = [
            Color(red: 0.95, green: 0.95, blue: 0.97),
            Color(red: 0.97, green: 0.95, blue: 0.95),
            Color(red: 0.95, green: 0.97, blue: 0.95),
            Color(red: 0.97, green: 0.97, blue: 0.95),
            Color(red: 0.95, green: 0.95, blue: 0.99),
        ]
        
        let hash = abs(username.hashValue)
        return colors[hash % colors.count]
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: size, height: size)
            
            Text(emoji)
                .font(.system(size: size * 0.5))
        }
    }
}

// 混合模式：字母 + 背景色
struct AvatarView: View {
    let username: String
    let size: CGFloat
    let useEmoji: Bool = false  // 切换为 true 使用 emoji
    
    var body: some View {
        if useEmoji {
            EmojiAvatarView(username: username, size: size)
        } else {
            InitialAvatarView(username: username, size: size)
        }
    }
}
