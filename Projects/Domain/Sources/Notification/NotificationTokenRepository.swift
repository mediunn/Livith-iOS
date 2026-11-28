public protocol NotificationTokenRepository {
    func registerFCMToken(_ token: String) async throws(NotificationError)
    func deleteFCMToken(_ token: String) async throws(NotificationError)
}
