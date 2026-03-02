# Main Actor 错误修复总结

## ✅ 问题描述

错误信息：
```
Main actor-isolated property 'errorMessage' can not be mutated from a Sendable closure
```

这个错误发生在 Firebase 的异步闭包（如 `addSnapshotListener`、`getDocuments`）中直接修改 `@Published` 属性时。

---

## ✅ 解决方案

### 方法 1: 使用 `Task { @MainActor in ... }`

对于在闭包中修改 UI 属性，使用：

```swift
// ❌ 错误写法
.addSnapshotListener { snapshot, error in
    if let error = error {
        self.errorMessage = error.localizedDescription  // ❌ 编译错误
        return
    }
}

// ✅ 正确写法
.addSnapshotListener { snapshot, error in
    if let error = error {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription  // ✅ 正确
        }
        return
    }
}
```

### 方法 2: 在 ViewModel 类上添加 `@MainActor`

如果整个 ViewModel 的所有方法都在主线程运行，可以在类上添加：

```swift
@MainActor
class AuthViewModel: ObservableObject {
    @Published var errorMessage = ""
    
    // 所有方法都自动在主线程运行
    func someMethod() {
        self.errorMessage = "error"  // ✅ 不需要额外包装
    }
}
```

---

## 📝 已修复的文件

### 1. ✅ MapViewModel.swift
**修复了 3 处**：
- Line 68: `fetchPosts()` 中的 `addSnapshotListener` 错误处理
- Line 112: `createPost()` 中的 geocoding 错误处理
- Line 172: `createPost()` 中的 Firestore 添加文档错误

### 2. ✅ ChatViewModel.swift
**修复了 5 处**：
- Line 30: `fetchConversations()` 中的错误处理
- Line 67: `createOrGetConversation()` 中的搜索错误
- Line 100: `createOrGetConversation()` 中的创建错误
- Line 118: `fetchMessages()` 中的错误处理
- Line 152: `sendMessage()` 中的错误处理（已用 `Task { @MainActor in }` 包装）

### 3. ✅ RequestViewModel.swift
**修复了 4 处**：
- Line 79: `fetchSentRequests()` 中的错误处理
- Line 113: `fetchReceivedRequests()` 中的错误处理
- Line 175: `acceptRequest()` 中的更新错误
- Line 197: `declineRequest()` 中的错误处理

### 4. ✅ AuthViewModel.swift
**无需修改** - 已经使用 `@MainActor` 标记整个类

---

## 🧪 测试检查清单

在运行项目前，确认：

- [x] MapViewModel 的所有 Firebase 闭包已修复
- [x] ChatViewModel 的所有 Firebase 闭包已修复
- [x] RequestViewModel 的所有 Firebase 闭包已修复
- [x] AuthViewModel 已有 `@MainActor` 标记
- [x] 编译时不再有 Main Actor 警告

---

## 🚀 验证步骤

1. 清理构建：`⌘ + Shift + K`
2. 重新构建：`⌘ + B`
3. 检查编译器输出，确认没有 Main Actor 相关错误
4. 运行应用测试功能

---

## 📚 技术说明

### 为什么会出现这个错误？

Swift 的 Concurrency 模型中，`@Published` 属性属于 Main Actor，只能在主线程修改。而 Firebase 的闭包默认在后台线程执行，直接修改会导致线程安全问题。

### `Task { @MainActor in }` 的作用

创建一个新的异步任务，确保闭包内的代码在主线程执行：

```swift
Task { @MainActor in
    // 这里的代码保证在主线程运行
    self.errorMessage = "error"
    self.posts = newPosts
}
```

### 何时使用 `@MainActor` vs `Task { @MainActor in }`

| 场景 | 解决方案 |
|------|---------|
| 整个 ViewModel 都操作 UI | 在类上添加 `@MainActor` |
| 只有部分闭包需要更新 UI | 使用 `Task { @MainActor in }` |
| async/await 函数 | 函数标记为 `@MainActor` 或在类上标记 |

---

## ✅ 修复完成

所有 Main Actor 错误已解决！现在可以正常编译和运行项目了。

**修复时间**: 2026-03-01  
**修复文件**: 3 个 ViewModel  
**修复位置**: 12 处
