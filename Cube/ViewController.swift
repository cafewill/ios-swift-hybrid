//
//  ViewController.swift
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate {

    var web: WKWebView!
    var refreshControl: UIRefreshControl!
    var indicator: UIActivityIndicatorView!

    override func viewDidLoad () {
        super.viewDidLoad ()
        Allo.i ("viewDidLoad", String (describing: self))

        self.view.backgroundColor = UIColor.red
        
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        // configuration.mediaTypesRequiringUserActionForPlayback = true
        configuration.preferences.setValue("TRUE", forKey: "allowFileAccessFromFileURLs")
        web = WKWebView(frame: self.view.bounds, configuration: configuration)
        
        web.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        web.isHidden = false
        web.uiDelegate = self
        web.navigationDelegate = self
        web.backgroundColor = UIColor.white
        web.autoresizesSubviews = true
        web.isMultipleTouchEnabled = true
        web.isUserInteractionEnabled = true
        web.allowsLinkPreview = false
        web.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        web.scrollView.delegate = self
        web.scrollView.decelerationRate = UIScrollView.DecelerationRate.normal
        self.view.addSubview(web)
        
        web.translatesAutoresizingMaskIntoConstraints = false
        if #available(iOS 11, *) {
            let guide = self.view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                web.topAnchor.constraint(equalTo: guide.topAnchor),
                web.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
                web.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                web.trailingAnchor.constraint(equalTo: guide.trailingAnchor)
            ])
        } else {
            let margins = self.view.layoutMarginsGuide
            NSLayoutConstraint.activate([
                web.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
                web.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
                web.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
                web.bottomAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor)
            ])
        }
        self.view.layoutIfNeeded()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.white
        self.refreshControl.backgroundColor = UIColor.red
        // self.refreshControl.backgroundColor = UIColorFromRGB(0xed1d24)
        self.refreshControl.addTarget (self, action: #selector(actionRefreshDelay), for: .valueChanged)
        web.scrollView.addSubview(self.refreshControl)
        
        indicator = UIActivityIndicatorView(style: .whiteLarge)
        if #available(iOS 13.0, *) {
            indicator.style = .large
        }
        indicator.isHidden = true
        indicator.stopAnimating()
        indicator.center = self.view.center
        indicator.color = UIColor.red

        self.view.addSubview(indicator)
        
        let swipeGestureLeft = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGestureLeft.delegate = self
        swipeGestureLeft.direction = .left
        web.addGestureRecognizer(swipeGestureLeft)
        
        let swipeGestureRight = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture(_:)))
        swipeGestureRight.delegate = self
        swipeGestureRight.direction = .right
        web.addGestureRecognizer(swipeGestureRight)
        
        self.loadSite()
        self.rotateFirebase()
    }

    func rotateNotification (_ userInfo: [AnyHashable: Any]) {
        Allo.i ("rotateNotification", String (describing: self))

        // 푸시 알림 기본 데이터
        if let aps = userInfo ["aps"] as? [AnyHashable: Any],
           let alert = aps ["alert"] as? [AnyHashable: Any],
           let title = alert ["title"] as? String,
           let message = alert ["body"] as? String {
            // 추가 데이터 (바로가기 링크)
            let optionalLink : String? = userInfo ["link"] as? String
            Allo.i ("Check [\(title)][\(message)][\(String (describing: optionalLink))]")
            if let link = optionalLink {
                if let check = URL(string: link), check.scheme != nil, check.host != nil {
                    UIApplication.shared.open (check, options: [:], completionHandler: nil)
                }
            }
        }
    }

    func rotateFirebase () {
        Allo.i ("rotateFirebase", String (describing: self))

        NotificationCenter.default.addObserver(self,
                                               selector: #selector (rotateToken (_:)),
                                               name: NSNotification.Name ("FCMToken"),
                                               object: nil)
    }
    
    @objc func rotateToken (_ notification: Notification) {
        Allo.i ("rotateToken", String (describing: self))

        if let token = notification.userInfo?["token"] as? String {
            registDevice (token)
        }
    }
    
    func registDevice (_ token: String) {
        Allo.i ("registDevice", String (describing: self))

        // 필요시 로컬 및 리모트 서버 연동하여 저장함
        Allo.i ("Check token [\(token)]")
    }
    
    func loadSite () {
        Allo.i ("loadSite", String (describing: self))
        
        loadLink (Allo.CUBE_SITE)
    }

    func loadLink (_ link: String) {
        Allo.i ("loadLink", String (describing: self))
        
        web.load (URLRequest(url: URL(string: link)!))
    }

    func openLink (_ link: String) {
        Allo.i ("openLink", String (describing: self))
        
        if let check = URL(string: link), check.scheme != nil, check.host != nil {
            UIApplication.shared.open(check, options: [:], completionHandler: nil)
        }
    }

    func actionPrev () {
        Allo.i ("actionPrev", String (describing: self))
        
        if web.canGoBack {
            web.goBack ()
        }
    }

    func actionNext () {
        Allo.i ("actionNext", String (describing: self))

        if web.canGoForward {
            web.goForward()
        }
    }

    @objc func actionRefresh () {
        Allo.i ("actionRefresh", String (describing: self))

        web.reload()
        refreshControl.endRefreshing()
    }

    @objc func actionRefreshDelay () {
        Allo.i ("actionRefreshDelay", String (describing: self))

        let delay: CGFloat = 0.50
        perform (#selector (actionRefresh), with: nil, afterDelay: TimeInterval (delay))
    }

    func showIndicator () {
        Allo.i ("showIndicator", String (describing: self))

        indicator.isHidden = false
        indicator.startAnimating()
        
        // 인디케이터는 1200 후 자동으로 없어짐 (로드가 빨리된다면 그전에 onPageFinished 에서 처리됨)
        // 간혹 웹페이지에서 로드 불가한 (css, js 등) 리소스로 인해 계속 로딩중 상태가 지속되는걸 방지하기 위함
        let delay: CGFloat = 1.500
        perform (#selector (hideIndicator), with: nil, afterDelay: TimeInterval (delay))
    }

    @objc func hideIndicator () {
        Allo.i ("hideIndicator", String (describing: self))

        indicator.isHidden = true
        indicator.stopAnimating ()
    }

    @objc func handleSwipeGesture (_ sender: UISwipeGestureRecognizer) {
        Allo.i ("handleSwipeGesture", String (describing: self))

        if sender.direction == .left {
            actionNext ()
        }
        if sender.direction == .right {
            actionPrev ()
        }
    }

    // #pragma mark - WKWebView UIDelegate
    /*
    func webView (_ webView: WKWebView, runOpenPanelWith parameters: WKOpenPanelParameters, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping ([URL]) -> Void) {
        Allo.i("webView / runOpenPanelWithParameters / initiatedByFrame / completionHandler \(String(describing: self))")
    }
     */

    func webView (_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        Allo.i ("webView / runJavaScriptAlertPanelWithMessage / initiatedByFrame / completionHandler", String (describing: self))
        
        let alertController = UIAlertController(title: NSLocalizedString("title_alert", comment: "Alert"), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("action_ok", comment: "Ok"), style: .cancel) { _ in
            completionHandler()
        })
        present (alertController, animated: true)
    }

    func webView (_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        Allo.i ("webView / runJavaScriptConfirmPanelWithMessage / initiatedByFrame / completionHandler", String (describing: self))

        let alertController = UIAlertController(title: NSLocalizedString("title_confirm", comment: "Confirm"), message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("action_ok", comment: "Ok"), style: .default) { _ in
            completionHandler(true)
        })
        alertController.addAction(UIAlertAction(title: NSLocalizedString("action_cancel", comment: "Cancel"), style: .cancel) { _ in
            completionHandler(false)
        })
        present (alertController, animated: true, completion: nil)
    }

    func webView (_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        Allo.i ("webView / runJavaScriptTextInputPanelWithPrompt / defaultText / initiatedByFrame / completionHandler", String (describing: self))
        
        let alertController = UIAlertController(title: prompt, message: "", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("action_ok", comment: "Ok"), style: .default, handler: { _ in
            let input = alertController.textFields?.first?.text
            completionHandler(input)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("action_cancel", comment: "Cancel"), style: .cancel, handler: { _ in
            completionHandler(nil)
        }))
        present (alertController, animated: true, completion: nil)
    }

    // MARK: - WKWebView WKNavigationDelegate

    func webView (_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        Allo.i ("webView / didStartProvisionalNavigation", webView.url as Any, String (describing: self))
        
        showIndicator ()
    }

    func webView (_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Allo.i ("webView / didFinish", webView.url as Any, String (describing: self))

        do {
            // hideIndicator()
        } catch let e {
            print("error: \(e.localizedDescription)")
        }
    }

    func webView (_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Allo.i ("webView / didFail / withError", webView.url as Any, String (describing: self))

        // hideIndicator()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        Allo.i ("webView / decidePolicyFor / decisionHandler", navigationAction.request.url?.absoluteString as Any, String (describing: self))

        // let requestString = navigationAction.request.url?.absoluteString
        decisionHandler(.allow)
    }
}

