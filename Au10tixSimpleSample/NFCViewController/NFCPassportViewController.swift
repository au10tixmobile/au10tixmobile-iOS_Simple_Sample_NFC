//
//  NFCPassportViewController.swift
//  Au10tixSimpleSample
//
//  Created by Serhii Kostrykin on 22.05.2022.
//

import UIKit
import AVFoundation
import Au10tixCore
import Au10tixNFCPassportKit

final class NFCPassportViewController: UIViewController {
    
    // MARK: - Properties    
    private var session = NFCPassportSession()
    
    // MARK: - Outlets
    @IBOutlet weak var previewView: UIView!
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Internal API
private extension NFCPassportViewController {
    
    /**
     Calls the start Session function of the Au10tixNFCPassportKit .
     */
    func prepare() {
        guard let token = Au10tix.shared.bearerToken else { return }
        session.delegate = self
        self.session.start(with: token, previewView: self.previewView) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let prepareError):
                self.showAlert("Prepare Error: \(prepareError)")
            case .success(let sessionId):
                debugPrint("start with sessionId: " + sessionId)
            }
        }
    }
    
    /**
     Read NFC data once you have a MRZ string - it uses to decode NFC data.
     */
    func readNFC(mrz: String) {
        self.session.readNFC(with: mrz)
    }
    
    func showAlert(_ text: String) {
        let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func openNFCResult(_ info: PassportInformation) {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
            return
        }
        controller.resultString =
        [info.firstName, info.lastName, info.dateOfBirth, info.documentExpiryDate, info.documentNumber, info.gender, info.nationality, info.issuingAuthority].joined(separator: ", ")
        controller.resultImage = info.passportImage
        navigationController?.pushViewController(controller, animated: true)
    }

}

// MARK: - NFCPassportSessionDelegate
extension NFCPassportViewController: NFCPassportSessionDelegate {
    
    /**
    Gets Called when an MRZ string scanned
     */
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didScan passportMRZ: String, in frame: CIImage) {
        readNFC(mrz: passportMRZ)
    }
    
    /**
    Gets Called when data groups found (DG01, DG02, DG07, DG14)
     */
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didIndicate dataGroupsFound: [String]) {
        
    }
    
    /**
    Gets Called on NFC data reading progress updated
     */
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didIndicate extractionProgress: String, of extractionPhase: String?) {
        
    }

    /**
    Gets Called when NFC data extracted
     */
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didExtract nfcInfo: PassportInformation) {
        openNFCResult(nfcInfo)
    }
    
    /**
    Gets Called on NFCSession error received
     */
    func nfcPassportSession(_ nfcPassportSession: NFCPassportSession, didFailWith error: NFCPassportSessionError) {
        showAlert("NFCError \(error)")
    }
    
}
