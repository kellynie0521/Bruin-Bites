//
//  ChatView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct ChatView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    
    let conversationId: String
    @State private var messageText = ""
    @State private var scrollProxy: ScrollViewProxy?
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages area
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        // Welcome message
                        if chatViewModel.messages.isEmpty {
                            VStack(spacing: 15) {
                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 60, height: 60)
                                    .foregroundColor(.uclaBlue.opacity(0.3))
                                    .padding(.top, 40)
                                
                                Text("Start your conversation!")
                                    .font(.roboto(16, weight: .medium))
                                    .foregroundColor(.gray)
                                
                                Text("Say hi to your dining buddy 👋")
                                    .font(.roboto(14))
                                    .foregroundColor(.gray.opacity(0.7))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        }
                        
                        ForEach(chatViewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == authViewModel.user?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                    .padding(.bottom, 8)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.uclaLightBlue.opacity(0.05),
                            Color.white,
                            Color.uclaLightGold.opacity(0.05)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .onAppear {
                    scrollProxy = proxy
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    scrollToBottom(proxy: proxy)
                }
            }
            
            Divider()
            
            // Input area
            HStack(alignment: .bottom, spacing: 12) {
                // Text input with multiline support
                ZStack(alignment: .leading) {
                    if messageText.isEmpty {
                        Text("Message...")
                            .font(.roboto(16))
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.leading, 16)
                            .padding(.top, 12)
                    }
                    
                    TextField("", text: $messageText, axis: .vertical)
                        .font(.roboto(16))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .lineLimit(1...5)
                        .submitLabel(.send)
                        .onSubmit {
                            sendMessage()
                        }
                }
                .background(Color(.systemGray6))
                .cornerRadius(22)
                .overlay(
                    RoundedRectangle(cornerRadius: 22)
                        .stroke(Color.uclaBlue.opacity(0.2), lineWidth: 1)
                )
                
                // Send button
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(sendButtonGradient)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .animation(.easeInOut(duration: 0.2), value: messageText.isEmpty)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .padding(.bottom, 0) // 移除额外的底部 padding，让系统自动处理
            .background(
                Color(.systemBackground)
                    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: -2)
            )
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text(getOtherUserName())
                        .font(.roboto(17, weight: .semibold))
                        .foregroundColor(.uclaDarkBlue)
                }
            }
        }
        .onAppear {
            chatViewModel.fetchMessages(conversationId: conversationId)
            // 标记对话为已读
            chatViewModel.markConversationAsRead(conversationId: conversationId)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom) // 让键盘正确推动内容
    }
    
    private func sendMessage() {
        let trimmedText = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        guard let user = authViewModel.user else { return }
        
        chatViewModel.sendMessage(
            conversationId: conversationId,
            senderId: user.id ?? "",
            senderName: user.username,
            text: trimmedText
        )
        
        messageText = ""
        
        // Scroll to bottom after sending
        if let proxy = scrollProxy, let lastMessage = chatViewModel.messages.last {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let lastMessage = chatViewModel.messages.last {
            withAnimation(.easeOut(duration: 0.3)) {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
    
    private func getOtherUserName() -> String {
        // Get conversation details from chatViewModel if needed
        return "Chat"
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private var sendButtonGradient: LinearGradient {
        if messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return LinearGradient(
                gradient: Gradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [Color.uclaBlue, Color.uclaDarkBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if isCurrentUser {
                Spacer(minLength: 60)
            } else {
                // Avatar for other user
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.uclaBlue.opacity(0.6), Color.uclaLightBlue]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(message.senderName.prefix(1).uppercased())
                            .font(.roboto(14, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                // Sender name for other user
                if !isCurrentUser {
                    Text(message.senderName)
                        .font(.roboto(11, weight: .semibold))
                        .foregroundColor(.uclaDarkBlue.opacity(0.7))
                        .padding(.leading, 4)
                }
                
                // Message bubble
                HStack {
                    Text(message.text)
                        .font(.roboto(15))
                        .foregroundColor(isCurrentUser ? .white : .black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(messageBubbleBackground)
                        .cornerRadius(18)
                        .contextMenu {
                            Button(action: {
                                UIPasteboard.general.string = message.text
                            }) {
                                Label("Copy", systemImage: "doc.on.doc")
                            }
                        }
                }
            }
            
            if !isCurrentUser {
                Spacer(minLength: 60)
            } else {
                // Check mark for sent messages
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.uclaBlue.opacity(0.6))
                    .padding(.bottom, 2)
            }
        }
        .padding(.vertical, 2)
    }
    
    private var messageBubbleBackground: some View {
        Group {
            if isCurrentUser {
                LinearGradient(
                    gradient: Gradient(colors: [Color.uclaBlue, Color.uclaDarkBlue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .shadow(color: .uclaBlue.opacity(0.3), radius: 3, x: 0, y: 2)
            } else {
                Color.white
                    .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
            }
        }
    }
}
