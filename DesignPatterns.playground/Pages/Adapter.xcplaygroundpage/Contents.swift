/*:
 [Previous](@previous)&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Next](@next)
 
 # Adapter
 - - - - - - - - - -
 ![Adapter Diagram](Adapter_Diagram.png)
 
 The adapter pattern allows incompatible types to work together. It involves four components:
 
 1. An **object using an adapter** is the object that depends on the new protocol.
 
 2. The **new protocol** that is desired to be used.
 
 3. A **legacy object** that existed before the protocol was made and cannot be modified directly to conform to it.
 
 4. An **adapter** that's created to conform to the protocol and passes calls onto the legacy object.
 
 ## Code Example
 */
import UIKit

// MARK: - Legacy Object

class GoogleAuthenticator {
    func login(
        email: String,
        password: String,
        completion: @escaping (GoogleUser?, Error?) -> Void) {
        // Make networking calls that return a token string
        let token = "special-token-value"
        let user = GoogleUser(email: email,
                              password: password,
                              token: token)
        completion(user, nil)
    }
}

struct GoogleUser {
    var email: String
    var password: String
    var token: String
}

// MARK: - New Protocol

protocol AuthenticationService {
    func login(email: String,
               password: String,
               success: @escaping (User, Token) -> Void,
               failure: @escaping (Error?) -> Void)
}

struct User {
    let email: String
    let password: String
}

struct Token {
    let value: String
}

// MARK: - Adapter

class GoogleAuthenticatorAdapter: AuthenticationService {
    private var googleAuth = GoogleAuthenticator()
    
    func login(email: String,
               password: String,
               success: @escaping (User, Token) -> Void, failure: @escaping (Error?) -> Void) {
        googleAuth.login(email: email, password: password) { googleUser, error in
            guard let googleUser = googleUser, error == nil else {
                failure(error)
                return
            }
            
            let user = User(email: googleUser.email, password: googleUser.password)
            let token = Token(value: googleUser.token)
            
            success(user, token)
        }
    }
}

// MARK: - Object Using an Adapter

class LoginViewController: UIViewController {
    
    // MARK: - Properties
    
    var authService: AuthenticationService!
    
    // MARK: - Views
    
    var emailTextField = UITextField()
    var passwordTextField = UITextField()
    
    // MARK: - Class Constructors

    class func instance(with authService: AuthenticationService) -> LoginViewController {
        let viewController = LoginViewController()
        viewController.authService = authService
        return viewController
    }
    
    func login() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            print("Email and password are required inputs!")
            return
        }
        authService.login(
            email: email,
            password: password,
            success: { user, token in
                print("Auth succeeded: \(user.email), \(token.value)")
            },
            failure: { error in
                print("Auth failed with error: no error provided")
            })
    }
}

// MARK: - Example

let viewController = LoginViewController.instance(with: GoogleAuthenticatorAdapter())
viewController.emailTextField.text = "user@example.com"
viewController.passwordTextField.text = "password"
viewController.login()



// MARK: - Another Example

// MARK: - Legacy Object

protocol TextView {
    var isEmpty: Bool { get }
    func getOrigin() -> (x: CGFloat, y: CGFloat)
    func getExtent() -> (width: CGFloat, height: CGFloat)
}

// MARK: - Adapter

protocol Manipulator { }

protocol Shape {
    var isEmpty: Bool { get }
    func boundingBox() -> (topLeft: CGPoint, bottomRight: CGPoint)
    func createManipulator() -> Manipulator
}

class TextManipulator: Manipulator {
    private var textShape: TextShape
    
    init(_ textShape: TextShape) {
        self.textShape = textShape
    }
}

class TextShape: Shape {
    private var textView: TextView
    
    init(with textView: TextView) {
        self.textView = textView
    }
    
    var isEmpty: Bool {
        textView.isEmpty
    }
    
    func boundingBox() -> (topLeft: CGPoint, bottomRight: CGPoint) {
        let (x, y) = textView.getOrigin()
        let (width, height) = textView.getExtent()
        
        let topLeft = CGPoint(x: x, y: y)
        let bottomRight = CGPoint(x: x + width, y: y + height)
        return (topLeft, bottomRight)
    }
    
    func createManipulator() -> Manipulator {
        TextManipulator(self)
    }
}
