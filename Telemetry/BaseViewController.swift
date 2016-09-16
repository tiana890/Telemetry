import Foundation
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {

    var disposeBag : DisposeBag?
    
    func addSubscription(subscription: Disposable){
        if(self.disposeBag == nil){
            self.disposeBag = DisposeBag()
        }
        disposeBag?.addDisposable(subscription)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.disposeBag = nil
    }
    
    deinit{
        print("DEINIT DISPOSABLE")
        self.disposeBag = nil
    }
}
