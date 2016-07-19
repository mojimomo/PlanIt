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

        let backButtom = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: "dismiss")
        self.navigationItem.leftBarButtonItem = backButtom
        
        webView.delegate = self

        
        //设置初始加载网页
        let url = NSURL(string: "http://zoomyale.coding.me/markplan_tutorial/")
        let request = NSURLRequest(URL: url!)
        webView.loadRequest(request)
    }

    //开始加载网页
    func webViewDidStartLoad(webView: UIWebView) {
        print("start")
        indicator = WIndicator.showIndicatorAddedTo(self.navigationController!.view, animation: true)
        
    }
    
    //完成加载网页
    func webViewDidFinishLoad(webView: UIWebView) {
        print("finish")
        if indicator != nil && self.navigationController != nil{
            WIndicator.removeIndicatorFrom(self.navigationController!.view, animation: true)
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismiss(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
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
