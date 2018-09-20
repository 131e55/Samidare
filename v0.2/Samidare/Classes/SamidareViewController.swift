//
//  SamidareViewController.swift
//  Samidare
//
//  Created by Keisuke Kawamura on 2018/03/22.
//

import UIKit

open class SamidareViewController: UIViewController {

    open override func loadView() {
        print("🐶")
        super.loadView()
    }

    open override func viewDidLoad() {
        super.viewDidLoad()

        print("🐱")
        print(view.backgroundColor)
    }
}

