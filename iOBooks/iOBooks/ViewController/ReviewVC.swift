//
//  ReviewVC.swift
//  iOBooks
//
//  Created by Nikita Thomas on 10/29/18.
//  Copyright © 2018 Nikita Thomas. All rights reserved.
//

import UIKit

class ReviewVC: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    @IBAction func saveReviewButton(_ sender: Any) {
        if let text = textView.text {
            book?.review = text
        }
        guard let book = book else {return}
        BookController.shared.updateBookOnServer(book: book)
        navigationController?.popViewController(animated: true)
    }
    
    
    var book: Book?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.text = book?.review
    }
}
