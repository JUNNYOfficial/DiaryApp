import SwiftUI

struct ProfileView: View {
    @Environment(\.theme) var theme
    @Environment(\.dismiss) private var dismiss
    @StateObject private var authService = AppleSignInService.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundWhite
                    .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Avatar
                    ZStack {
                        Circle()
                            .fill(theme.lightBlue)
                            .frame(width: 100, height: 100)
                        
                        Text(initials)
                            .font(.system(size: 36, weight: .bold))
                            .foregroundStyle(theme.primaryBlue)
                    }
                    
                    // Info
                    VStack(spacing: 8) {
                        Text(authService.fullName.isEmpty ? "用户" : authService.fullName)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(theme.textPrimary)
                        
                        if !authService.email.isEmpty {
                            Text(authService.email)
                                .font(.system(size: 15))
                                .foregroundStyle(theme.textSecondary)
                        }
                        
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.shield.fill")
                                .font(.caption)
                            Text("Apple ID 已验证")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .foregroundStyle(Color.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    
                    // Settings
                    VStack(spacing: 0) {
                        SettingRow(icon: "cloud.fill", iconColor: theme.primaryBlue, title: "iCloud 同步", value: "已开启")
                        
                        Divider()
                            .padding(.leading, 52)
                        
                        SettingRow(icon: "lock.fill", iconColor: theme.primaryBlue, title: "隐私保护", value: "")
                    }
                    .background(theme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Logout
                    Button(action: {
                        authService.logout()
                        dismiss()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "arrow.right.square")
                            Text("退出登录")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(Color.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.red.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 20)
                }
                .padding(.top, 32)
            }
            .navigationTitle("个人中心")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("完成") { dismiss() }
                        .foregroundStyle(theme.primaryBlue)
                }
            }
        }
    }
    
    private var initials: String {
        let name = authService.fullName.isEmpty ? "用户" : authService.fullName
        let components = name.components(separatedBy: " ")
        if components.count >= 2 {
            let first = components.first?.prefix(1) ?? ""
            let last = components.last?.prefix(1) ?? ""
            return String(first + last)
        }
        return String(name.prefix(1))
    }
}

struct SettingRow: View {
    @Environment(\.theme) var theme
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(iconColor)
                .frame(width: 28)
            
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(theme.textPrimary)
            
            Spacer()
            
            if !value.isEmpty {
                Text(value)
                    .font(.system(size: 14))
                    .foregroundStyle(theme.textSecondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(theme.textSecondary.opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}
