//
//  ViewController.swift
//  WKWebViewTest
//
//  Created by DH on 2018. 3. 1..
//  Copyright © 2018년 test. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController {
    
    private weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentController = WKUserContentController()
        contentController.add(self, name: "test")
        
        let userScript = WKUserScript(source: "initNative()", injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        contentController.addUserScript(userScript)
        
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = contentController
        
        webView = WKWebView(frame: view.frame, configuration: configuration)
        webView.uiDelegate = self
        view.addSubview(webView)
        
        let localFile = Bundle.main.path(forResource: "test", ofType: "html") ?? "" // 반드시 존재하므로 그냥 처리
        let url = URL(fileURLWithPath: localFile)
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

extension ViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "test", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { _ in
            completionHandler()
        }
        alertController.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "test", message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { _ in
            completionHandler(false)
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "test" {
            if let dictionary: [String: String] = message.body as? Dictionary {
                if let action = dictionary["action"] {
                    if action == "bind", let name = dictionary["name"] {
                        if name == "message" {
                            let dateString = Date().description
                            webView.evaluateJavaScript("var \(name) = '\(dateString)';", completionHandler: nil)
                        }
                    } else if action == "call", let function = dictionary["function"] {
                        var returnMessage = ""
                        if function == "returnFunction" {
                            returnMessage = "나는 선택받은 function이다."
                        }
                        
                        webView.evaluateJavaScript("\(function)('\(returnMessage)')", completionHandler: nil)
                    }
                }
            } else if let message = message.body as? String {
                if message == "getMessage" {
                    webView.evaluateJavaScript("returnMessage('나는 function에 호출된 녀석입니다.');", completionHandler: nil)
                }
            }
        }
    }
}
