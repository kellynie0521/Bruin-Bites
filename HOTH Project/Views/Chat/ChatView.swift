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
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(chatViewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isCurrentUser: message.senderId == authViewModel.user?.id
                            )
                            .id(message.id)
                        }
                    }
                    .padding()
                }
                .onChange(of: chatViewModel.messages.count) { _ in
                    if let lastMessage = chatViewModel.messages.last {
                        withAnimation {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            HStack(spacing: 12) {
                TextField("Message", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .foregroundColor(.blue)
                }
                .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
        }
        .navigationTitle("Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            chatViewModel.fetchMessages(conversationId: conversationId)
        }
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
    }
}

struct MessageBubble: View {
    let message: Message
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.senderName)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(message.text)
                    .padding(12)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .cornerRadius(16)
                
                Text(message.timestamp, style: .time)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            if !isCurrentUser { Spacer() }
        }
    }
}
