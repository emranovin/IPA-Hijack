//
//  ViewController.swift
//
//  Created by Emran Novin on 9/9/23.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var interactiveLinkTextView: InteractiveLinkTextView!
    
    
    var url: URL = URL(string: "https://placeholder.com/app.ipa")! {
        didSet {
            renderAttributedString(url)
        }
    }
    
    lazy var deeplinkCoordinator: DeeplinkCoordinatorProtocol = {
        return DeeplinkCoordinator(handlers: [
            PlistDeeplinkHandler(self),
            TestDeeplinkHandler(self)
        ])
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        deeplinkCoordinator.handleURL(URL(string: "itms-services://?action=download-manifest&url=https://placeholder.com/manifest.plist")!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        renderAttributedString(url)
        interactiveLinkTextView.isUserInteractionEnabled = true
        interactiveLinkTextView.isEditable = false
    }
    
    func renderAttributedString(_ url: URL) {
        DispatchQueue.main.async { [weak self] in
            let fullString = NSMutableAttributedString(string: "URL: \n", attributes: nil)
            let hyperLinkString = NSMutableAttributedString(string: url.absoluteString, attributes:[NSAttributedString.Key.link: url])
            fullString.append(hyperLinkString)
            self?.interactiveLinkTextView.attributedText = fullString
            self?.interactiveLinkTextView.font = .systemFont(ofSize: 32)
        }
    }
}
