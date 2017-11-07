//
//  InfoViewController.swift
//  EnterpriseMessenger
//
//  Created by David Tucker on 2/16/15.
//  Copyright (c) 2015 Universal Mind. All rights reserved.
//

import Foundation
import UIKit

@objc(InfoViewController)

class InfoViewController : UIViewController, UITextViewDelegate {
    
    //MARK: -
    //MARK: IBOutlets
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: -
    //MARK: UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let rtfURL = Bundle.main.url(forResource: "about", withExtension: "rtf")
        let options = [
            NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf
        ]

        let attrStr = try? NSAttributedString (url: rtfURL!, options: options, documentAttributes: nil)
        infoTextView.delegate = self
        infoTextView.attributedText = attrStr
        infoTextView.isSelectable = true
        infoTextView.delaysContentTouches = false
        infoTextView.invalidateIntrinsicContentSize()
        view.setNeedsUpdateConstraints()
        textViewHeightConstraint.constant = infoTextView.sizeThatFits(CGSize(width: self.infoTextView.frame.size.width, height: CGFloat.greatestFiniteMagnitude)).height + 220
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("WILL APPEAR", terminator: "")
    }

    @IBAction func closeInfo(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }

    //MARK: -
    //MARK: UITextViewDelegate Implementation
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return true
    }
    
}
