//
//  InboxView.swift
//  HOTH Project
//
//  Created by 聂楚涵 on 3/1/26.
//

import SwiftUI

struct InboxViewShared: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var requestViewModel: RequestViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    @State private var selectedTab = 0
    @State private var selectedConversationId: String?
    @State private var showChat = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.uclaBlue,
                            Color.uclaDarkBlue,
                            Color.uclaGold.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 130)
                    
                    VStack(spacing: 12) {
                        Text("Message Center")
                            .font(.roboto(28, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            InboxTabButton(
                                title: "Received",
                                count: requestViewModel.receivedRequests.filter { $0.requestStatus == .pending }.count,
                                isSelected: selectedTab == 0,
                                action: { selectedTab = 0 }
                            )
                            
                            InboxTabButton(
                                title: "Sent",
                                count: nil,
                                isSelected: selectedTab == 1,
                                action: { selectedTab = 1 }
                            )
                            
                            InboxTabButton(
                                title: "Chats",
                                count: chatViewModel.conversations.filter { conv in
                                    guard let hasUnread = conv.hasUnreadMessages,
                                          hasUnread,
                                          let lastSenderId = conv.lastMessageSenderId,
                                          let currentUserId = authViewModel.user?.id else {
                                        return false
                                    }
                                    return lastSenderId != currentUserId
                                }.count,
                                isSelected: selectedTab == 2,
                                action: { selectedTab = 2 }
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 30)
                }
                
                TabView(selection: $selectedTab) {
                    ReceivedRequestsView(
                        requestViewModel: requestViewModel,
                        chatViewModel: chatViewModel,
                        onChatOpen: { convId in
                            print("🔵🔵🔵 [InboxViewShared] onChatOpen called!")
                            print("🔵 Conversation ID: \(convId)")
                            selectedConversationId = convId
                            print("🔵 selectedConversationId set to: \(selectedConversationId ?? "nil")")
                            // 切换到 Chats 标签
                            selectedTab = 2
                            print("🔵 Switched to Chats tab")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showChat = true
                                print("🔵 showChat set to: \(showChat)")
                            }
                        }
                    )
                    .tag(0)
                    
                    SentRequestsView(requestViewModel: requestViewModel)
                        .tag(1)
                    
                    ConversationsListView(
                        chatViewModel: chatViewModel,
                        onConversationSelect: { convId in
                            selectedConversationId = convId
                            showChat = true
                        }
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.uclaLightBlue.opacity(0.1),
                            Color.uclaLightGold.opacity(0.2),
                            Color.white
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: selectedConversationId.flatMap { convId in
                        ChatView(chatViewModel: chatViewModel, conversationId: convId)
                            .environmentObject(authViewModel)
                    },
                    isActive: $showChat,
                    label: { EmptyView() }
                )
                .opacity(0)
            )
            .onAppear {
                print("🔵 InboxViewShared appeared")
                guard let userId = authViewModel.user?.id else {
                    print("❌ No user ID found")
                    return
                }
                print("🔵 Fetching requests for user: \(userId)")
                requestViewModel.fetchSentRequests(userId: userId)
                requestViewModel.fetchReceivedRequests(userId: userId)
                chatViewModel.fetchConversations(userId: userId)
            }
        }
    }
}

struct InboxView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var requestViewModel = RequestViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var selectedTab = 0
    @State private var selectedConversationId: String?
    @State private var showChat = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.uclaBlue,
                            Color.uclaDarkBlue,
                            Color.uclaGold.opacity(0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(height: 130)
                    
                    VStack(spacing: 12) {
                        Text("Message Center")
                            .font(.roboto(28, weight: .bold))
                            .foregroundColor(.white)
                        
                        HStack(spacing: 0) {
                            InboxTabButton(
                                title: "Received",
                                count: requestViewModel.receivedRequests.filter { $0.requestStatus == .pending }.count,
                                isSelected: selectedTab == 0,
                                action: { selectedTab = 0 }
                            )
                            
                            InboxTabButton(
                                title: "Sent",
                                count: nil,
                                isSelected: selectedTab == 1,
                                action: { selectedTab = 1 }
                            )
                            
                            InboxTabButton(
                                title: "Chats",
                                count: nil,
                                isSelected: selectedTab == 2,
                                action: { selectedTab = 2 }
                            )
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 30)
                }
                
                TabView(selection: $selectedTab) {
                    ReceivedRequestsView(
                        requestViewModel: requestViewModel,
                        chatViewModel: chatViewModel,
                        onChatOpen: { convId in
                            selectedConversationId = convId
                            // 切换到 Chats 标签
                            selectedTab = 2
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                showChat = true
                            }
                        }
                    )
                    .tag(0)
                    
                    SentRequestsView(requestViewModel: requestViewModel)
                        .tag(1)
                    
                    ConversationsListView(
                        chatViewModel: chatViewModel,
                        onConversationSelect: { convId in
                            selectedConversationId = convId
                            showChat = true
                        }
                    )
                    .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.uclaLightBlue.opacity(0.1),
                            Color.uclaLightGold.opacity(0.2),
                            Color.white
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Hidden NavigationLink for programmatic navigation
                NavigationLink(
                    destination: selectedConversationId.map { convId in
                        ChatView(chatViewModel: chatViewModel, conversationId: convId)
                            .environmentObject(authViewModel)
                    },
                    isActive: $showChat
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .onAppear {
                guard let userId = authViewModel.user?.id else { return }
                requestViewModel.fetchSentRequests(userId: userId)
                requestViewModel.fetchReceivedRequests(userId: userId)
                chatViewModel.fetchConversations(userId: userId)
            }
        }
    }
}

struct InboxTabButton: View {
    let title: String
    let count: Int?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                HStack(spacing: 4) {
                    Text(title)
                        .font(.roboto(14, weight: isSelected ? .bold : .regular))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.7))
                    
                    if let count = count, count > 0 {
                        ZStack {
                            Circle()
                                .fill(Color.uclaGold)
                                .frame(width: 20, height: 20)
                            Text("\(count)")
                                .font(.roboto(10, weight: .bold))
                                .foregroundColor(.uclaDarkBlue)
                        }
                    }
                }
                
                Rectangle()
                    .fill(isSelected ? Color.uclaGold : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ReceivedRequestsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var requestViewModel: RequestViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    let onChatOpen: (String) -> Void
    
    var body: some View {
        ScrollView {
            if requestViewModel.receivedRequests.isEmpty {
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)
                    Image(systemName: "tray")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No requests received")
                        .font(.roboto(18, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("When someone wants to dine with you,\ntheir request will appear here")
                        .font(.roboto(13))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(requestViewModel.receivedRequests) { request in
                        ReceivedRequestCard(
                            request: request,
                            onAccept: {
                                requestViewModel.respondToRequest(
                                    requestId: request.id ?? "",
                                    accept: true,
                                    chatViewModel: chatViewModel
                                ) { convId in
                                    if let convId = convId {
                                        onChatOpen(convId)
                                    }
                                }
                            },
                            onReject: {
                                requestViewModel.respondToRequest(
                                    requestId: request.id ?? "",
                                    accept: false,
                                    chatViewModel: chatViewModel
                                ) { _ in }
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ReceivedRequestCard: View {
    let request: DiningRequest
    let onAccept: () -> Void
    let onReject: () -> Void
    
    @State private var isProcessing = false
    @State private var isAccepted = false
    @State private var isDeclined = false
    
    var body: some View {
        // 如果已经 accept 或 decline，不显示这个卡片
        if isAccepted || isDeclined {
            EmptyView()
        } else {
            cardContent
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack(spacing: 12) {
                AvatarView(username: request.fromUsername, size: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(request.fromUsername)
                        .font(.roboto(18, weight: .bold))
                        .foregroundColor(.uclaDarkBlue)
                    Text("wants to dine with you")
                        .font(.roboto(13))
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                if request.requestStatus == .pending {
                    ZStack {
                        Circle()
                            .fill(Color.uclaGold)
                            .frame(width: 12, height: 12)
                        Circle()
                            .fill(Color.uclaGold.opacity(0.3))
                            .frame(width: 20, height: 20)
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.uclaBlue)
                        .font(.system(size: 14))
                    Text(request.restaurantName)
                        .font(.roboto(15, weight: .semibold))
                        .foregroundColor(.uclaDarkBlue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.uclaLightBlue.opacity(0.1))
                .cornerRadius(10)
                
                HStack(spacing: 8) {
                    Image(systemName: "clock")
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    Text(request.timeSlot)
                        .font(.roboto(13))
                        .foregroundColor(.gray)
                }
                
                if let message = request.message, !message.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Message:")
                            .font(.roboto(12, weight: .semibold))
                            .foregroundColor(.gray)
                        Text("\"\(message)\"")
                            .font(.roboto(14))
                            .foregroundColor(.primary)
                            .italic()
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.uclaLightGold.opacity(0.15))
                    .cornerRadius(10)
                }
            }
            
            if request.requestStatus == .pending {
                HStack(spacing: 12) {
                    Button(action: {
                        print("🔵 Decline button tapped for request: \(request.id ?? "no-id")")
                        isProcessing = true
                        onReject()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isProcessing = false
                            withAnimation {
                                isDeclined = true
                            }
                        }
                    }) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .red))
                            } else {
                                Image(systemName: "xmark")
                            }
                            Text("Decline")
                        }
                        .font(.roboto(15, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(isProcessing)
                    
                    Button(action: {
                        print("🔵 Accept button tapped for request: \(request.id ?? "no-id")")
                        isProcessing = true
                        onAccept()
                        // Accept 后由 onAccept 回调处理跳转，不需要额外的动画
                    }) {
                        HStack {
                            if isProcessing {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "checkmark")
                            }
                            Text("Accept")
                        }
                        .font(.roboto(15, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.uclaBlue, Color.uclaDarkBlue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .uclaBlue.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .disabled(isProcessing)
                }
            } else {
                HStack(spacing: 8) {
                    Image(systemName: request.requestStatus == .accepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(request.requestStatus == .accepted ? .green : .red)
                    Text(request.requestStatus == .accepted ? "Accepted" : "Declined")
                        .font(.roboto(15, weight: .semibold))
                        .foregroundColor(request.requestStatus == .accepted ? .green : .red)
                }
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                Text(request.createdAt, style: .relative)
                    .font(.roboto(11))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct SentRequestsView: View {
    @ObservedObject var requestViewModel: RequestViewModel
    
    var body: some View {
        ScrollView {
            if requestViewModel.sentRequests.isEmpty {
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)
                    Image(systemName: "paperplane")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No requests sent")
                        .font(.roboto(18, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Send dining requests to connect\nwith other students")
                        .font(.roboto(13))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(requestViewModel.sentRequests) { request in
                        SentRequestCard(request: request)
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct SentRequestCard: View {
    let request: DiningRequest
    
    var statusColor: Color {
        switch request.requestStatus {
        case .pending: return .uclaGold
        case .accepted: return .green
        case .rejected: return .red
        }
    }
    
    var statusIcon: String {
        switch request.requestStatus {
        case .pending: return "clock.fill"
        case .accepted: return "checkmark.circle.fill"
        case .rejected: return "xmark.circle.fill"
        }
    }
    
    var statusText: String {
        switch request.requestStatus {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Declined"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(username: request.toUsername, size: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("To:")
                            .font(.roboto(12))
                            .foregroundColor(.gray)
                        Text(request.toUsername)
                            .font(.roboto(16, weight: .bold))
                            .foregroundColor(.uclaDarkBlue)
                    }
                    Text(request.restaurantName)
                        .font(.roboto(14))
                        .foregroundColor(.uclaBlue)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    Image(systemName: statusIcon)
                        .foregroundColor(statusColor)
                        .font(.system(size: 20))
                    Text(statusText)
                        .font(.roboto(11, weight: .semibold))
                        .foregroundColor(statusColor)
                }
            }
            
            if let message = request.message, !message.isEmpty {
                Text("\"\(message)\"")
                    .font(.roboto(13))
                    .foregroundColor(.gray)
                    .italic()
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(8)
            }
            
            HStack {
                Image(systemName: "clock")
                    .font(.system(size: 10))
                    .foregroundColor(.gray)
                Text(request.createdAt, style: .relative)
                    .font(.roboto(11))
                    .foregroundColor(.gray)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
    }
}

struct ConversationsListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @ObservedObject var chatViewModel: ChatViewModel
    let onConversationSelect: (String) -> Void
    
    var body: some View {
        ScrollView {
            if chatViewModel.conversations.isEmpty {
                VStack(spacing: 20) {
                    Spacer().frame(height: 60)
                    Image(systemName: "bubble.left.and.bubble.right")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray.opacity(0.5))
                    Text("No conversations yet")
                        .font(.roboto(18, weight: .semibold))
                        .foregroundColor(.gray)
                    Text("Accepted requests will appear here\nas active conversations")
                        .font(.roboto(13))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 15) {
                    ForEach(chatViewModel.conversations) { conversation in
                        ConversationCard(
                            conversation: conversation,
                            currentUserId: authViewModel.user?.id ?? "",
                            onTap: {
                                onConversationSelect(conversation.id ?? "")
                            }
                        )
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct ConversationCard: View {
    let conversation: Conversation
    let currentUserId: String
    let onTap: () -> Void
    
    var otherUserName: String {
        conversation.participantNames.first(where: { $0.key != currentUserId })?.value ?? "Unknown"
    }
    
    var isUnread: Bool {
        // 只有当有未读消息且最后一条消息不是当前用户发送的时候才显示未读标记
        guard let hasUnread = conversation.hasUnreadMessages,
              hasUnread,
              let lastSenderId = conversation.lastMessageSenderId else {
            return false
        }
        return lastSenderId != currentUserId
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 15) {
                ZStack(alignment: .topTrailing) {
                    AvatarView(username: otherUserName, size: 55)
                    
                    // 未读标记红点
                    if isUnread {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 2)
                            )
                            .offset(x: 4, y: -4)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(otherUserName)
                        .font(.roboto(17, weight: isUnread ? .bold : .semibold))
                        .foregroundColor(.uclaDarkBlue)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 11))
                            .foregroundColor(.uclaBlue)
                        Text(conversation.restaurantName)
                            .font(.roboto(13))
                            .foregroundColor(.uclaBlue)
                    }
                    
                    if let lastMessage = conversation.lastMessage {
                        Text(lastMessage)
                            .font(.roboto(13, weight: isUnread ? .semibold : .regular))
                            .foregroundColor(isUnread ? .uclaDarkBlue : .gray)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let lastMessageTime = conversation.lastMessageTime {
                        Text(lastMessageTime, style: .relative)
                            .font(.roboto(11, weight: isUnread ? .semibold : .regular))
                            .foregroundColor(isUnread ? .uclaBlue : .gray)
                    }
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
            }
            .padding(16)
            .background(isUnread ? Color.uclaLightBlue.opacity(0.1) : Color.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(isUnread ? 0.12 : 0.08), radius: 8, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
