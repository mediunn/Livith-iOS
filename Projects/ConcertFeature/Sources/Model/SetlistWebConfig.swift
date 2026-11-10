import Foundation

public struct SetlistWebConfig: Sendable {
    public let baseURL: URL?

    public init(baseURL: URL?) {
        guard let baseURL,
              let scheme = baseURL.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              let host = baseURL.host, !host.isEmpty,
              baseURL.user == nil, baseURL.password == nil,
              baseURL.query == nil, baseURL.fragment == nil else {
            self.baseURL = nil
            return
        }
        self.baseURL = baseURL
    }

    func setlistURL(concertID: Int, setlistID: Int) -> URL? {
        baseURL?.appendingPathComponent("app/setlist/\(setlistID)/\(concertID)")
    }

    func allowsOrigin(scheme: String, host: String, port: Int?) -> Bool {
        guard let baseURL,
              baseURL.scheme?.lowercased() == scheme.lowercased(),
              baseURL.host?.lowercased() == host.lowercased() else { return false }
        let defaultPort = scheme.lowercased() == "https" ? 443 : 80
        let originPort = port == 0 ? nil : port
        return (baseURL.port ?? defaultPort) == (originPort ?? defaultPort)
    }
}
