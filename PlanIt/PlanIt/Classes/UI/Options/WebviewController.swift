//
//  WebviewController.swift
//  PlanItOptions
//
//  Created by Yale on 16/7/3.
//  Copyright © 2016年 Yale. All rights reserved.
//

import UIKit

class WebviewController: UIViewController,UIWebViewDelegate {

    //使用指南的webview
    @IBOutlet var webView: UIWebView!
    var indicator: WActivityIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let backButtom = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(WebviewController.handleDismiss))
        self.navigationItem.leftBarButtonItem = backButtom
        self.title = NSLocalizedString("Tutorial",comment:"")
        
        webView.delegate = self

        
        //设置初始加载网页
        let url = URL(string: "http://zoomyale.coding.me/markplan_tutorial/")
        let request = URLRequest(url: url!)
        webView.loadRequest(request)
    }

    //开始加载网页
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("start")
        indicator = WIndicator.showIndicatorAddedTo(self.navigationController!.view, animation: true)
        
    }
    
    //完成加载网页
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("finish")
        if indicator != nil && self.navigationController != nil{
            WIndicator.removeIndicatorFrom(self.navigationController!.view, animation: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleDismiss(){
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if indicator != nil && self.navigationController != nil{
            WIndicator.removeIndicatorFrom(self.navigationController!.view, animation: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
