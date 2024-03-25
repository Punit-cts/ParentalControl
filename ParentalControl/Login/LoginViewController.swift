//
//  ViewController.swift
//  CorenrollDemo
//
//  Created by Punit Thakali on 11/12/2023.
//

import UIKit



class LoginViewController: UIViewController, UITextFieldDelegate, LoginViewModelDelegate, LoginVerificationViewModelDelegate{
    
    var loginviewModel: LoginViewModel!
    var loginverificationmodel: LoginVerificationViewModel!
    
    @IBOutlet weak var emailTextField: MaterialLikeTextField!
    @IBOutlet weak var passwordTextField: MaterialLikeTextField!
    @IBOutlet weak var biometricLoginButton: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let deviceidgenerated = generateDeviceID()                   //generates deviceID
        print(deviceidgenerated)
        
        self.makeSpinner()
        
        self.loginviewModel = LoginViewModel()
        self.loginviewModel.delegate = self
        
        self.loginverificationmodel = LoginVerificationViewModel()
        self.loginverificationmodel.delegate = self
        
    }
    
    private func setupViews() {
        
        self.emailTextField.backgroundColor = ThemeColor().BodyColor ?? UIColor.appF3F7FA
        self.emailTextField.setFieldLabel(with: "Email")
        self.emailTextField.setPlaceholderLabel(with: "Email")
        self.emailTextField.textField.keyboardType = .emailAddress
        self.emailTextField.textField.clearButtonMode = .whileEditing
        self.emailTextField.textField.delegate = self
        
        
        self.emailTextField.backgroundColor = ThemeColor().BodyColor ?? UIColor.appF3F7FA
        self.passwordTextField.setFieldLabel(with: "Password")
        self.passwordTextField.setPlaceholderLabel(with: "Password")
        self.passwordTextField.textField.keyboardType = .emailAddress
        self.emailTextField.textField.clearButtonMode = .whileEditing
        self.passwordTextField.textField.delegate = self
        self.passwordTextField.textField.isSecureTextEntry = true
        
        let passwordTrailingView = PasswordTrailingButton(frame: CGRect(x: 0, y: 0, width: 24.0, height: 24.0))
        passwordTrailingView.isSecureEntry = { (value) in
            self.passwordTextField.textField.isSecureTextEntry = value
        }
        self.passwordTextField.setTrailingItem(with: passwordTrailingView)
        
        self.biometricLoginButton.isHidden = true
        if let _ = AuthenticationWorker().getUser()?.user?.device_token ?? AuthCache.DeviceToken.get(), Authenticator.shared.isBiometricEnabled() {
            UIView.animate(withDuration: 0.2) {
                self.biometricLoginButton.isHidden = false
            }
        }
        
        switch Authenticator.shared.getBiometricType() {
        case .faceID:
            self.biometricLoginButton.setTitle("Tap here to login with face.", for: .normal)
            self.biometricLoginButton.setImage(UIImage(named: "biometric_face_icon"), for: .normal)
        case .touchID:
            self.biometricLoginButton.setTitle("Tap here to login with fingerprint.", for: .normal)
            self.biometricLoginButton.setImage(UIImage(named: "biometric_finger_icon"), for: .normal)
        default:
            self.biometricLoginButton.isHidden = true
        }
        
    }
    
    
    @IBAction func loginButton(_ sender: Any) {
        

        if validate(){
            
            self.present(loadingAlert, animated: true)
            
            let loginmodel  = LoginModel(email: self.emailTextField.text!, user_type: "A", password: self.passwordTextField.text!, device_id: self.generateDeviceID())
            self.loginviewModel.login(model: loginmodel)
            
            let verificationmodel = LoginVerificationModel(email: self.emailTextField.text!, data: "email", device_id: self.generateDeviceID())
            self.loginverificationmodel.loginverification(model: verificationmodel)
            
        }
        
        else{
            
            loginFailed()
            
        }
    }
    
    private func validate() -> Bool {
        guard var email = emailTextField.text, email != Strings.empty else {
            self.emailTextField.setErrorText(Strings.Authentication.required_field_error)
            return false
        }
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !email.isEmail {
            self.emailTextField.setErrorText(Strings.Authentication.invalid_email)
            return false
        }
        
        guard var password = passwordTextField.text, password != Strings.empty else {
            self.passwordTextField.setErrorText(Strings.Authentication.required_field_error)
            return false
        }
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return true
        
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        
    }
    
    let loadingAlert = UIAlertController(title: nil, message: "\n\nLogging In", preferredStyle: .alert)
    
    private func makeSpinner() {
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        loadingAlert.view.addSubview(spinner)
        
        NSLayoutConstraint.activate([
            
            spinner.centerXAnchor.constraint(equalTo: loadingAlert.view.centerXAnchor),
            spinner.topAnchor.constraint(equalTo: loadingAlert.view.topAnchor, constant: 30),
        ])
        
    }
    
    func didLoginSuccessfully() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.loadingAlert.dismiss(animated: true) {
                
                self?.performSegue(withIdentifier: "instantiate", sender: nil)
            }
        }
    }
    
    func loginFailed() {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.loadingAlert.dismiss(animated: true)
        }
        
        let failureAlert = UIAlertController(title: "Login Failed", message: nil, preferredStyle: .alert)
        failureAlert.addAction(UIAlertAction(title: "Back", style: .default, handler: nil))
        present(failureAlert, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {   //clears the alert label that appears
        return true
    }
    
    func generateDeviceID() -> String {                                             //generates the deviceID
        
        if let vendorID = UIDevice.current.identifierForVendor?.uuidString {
            
            return vendorID
        }
        else {
            
            return UUID().uuidString
        }
    }
}



