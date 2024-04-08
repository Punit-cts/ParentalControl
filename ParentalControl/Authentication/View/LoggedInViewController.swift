//
//  LoggedInViewController.swift
//  CorenrollDemo
//
//  Created by Punit Thakali on 18/12/2023.
//

import UIKit

class LoggedInViewController: UIViewController, OTPVerificationViewModelDelegate, UITextFieldDelegate {
    
    var otpModel: OTPVerificationViewModel!
    let loginviewcontroller = LoginScreenViewController()
    
    @IBOutlet weak var otpTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.otpModel = OTPVerificationViewModel()
        self.otpModel.delegate = self
        self.otpTextField.delegate = self
        self.makeSpinnerforOTP()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == otpTextField, let text = textField.text,
           let range = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: range, with: string)
            return updatedText.count <= 4
        }
        return true
    }
    
    @IBAction func verifyOTPButton(_ sender: UIButton) {
        
        guard let enteredOTP = otpTextField.text, !enteredOTP.isEmpty else {
            showAlert(message: "Please enter OTP")
            return
        }
        
        if enteredOTP == "1111" {
            print("OTP verification successful")
            loadingOTPAlert.dismiss(animated: true)
        } else {
            showAlert(message: "The OTP you entered is incorrect. Please try again.")
        }
    }
    
    let loadingOTPAlert = UIAlertController(title: nil, message: "\n\nVerifying OTP", preferredStyle: .alert)
         
    private func makeSpinnerforOTP() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        loadingOTPAlert.view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: loadingOTPAlert.view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: loadingOTPAlert.view.topAnchor, constant: 30),
        ])
    }
    
    func didVerifyOTP(){
        
        DispatchQueue.main.async { [weak self] in
            
            self?.loadingOTPAlert.dismiss(animated: true)
            
        }
    }
    
    func OTPVerifyFailed(){
        
        DispatchQueue.main.async {
            
            self.loadingOTPAlert.dismiss(animated: true)
        }
        
        let failureOTPAlert = UIAlertController(title: "Verifying OTP Failed", message: nil, preferredStyle: .alert)
        failureOTPAlert.addAction(UIAlertAction(title: "Back", style: .default, handler: nil))
        present(failureOTPAlert, animated: true, completion: nil)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

