



import UIKit

enum EnterError: Error {
    case pageNotFound(Int)
    case internalServerError(Int, String)
    case tooManyRequests
}

class NetWork {
   static let responses = [100, 404, 500, 429]
   static func request () -> Int {
       return responses.randomElement()!
   }
}

class NetWorkManger {
    func userRequest() throws -> String {
        let statusCode = NetWork.request()
        guard statusCode != 404 else { throw EnterError.pageNotFound(statusCode)}
        guard statusCode != 500 else { throw EnterError.internalServerError(statusCode, "internal server error")}
        guard statusCode != 429 else { throw EnterError.tooManyRequests }
        return "You can continue, setup was successful"
    }
}

class ViewController: UIViewController {
    
    let networkManager = NetWorkManger()
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var button: UIButton! {
        didSet {
            button.setTitle("Random", for: .normal)
            button.backgroundColor = .darkGray
            button.setTitleColor(.systemGray6, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
            button.layer.cornerRadius = 10
            button.layer.masksToBounds = true
        }
    }
    
    lazy var alertControllerRepeat: UIAlertController = {
    let alertController = UIAlertController(title: " ", message: " ", preferredStyle: .alert)
    var cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
    var repeatAction = UIAlertAction(title: "Repeat", style: .destructive) { _ in
        //        MARK:- Task №2
        self.loadUserAsyncWithResult { (result) in
            switch result {
            case .success(let succes):
                self.alertControllerSucces.title = "CONGRATULATIONS"
                self.alertControllerSucces.message = succes
                self.callAlertTwo()
            case .failure(let error):
                print(error)
            }
        }
    }
    alertController.addAction(cancelAction)
    alertController.addAction(repeatAction)
        return alertController
    }()
    
    lazy var alertControllerSucces: UIAlertController = {
    let alertController = UIAlertController(title: " ", message: " ", preferredStyle: .alert)
    var cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in }
    var continueAction = UIAlertAction(title: "Continue", style: .destructive) { _ in }
    alertController.addAction(cancelAction)
    alertController.addAction(continueAction)
        return alertController
    }()
    
    func callAlertTwo() {
        self.present(alertControllerSucces, animated: true, completion: nil)
    }
    func callAlert() {
        self.present(alertControllerRepeat, animated: true, completion: nil)
    }
    
    //        MARK:- Task №1
    func tryingToConnect() throws -> String {
        var succes: String = ""
        do {
            succes = try networkManager.userRequest()
        } catch EnterError.pageNotFound(let codeError) {
            alertControllerRepeat.title = "Error is \(codeError)"
            alertControllerRepeat.message = "Try to repeat"
            callAlert()
        } catch  let EnterError.internalServerError(code, reason) {
            alertControllerRepeat.title = "Error is \(code)"
            alertControllerRepeat.message = "Try to repeat, because \(reason)"
            callAlert()
    }
        return succes
    }
//        MARK:- Task №3
        func loadUserAsyncWithResult(completion: (Result< String, EnterError>) -> Void) {
            if let succes = try? tryingToConnect() {
                completion(.success(succes))
            } else {
                completion(.failure(.tooManyRequests))
            }
        }

        
    
    
    @IBAction func touchButton(_ sender: Any) {
        //        MARK:- Task №2
        loadUserAsyncWithResult { (result) in
            switch result {
            case .success(let succes):
            alertControllerSucces.title = "CONGRATULATIONS"
            alertControllerSucces.message = succes
            callAlertTwo()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
}


