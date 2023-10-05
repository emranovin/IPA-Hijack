//
//  ViewController.swift
//  IPACatcher
//
//  Created by Emran Novin on 9/9/23.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var interactiveLinkTextView: InteractiveLinkTextView!
    
    
    var url: URL = URL(string: "https://Sample.com/App.ipa")! {
        didSet {
            renderAttributedString(url)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        renderAttributedString(url)
        interactiveLinkTextView.isUserInteractionEnabled = true
        interactiveLinkTextView.isEditable = false
    }
    
    func renderAttributedString(_ url: URL) {
        let fullString = NSMutableAttributedString(string: "URL: \n", attributes: nil)
        let hyperLinkString = NSMutableAttributedString(string: url.absoluteString, attributes:[NSAttributedString.Key.link: url])
        fullString.append(hyperLinkString)
        interactiveLinkTextView.attributedText = fullString
        interactiveLinkTextView.font = .systemFont(ofSize: 32)
    }
}
