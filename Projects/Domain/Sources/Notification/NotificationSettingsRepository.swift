public protocol NotificationSettingsRepository {
    func updateNotificationConsent(
        field: NotificationConsentField,
        isAgreed: Bool
    ) async throws(NotificationError) -> NotificationConsentResult
    func updateMarketingConsent() async throws(NotificationError) -> NotificationConsentResult
    func fetchNotificationSettings() async throws(NotificationError) -> NotificationSettings
}
