import Foundation
import RxSwift
import RxCocoa

class BaseViewController: UIViewController {
    //    var mSubscriptions: CompositeDisposable?
    //
    //    func addSubscription(subscription: Disposable){
    //        if(mSubscriptions == nil){
    //            mSubscriptions = CompositeDisposable()
    //        }
    //        if let mSub = mSubscriptions{
    //            mSub.addDisposable(subscription)
    //        }
    //    }
    //
    //    func unsubscribeAll(){
    //        if let mSub = mSubscriptions{
    //            mSub.dispose()
    //            mSubscriptions = nil
    //        }
    //
    //    }
    //
    //    override func viewWillDisappear(animated: Bool) {
    //        super.viewWillDisappear(animated)
    //        unsubscribeAll()
    //    }
    //
    ////    override func viewDidDisappear(animated: Bool) {
    ////        super.viewDidDisappear(animated)
    ////        unsubscribeAll()
    ////    }
    ////
    //    deinit{
    //        print("UNSUBSCRIBE ALL")
    //        unsubscribeAll()
    //    }
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
