//
//  ViewController.swift
//  UrbanPiperTest
//
//  Created by Gupta, Ajay - Ajay on 9/19/17.
//  Copyright © 2017 Gupta, Ajay - Ajay. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class ViewController: UIViewController, UITextFieldDelegate, GIDSignInUIDelegate {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!
    
    var credentials: AuthCredential? {
        didSet{
            googleSignInButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        self.activityIndicator.isHidden = true
        googleSignInButton.isEnabled = false

        self.passwordTextField.delegate = self
        self.mobileNumberTextField.delegate = self
        
        // Set up for google signin
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func loginButtonPressed(_ sender: Any) {
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.loginButton.isHidden = true
        if let mobile = mobileNumberTextField.text , let pass = passwordTextField.text {
            Auth.auth().signIn(withEmail: mobile, password: pass) { (user, error) in
                self.activityIndicator.stopAnimating()
                if let error = error {
                    self.showMessagePrompt(error.localizedDescription)
                    self.activityIndicator.isHidden = true
                    self.loginButton.isHidden = false
                    return
                }
                self.activityIndicator.isHidden = true
                self.performSegue(withIdentifier: Constants.storiesListSegueIdentifier, sender: self)
            }
        } else {
            self.activityIndicator.stopAnimating()
            self.loginButton.isHidden = false
            self.activityIndicator.isHidden = true
            self.showMessagePrompt(Constants.errorMessageForLogin)
        }
    }
    
    
    @IBAction func signInWithGoogleBtnTapped(_ sender: Any) {
        self.loginButton.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        Auth.auth().signIn(with: credentials!) { (user, error) in
            self.activityIndicator.stopAnimating()
            if let error = error {
                self.showMessagePrompt(error.localizedDescription)
                self.loginButton.isHidden = false
                self.activityIndicator.isHidden = true
                return
            }
            self.performSegue(withIdentifier: Constants.storiesListSegueIdentifier, sender: self)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        if textField === mobileNumberTextField {
            mobileNumberTextField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField{
            passwordTextField.resignFirstResponder()
        }
            return true
    }
    
    func showMessagePrompt(_ message: String){
        let alert = UIAlertController.init(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

