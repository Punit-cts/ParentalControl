//
//  AuthenticationManager.swift
//

import Foundation
import LocalAuthentication
import RealmSwift

enum BiometricType: String {
    case none
    case touchID
    case faceID
}

extension LAContext {
    
    var biometricType: BiometricType {
        var error: NSError?
        
        guard self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            // Capture these recoverable error thru Crashlytics
            return .none
        }
        
        if #available(iOS 11.0, *) {
            switch self.biometryType {
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            default:
                return .none
            }
        } else {
            return  self.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) ? .touchID : .none
        }
    }
}

class Authenticator: NotificationCountType, RealmServiceType {
    
    static let shared = Authenticator()
    
    var objectService = ObjectServiceProvider()
    
    var notifCount:Int?
    var messageCount: Int?
    
    func getBiometricType() -> BiometricType {
        return LAContext().biometricType
    }
        
    func canUseBiometric() -> Bool {
        // Get the current authentication context
        let context = LAContext()
        var authError: NSError?
        //        context.localizedFallbackTitle = "Use Password"
        
        // Check if the device is compatible with TouchID and can evaluate the policy.
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            return false
        }
        return true
    }
    
    func useBiometric(compltion: @escaping (String?) -> ()) {
        if Authenticator.shared.canUseBiometric() {
            Authenticator.shared.bioMetricAuthenticate {
                compltion(nil)
            } failure: { errorMessage in
                compltion(errorMessage)
            }
        } else {
            compltion(nil)
        }
    }
    
    func isLoggedIn() -> Bool {
        guard let check: Bool = UserDefaultKey.deviceVerified.value() else {
            return false
        }
        return check
    }
    
    func bioMetricAuthenticate(success: @escaping ()->(), failure: @escaping (String)->()) {
        // Get the current authentication context
        let context = LAContext()
        var authError: NSError?
        //        context.localizedFallbackTitle = "Use Password"
        let myLocalizedReasonString = "Login to your account."
        
        // Check if the device is compatible with TouchID and can evaluate the policy.
        guard context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            DispatchQueue.main.async {
                failure("Biometric authentication failed")
            }
            return
        }
        
        context.evaluatePolicy(
            LAPolicy.deviceOwnerAuthenticationWithBiometrics,
            localizedReason: myLocalizedReasonString,
            reply: { (status, error) in
                if status {
                    DispatchQueue.main.async {
                        success()
                    }
                } else {
                    DispatchQueue.main.async {
                        if let err = error as NSError?{
                            
                            func biomertyFailure(for code: Int) {
                                if #available(iOS 11.0, *) {
                                    switch code {
                                    case LAError.biometryLockout.rawValue:
                                        failure("biometric is locked for certain period.")
                                    case LAError.biometryNotAvailable.rawValue:
                                        failure("biometric is not available for your device")
                                    case LAError.biometryNotEnrolled.rawValue :
                                        failure("biometric is not enrolled for your device.")
                                    default:
                                        OperationQueue.main.addOperation({ () -> Void in
                                            self.bioMetricAuthenticate(success: success, failure: failure)
                                        })
                                    }
                                } else {
                                    switch code {
                                    case LAError.touchIDLockout.rawValue:
                                        failure("biometric is locked for certain period.")
                                        break
                                    case LAError.touchIDNotAvailable.rawValue:
                                        failure("biometric is not available for your device")
                                    case LAError.touchIDNotEnrolled.rawValue :
                                        failure("biometric is not enrolled for your device.")
                                    default:
                                        OperationQueue.main.addOperation({ () -> Void in
                                            self.bioMetricAuthenticate(success: success, failure: failure)
                                        })
                                    }
                                }
                            }
                            
                            switch err.code {
                            // Cancellation
                            case LAError.Code.appCancel.rawValue:
                                failure("Biometric canceled by app.")
                            case LAError.Code.systemCancel.rawValue:
                                failure("Biometric canceled by system.")
                            case LAError.Code.userCancel.rawValue:
                                failure("Biometric canceled by user.")
                                
                            // Other Errors
                            case LAError.Code.userFallback.rawValue:
                                // We show the alert view in the main thread (always update the UI in the main thread)
                                OperationQueue.main.addOperation({ () -> Void in
                                    failure("Biometric fallback available.")
                                })
                            case LAError.Code.passcodeNotSet.rawValue:
                                failure("Biometric passcode not set")
                            case LAError.authenticationFailed.rawValue:
                                failure("Biometric authentication failed.")
                            case LAError.invalidContext.rawValue:
                                failure("Biometric invalid context.")
                            case LAError.notInteractive.rawValue:
                                failure("Biometric not interactive.")
                            default:
                                biomertyFailure(for: err.code)
                            }
                            
                        }
                    }
                }
        })
    }
    
    func isBiometricEnabled() -> Bool {
        guard let check: Bool = UserDefaultKey.biometricSettingEnbled.value() else {
            return false
        }
        return check
    }
    
    func fileDownloaded(file path:String) {
        if var values:[String] = UserDefaultKey.downloadedFiles.value() {
            values.append(path)
            UserDefaultKey.downloadedFiles.set(value: values)
        } else {
            UserDefaultKey.downloadedFiles.set(value: [path])
        }
    }
    
    func saveFetchedResponse(at path:String) {
        if var values:[String] = UserDefaultKey.downloadedFiles.value() {
            values.append(path)
            UserDefaultKey.responses.set(value: values)
        } else {
            UserDefaultKey.responses.set(value: [path])
        }
    }
    
    /// This will clear database after files are removed
    func removeDownloadedFiles() {
        if let files = FileObjectServiceImpl().getSavedFileObjects() {
            _ = files.map { self.removeFile(at: $0.filePath)}
            // Clear all database elements
            try? realm?.write {
                realm?.deleteAll()
            }
        }
        if let values:[String] = UserDefaultKey.downloadedFiles.value() {
            var notRemoved = [String]()
            for filePath in values {
                if var path = filePath.removingPercentEncoding {
                    path = path.replacingOccurrences(of: "file://", with: "")
                    if LocalFileManager.shared.checkExists(at: path) {
                        try? LocalFileManager.shared.removeItem(at: path)
                        print("==========================")
                        print("Removed: \(path)")
                        print("==========================")
                    } else {
                        notRemoved.append(filePath)
                    }
                }
            }
            UserDefaultKey.downloadedFiles.set(value: notRemoved)
        }
    }
    
    func removefetchedResponse() {
        if let values:[String] = UserDefaultKey.responses.value() {
            var notRemoved = [String]()
            for filePath in values {
                if var path = filePath.removingPercentEncoding {
                    path = path.replacingOccurrences(of: "file://", with: "")
                    if LocalFileManager.shared.checkExists(at: path) {
                        try? LocalFileManager.shared.removeItem(at: path)
                        print("==========================")
                        print("Removed: \(path)")
                        print("==========================")
                    } else {
                        notRemoved.append(filePath)
                    }
                }
            }
            UserDefaultKey.responses.set(value: notRemoved)
        }
    }
    
    func removeFile(at path: String) {
        guard var path = path.removingPercentEncoding else {
            return
        }
        path = path.replacingOccurrences(of: "file://", with: "")
        if LocalFileManager.shared.checkExists(at: path) {
            try? LocalFileManager.shared.removeItem(at: path)
            print("==========================")
            print("Removed: \(path)")
            print("==========================")
        }
    }
    
    func logout(completion: @escaping () -> ()) {
        AuthCache.Cookies.clear()
        
        self.objectService.updateObjectValue {
            self.objectService.realm?.deleteAll()
        }
                
        // Saved After Login Start
        UserDefaultKey.user.remove()
        AuthCache.AcessToken.remove()
        AuthCache.AccessTokenType.remove()
        AuthCache.DeviceVerification.remove()
        
        removeDownloadedFiles()
        UserDefaultKey.downloadedFiles.remove()
        removefetchedResponse()
        UserDefaultKey.responses.remove()
        UserDefaults.standard.synchronize()
        completion()
    }
}



