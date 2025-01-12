//
// MainViewController.swift
// Au10tixSimpleSample
//
// Create By Au10tixon.
//

import UIKit
import AVFoundation
import Au10tixCore
import Au10tixBaseUI
import Au10tixProofOfAddressKit
import Au10tixSmartDocumentCaptureKit
import Au10tixPassiveFaceLivenessKit
import Au10tixProofOfAddressUI
import Au10tixSmartDocumentCaptureUI
import Au10tixPassiveFaceLivenessUI
import Au10tixBEKit
import Au10tixLivenessKit
import Au10tixLivenessUI
import Au10tixNFCPassportKit
import Au10tixNFCPassportUI

final class MainViewController: UIViewController {
    
    private var pflResultString: String?
    
    // MARK: - IBOutlets
    @IBOutlet private weak var stackView: UIStackView!
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // -----------
        
        uiPreparation()
        requestVideoPermission()
        addObserver()
    }
}

// MARK: - Private Methods

private extension MainViewController {
    
    private func requestVideoPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            self.prepare()
        case .denied, .restricted:
            self.showAlert("Video Permission was not granted", isError: true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.requestVideoPermission()
                }
            }
        @unknown default:
            fatalError()
        }
    }
    // MARK: - SDK Preparation
    /**
     Use this method to prepare Au10tix SDK.
     - warning: Use the JWT retrieved from your backend. See Au10tix guide for more info.
     */
    func prepare() {
        
        #warning("Use the JWT retrieved from your backend. See Au10tix guide for more info")
        let jwtToken = ""
        
        Au10tix.shared.prepare(with: jwtToken) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let sessionID):
                debugPrint("sessionID -\(sessionID)")
            case .failure(let error):
                self.showAlert(error.localizedDescription, isError: true)
            }
        }
    }
    
    // MARK: - Open SMART DOCUMENT CAPTURING UI component
    /**
     Use this method to initialize the SMART DOCUMENT CAPTURING UI component.
     */
    
    func openSDCUIComponent() {
        let configs = UIComponentConfigs()
        let controller = SDCViewController(configs: configs, navigationDelegate: self)
        controller.sdcDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Open PASSIVE FACE LIVENESS UI component.
    /**
     Use this method to initialize the PASSIVE FACE LIVENESS UI component.
     */
    
    func openPFLUIComponent() {
        let configs = UIComponentConfigs()
        let controller = PFLViewController(configs: configs, navigationDelegate: self)
        controller.pflDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Open LIVENESS UI component.
    /**
     Use this method to initialize the LIVENESS UI component.
     */
    
    func openLivenessUIComponent() {
        let configs = UIComponentConfigs()
        let livenessVC = LivenessViewController(configs: configs, navigationDelegate: self)
        livenessVC.livenessSessionDelegate = self
        self.present(livenessVC, animated: true, completion: nil)
    }
    
    // MARK: - Open PROOF OF ADDRESS UI component.
    /**
     Use this method to initialize the PROOF OF ADDRESS UI component.
     */
    
    func openPOAUIComponent() {
        let configs = UIComponentConfigs()
        let controller = POAViewController(configs: configs, navigationDelegate: self)
        controller.poaDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Open Passport UI component.
    /**
     Use this method to initialize the PROOF OF ADDRESS UI component.
     */
    func openNFCUIComponent() {
        let controller = NFCViewController()
        controller.nfcDelegate = self
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Open PFLViewController
    
    func openPFLViewController() {
        
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PFLUIViewController") as? PFLUIViewController else {
            return
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Open SDCViewContrller
    
    func openSDCViewContrller() {
        
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SDCUIViewController") as? SDCUIViewController else {
            return
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Open POAUIViewController
    
    func openPOAViewContrller() {
        
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "POAUIViewController") as? POAUIViewController else {
            return
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Open NFCUIViewController
    
    func openNFCPassportViewController() {
        
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NFCPassportViewController") as? NFCPassportViewController else {
            return
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }

    
    // MARK: - Open ResultViewController
    
    func openPFLResult(_ image: UIImage, resultString: String) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
            return
        }
        
        controller.resultString = resultString
        controller.resultImage = image
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - openSDCResults
    
    func openSDCResult(_ image: Au10Image) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
            return
        }
        
        controller.resultImage = image.uiImage
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - openPOAResults
    
    func openPOAResult(_ image: Au10Image) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
            return
        }
        
        controller.resultImage = image.uiImage
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // MARK: - Open NFCViewContrller
    
    func openNFCViewContrller() {
        
        guard let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SDCUIViewController") as? SDCUIViewController else {
            return
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }

    
    // MARK: - UIAlertController
    
    func showAlert(_ text: String, isError: Bool) {
        let alert = UIAlertController(title: isError ? "Error ☹️" : "Success 😀", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Buttons Preparation
    
    func uiPreparation() {
        stackView.arrangedSubviews
            .compactMap{ $0 as? UIButton }
            .compactMap{ $0.titleLabel}
            .forEach {
                $0.lineBreakMode = .byWordWrapping
                $0.textAlignment = .center
            }
    }
    
    // MARK: - Observer
    
    func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleExpirationNotification(_:)),
                                               name: .au10tixCoreTokenExpiration, object: nil)
    }
    
    @objc func handleExpirationNotification(_ sender: Notification) {
        let alert = UIAlertController(title: "Error", message: "Session Is Expired", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if var topController = UIApplication.shared.windows.filter({$0.isKeyWindow}).first?.rootViewController {
            if let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Actions

private extension MainViewController {
    
    @IBAction func btnSDCAction() {
        openSDCViewContrller()
    }
    
    @IBAction func btnPFLAction() {
        openPFLViewController()
    }
    
    @IBAction func btnPOAAction() {
        openPOAViewContrller()
    }

    @IBAction func btnNFCAction() {
        openNFCPassportViewController()
    }
    
    @IBAction func btnSDCwithUIAction() {
        openSDCUIComponent()
    }
    
    @IBAction func btnPFLwithUIAction() {
        openPFLUIComponent()
    }
    
    @IBAction func btnPOAwithUIAction() {
        openPOAUIComponent()
    }
    
    @IBAction func btnNFCwithUIAction() {
        openNFCUIComponent()
    }

    
    @IBAction func btnLivenessWithUIAction() {
        openLivenessUIComponent()
    }
    
    @IBAction func sendIdvRequest(sender: UIButton) {
        let originalTitle = sender.title(for: .normal)
        sender.setTitle("Sending...", for: .normal)
        Au10tixBackendKit.shared.sendIDVerificationFlow { [weak self, weak sender] result in
            guard let self = self, let sender = sender else { return }
            sender.setTitle(originalTitle, for: .normal)
            switch result {
            case .success(let requestId):
                self.showAlert("✅ RequestId: " + requestId, isError: false)
            case .failure(let error):
                self.showAlert("❌ \(error)", isError: true)
            }
        }
    }
    
    @IBAction func sendPoaRequest(sender: UIButton) {
        let alert = UIAlertController(title: "Proof Of Address Validation", message: "Fill details for comparison", preferredStyle: .alert)
        alert.addTextField {
            $0.placeholder = "First Name"
            $0.textContentType = .givenName
        }
        
        alert.addTextField {
            $0.placeholder = "Last Name"
            $0.textContentType = .familyName
        }
        
        alert.addTextField {
            $0.placeholder = "Address"
            $0.textContentType = .fullStreetAddress
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        alert.addAction(UIAlertAction(title: "🚀 Send", style: .default, handler: { [weak self, weak sender](_) in
            guard let self = self, let sender = sender else { return }
            guard let firstName = alert.textFields?[0].text,
                  let lastName = alert.textFields?[1].text,
                  let address = alert.textFields?[2].text else { return }
            
            let originalTitle = sender.title(for: .normal)
            sender.setTitle("Sending...", for: .normal)
            
            Au10tixBackendKit.shared.sendProofOfAddress(firstName: firstName, lastName: lastName, address: address) { [weak self, weak sender](result) in
                guard let self = self, let sender = sender else { return }
                sender.setTitle(originalTitle, for: .normal)
                switch result {
                case .success(let requestId):
                    self.showAlert("✅ RequestId: " + requestId, isError: false)
                case .failure(let error):
                    self.showAlert("❌ \(error)", isError: true)
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - POASessionDelegate

extension MainViewController: POASessionDelegate {
    
    /**
    Gets Called when Proof Of Address session failed
     */
    func poaSession(_ poaSession: POASession, didFailWith error: POASessionError) {
        
    }
    
    /**
    Gets Called when Proof Of Address image was taken
     */
    func poaSession(_ poaSession: POASession, didCapture image: Au10Image, with frameData: Au10Update) {
        openPOAResult(image)
    }
    
}

//MARK: - SDCSessionDelegate

extension MainViewController: SDCSessionDelegate {
    
    /**
    Gets Called when Smart Documet session failed
     */
    func sdcSession(_ sdcSession: SDCSession, didFailWithError error: SDCSessionError) {
        
    }
    
    /**
    Gets Called when Smart Documet result is received and processed
     */
    func sdcSession(_ sdcSession: SDCSession, didProcess processingStatus: SDCProcessingStatus) {
        
    }
    
    /**
    Gets Called when document was taken
     */
    func sdcSession(_ sdcSession: SDCSession, didCapture image: Au10Image, croppedImage: Au10Image?, with processingStatus: SDCProcessingStatus) {
        openSDCResult(croppedImage ?? image)
    }
    
    /**
    Gets Called when a barcode was detected
     */
    func sdcSession(_ sdcSession: SDCSession, didDetect machineReadableCodes: [Au10MachineReadableCode]) {
        
    }
    
    /**
    Gets Called when an image was taken
     */
    func sdcSession(_ sdcSession: SDCSession, didTake image: Au10Image) {
        
    }
}

//MARK: - PFLSessionDelegate

extension MainViewController: PFLSessionDelegate {
        
    /**
    Gets Called upon image sample is captured
     */
    func pflSession(_ pflSession: PFLSession, didCapture image: Data, qualityFeedback: QualityFaultOptions, faceBoundingBox: CGRect?) {
        
    }

    /**
    Gets Called for quality feedbcak while capturing session is running
     */
    func pflSession(_ pflSession: PFLSession, didRecieve qualityFeedback: QualityFaultOptions) {
        
    }
    
    private func getFaceErrortStringValue(_ error: FaceError?) -> String {
        
        guard let faceError = error else {return "none"}
        
        switch faceError {
        case .faceAngleTooLarge:
            return "faceAngleTooLarge"
        case .faceCropped:
            return "faceCropped"
        case .faceNotFound:
            return "faceNotFound"
        case .faceTooClose:
            return "faceTooClose"
        case .faceTooCloseToBorder:
            return "faceTooCloseToBorder"
        case .faceTooSmall:
            return "faceTooSmall"
        case .internalError:
            return "internalError"
        case .tooManyFaces:
            return "tooManyFaces"
        case .faceIsOccluded:
            return "faceIsOccluded"
        case .failedToReadImage:
            return "failedToReadImage"
        case .failedToWriteImage:
            return "failedToWriteImage"
        case .failedToReadModel:
            return "failedToReadModel"
        case .failedToAllocate:
            return "failedToAllocate"
        case .invalidConfig:
            return "invalidConfig"
        case .noSuchObject:
            return "noSuchObject"
        case .failedToPreprocessImageWhilePredict:
            return "failedToPreprocessImageWhilePredict"
        case .failedToPreprocessImageWhileDetect:
            return "failedToPreprocessImageWhileDetect"
        case .failedToPredictLandmarks:
            return "failedToPredictLandmarks"
        case .invalidFuseMode:
            return "invalidFuseMode"
        case .nullPtr:
            return "nullPtr"
        case .licenseError:
            return "licenseError"
        case .invalidMeta:
            return "invalidMeta"
        @unknown default:
            return ""
        }
    }
    
    private func getPflResultText(_ result: PFLResponse) -> String {
        
        return ["score - \(result.score ?? 0)",
                "quality - \(result.quality ?? 0)",
                "probability - \(result.probability ?? 0)",
                "faceError -\(getFaceErrortStringValue(result.error_code?.toFaceError))"].joined(separator: "\n")
    }
    
    /**
    Gets Called when on PFL liveness check result
     */
    func pflSession(_ pflSession: PFLSession, didConcludeWith result: PFLResponse, for image: Data) {
        self.pflResultString = getPflResultText(result)
    }
    
    /**
    Gets Called when PFL validation started
     */
    func pflSession(_ pflSession: PFLSession, didStartValidating image: Data) {
        
    }

    
    /**
    Gets Called when PFL passed liveness probabillity
     */
    func pflSession(_ pflSession: PFLSession, didPassProbabilityThresholdFor image: Data) {
        guard let uiImage = UIImage(data: image) else { return }
        self.openPFLResult(uiImage, resultString: self.pflResultString ?? "")
    }
    
    /**
    Gets Called when PFL failed
     */
    func pflSession(_ pflSession: PFLSession, didFailWith error: PFLSessionError) {
        
    }
    
}


extension MainViewController: LivenessSessionDelegate {
    
    /**
    Gets Called when Liveness finished
     */
    func livenessSession(_ session: LivenessSession, didFinishWithResult result: LivenessSessionResult) {
        
    }
    
    /**
    Gets Called when Liveness has an update
     */
    func livenessSession(_ session: LivenessSession, didReceiveAnUpdate update: LivenessSessionUpdate) {
        
    }
    
    /**
    Gets Called when Liveness failed
     */
    func livenessSession(_ session: LivenessSession, didFailWithError error: LivenessSessionError) {
        
    }
    
    /**
    Gets Called when Liveness waiting for user action due to 'reason'
     */
    func livenessSession(_ session: LivenessSession, waitingForUserAction reason: LivenessSessionWaitingForUserReason) {
        //you can show some UI prior to proceedToNextStep invokation
        session.proceedToNextStep()
    }
    
    /**
    Gets Called when Liveness session screen recording failed
     */
    func livenessSession(_ session: LivenessSession, didFailScreenRecordingWith error: ScreenRecorderError) {
        
    }
    
}

extension MainViewController: UIComponentViewControllerNavigationDelegate {
    /**
     Gets called whenever an UI-Comp finished.
     */
    func uiComponentViewControllerDidFinish(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    /**
     Gets called whenever an UI-Comp close button pressed.
     */
    func uiComponentViewControllerDidPressClose(_ controller: UIComponentBaseViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - NFCFlowDelegate
extension MainViewController: NFCFlowDelegate {
    
    func nfcSession(didSucceedWith passportMRZ: String?, and passportImage: UIImage?, and info: PassportInformation?) {
    }

    func nfcSession(didFailWith error: NFCFlowError) { }
    
    /**
     Gets called whenever an UI-Comp close button pressed.
     */
    func nfcSessionDidClose() {
        dismiss(animated: true, completion: nil)
    }
    
}


