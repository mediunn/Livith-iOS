//
//  AppleAuthenticator.swift
//  SocialAuth
//
//  Created by 김진웅 on 12/4/25.
//  Copyright © 2025 Livith. All rights reserved.
//

import Foundation
import AuthenticationServices

final class AppleAuthenticator: NSObject, SocialAuthenticator {
    private var activeContinuation: CheckedContinuation<SocialAuthCredential, Error>?
    
    @MainActor
    func signIn() async throws(SocialAuthError) -> SocialAuthCredential {
        do {
            return try await withCheckedThrowingContinuation { continuation in
                if let oldContinuation = activeContinuation {
                    oldContinuation.resume(throwing: SocialAuthError.canceled)
                }
                
                activeContinuation = continuation
                
                performAppleLoginRequest()
            }
        } catch let authError as SocialAuthError {
            throw authError
        } catch {
            throw .unknown
        }
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleAuthenticator: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let continuation = activeContinuation else { return }
        
        do {
            let credential = try self.createCredential(from: authorization)
            continuation.resume(returning: credential)
        } catch {
            continuation.resume(throwing: error)
        }
        
        activeContinuation = nil
    }
    
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        guard let continuation = activeContinuation else { return }
        
        let authError = convertToAuthError(from: error)
        continuation.resume(throwing: authError)
        
        activeContinuation = nil
    }
    
    private func convertToAuthError(from error: Error) -> SocialAuthError {
        guard let authorizationError = error as? ASAuthorizationError else {
            return .unknown
        }
        
        switch authorizationError.code {
        case .canceled:
            return .canceled
        default:
            return .unknown
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleAuthenticator: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let activeScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }),
              let windowScene = activeScene as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow })
        else {
            return ASPresentationAnchor()
        }
        return window
    }
}

// MARK: - Helpers

private extension AppleAuthenticator {
    func performAppleLoginRequest() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
    
    func createCredential(from authorization: ASAuthorization) throws -> SocialAuthCredential {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let identityToken = appleIDCredential.identityToken,
              let tokenString = String(data: identityToken, encoding: .utf8)
        else {
            throw SocialAuthError.missingToken
        }
        
        return SocialAuthCredential(
            vendor: .apple,
            token: tokenString,
            userID: appleIDCredential.email
        )
    }
}
