//
//  ViewController.swift
//
//  Created by Emran Novin on 9/9/23.
//

import UIKit

enum State {
    case none
    case isProcessing
    case successful(URL)
    case failed(Error)
}

class MainViewController: UIViewController {
    
    @IBOutlet private weak var interactiveLinkTextView: InteractiveLinkTextView!
    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!
    
    @IBAction private func didTapOnButton() {
        guard let url = URL(string: interactiveLinkTextView.text) else { return }
        let isHandling = deeplinkCoordinator?.handleURL(url) ?? false
        state = isHandling ? .isProcessing : .none
    }
    
    var deeplinkCoordinator: DeeplinkCoordinatorProtocol?
    
    private var state: State = .none {
        didSet { handleState() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        state = .none
    }
    
    private func handleState() {
        switch state {
        case .none:
            showMessage("Enter a valid URL, ")
            
        case .isProcessing:
            loadingIndicator.startAnimating()
            showMessage("Is Processing ...")
            
        case .successful(let url):
            loadingIndicator.stopAnimating()
            renderAttributedString(url)
            
        case .failed(let error):
            loadingIndicator.stopAnimating()
            showMessage(error.localizedDescription)
        }
    }
    
    private func renderAttributedString(_ url: URL) {
        let fullString = NSMutableAttributedString(string: "URL: \n", attributes: nil)
        let hyperLinkString = NSMutableAttributedString(string: url.absoluteString, attributes:[NSAttributedString.Key.link: url])
        fullString.append(hyperLinkString)
        interactiveLinkTextView.attributedText = fullString
    }
    
    private func showMessage(_ message: String) {
        interactiveLinkTextView.text = message
    }
}

extension MainViewController: PlistHandlerProtocol {
    func didHandleURL(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .successful(url)
        }
    }
    
    func didEncounterError(_ error: Error) {
        DispatchQueue.main.async { [weak self] in
            self?.state = .failed(error)
        }
    }
}
