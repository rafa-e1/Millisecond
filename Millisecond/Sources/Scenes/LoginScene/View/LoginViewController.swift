//
//  LoginViewController.swift
//  Millisecond
//
//  Created by RAFA on 10/3/24.
//

import UIKit

final class LoginViewController: BaseViewController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
