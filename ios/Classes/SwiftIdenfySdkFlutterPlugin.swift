import Flutter
import UIKit
import iDenfySDK
import idenfycore
import idenfyviews

public class SwiftIdenfySdkFlutterPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "idenfy_sdk_flutter", binaryMessenger: registrar.messenger())
    let instance = SwiftIdenfySdkFlutterPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
          result("iOS " + UIDevice.current.systemVersion)
        } else if call.method == "start" {
            if let arguments = call.arguments as? [String: Any],
               let authToken = arguments["authToken"] as? String {
                
                let idenfySettingsV2 = IdenfyBuilderV2()
                    .withAuthToken(authToken)
                    .build()
                
                IdenfyCommonColors.idenfyMainColorV2 = UIColor.init("0082FF")
                IdenfyCommonColors.idenfyMainDarkerColorV2 = UIColor.init("007EF5")
                IdenfyConfirmationViewUISettingsV2.idenfyDocumentConfirmationViewDocumentStepCircleTintColor = UIColor.init("007EF5")
                IdenfyConfirmationViewUISettingsV2.idenfyDocumentConfirmationViewUploadIconTintColor = UIColor.init("007EF5")
                IdenfyToolbarUISettingsV2.idenfyDefaultToolbarLogoIconTintColor = nil
                IdenfyToolbarUISettingsV2.idenfyDefaultToolbarBackIconTintColor = UIColor.init("007EF5")
                IdenfyToolbarUISettingsV2.idenfyLanguageSelectionToolbarLanguageSelectionIconTintColor = UIColor.init("007EF5")
                IdenfyToolbarUISettingsV2.idenfyLanguageSelectionToolbarCloseIconTintColor = UIColor.init("007EF5")
                IdenfyToolbarUISettingsV2.idenfyCameraPreviewSessionToolbarBackIconTintColor = UIColor.init("007EF5")
                IdenfyIdentificationResultsViewUISettingsV2.idenfyIdentificationResultsDividerIconStatusErrorTintColor = UIColor.init("007EF5")
                IdenfyIdentificationResultsViewUISettingsV2.idenfyIdentificationResultsDividerIconStatusLoadingTintColor = UIColor.init("007EF5")

                let idenfyController = IdenfyController.shared
                idenfyController.initializeIdenfySDKV2WithManual(idenfySettingsV2: idenfySettingsV2)
                let idenfyVC = idenfyController.instantiateNavigationController()

                UIApplication.shared.keyWindow?.rootViewController?.present(idenfyVC, animated: true, completion: nil)

                idenfyController.handleIdenfyCallbacksWithManualResults(idenfyIdentificationResult: {
                    idenfyIdentificationResult
                    in
                    do {
                        let jsonEncoder = JSONEncoder()
                        let jsonData = try jsonEncoder.encode(idenfyIdentificationResult)
                        let string = String(data: jsonData, encoding: String.Encoding.utf8)
                        result(string)
                    } catch {
                    }
                })
            }
        } else if call.method == "startFaceAuth" {
            if let arguments = call.arguments as? [String: Any],
               let withImmediateRedirect = arguments["withImmediateRedirect"] as? Bool,
               let authenticationToken = arguments["token"] as? String {
                let idenfyFaceAuthUISettings = IdenfySettingsDecoder.decodeFaceAuthUISettings(arguments["idenfyFaceAuthUISettings"] as? [String : AnyObject?])
                let idenfyController = IdenfyController.shared
                let faceAuthenticationInitialization = FaceAuthenticationInitialization(authenticationToken: authenticationToken, withImmediateRedirect: withImmediateRedirect, idenfyFaceAuthUISettings: idenfyFaceAuthUISettings)
                idenfyController.initializeFaceAuthentication(faceAuthenticationInitialization: faceAuthenticationInitialization)
                let idenfyVC = idenfyController.instantiateNavigationController()
                
                UIApplication.shared.keyWindow?.rootViewController?.present(idenfyVC, animated: true, completion: nil)
                
                idenfyController.handleIdenfyCallbacksForFaceAuthentication(faceAuthenticationResult: { faceAuthenticationResult in
                    do {
                        let jsonEncoder = JSONEncoder()
                        let jsonData = try jsonEncoder.encode(faceAuthenticationResult)
                        let string = String(data: jsonData, encoding: String.Encoding.utf8)
                        result(string)
                    } catch {
                    }
                })
            }
        }
    }
}

extension UIColor {

  convenience init(_ hex: String, alpha: CGFloat = 1.0) {
    var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

    if cString.hasPrefix("#") { cString.removeFirst() }

    if cString.count != 6 {
      self.init("ff0000") // return red color for wrong hex input
      return
    }

    var rgbValue: UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)

    self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
              green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
              blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
              alpha: alpha)
  }

class IdenfySettingsDecoder {
    
    static func decodeFaceAuthUISettings(_ json: [String: AnyObject?]?) -> IdenfyFaceAuthUISettings {
        let faceAuthUISettings = IdenfyFaceAuthUISettings()
        if let unwrappedLanguageSelectionNeeded = json?["isLanguageSelectionNeeded"] as? Bool {
            faceAuthUISettings.isLanguageSelectionNeeded = unwrappedLanguageSelectionNeeded
        }
        if let unwrappedSkipOnBoardingView = json?["skipOnBoardingView"] as? Bool {
            faceAuthUISettings.skipOnBoardingView = unwrappedSkipOnBoardingView
        }
        return faceAuthUISettings
    }
}
