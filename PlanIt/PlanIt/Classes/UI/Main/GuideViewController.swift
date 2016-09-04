//
//  GuideViewController.swift
//  Markplan
//
//  Created by Ken on 16/8/14.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController , UIScrollViewDelegate{
    @IBOutlet weak var guideSocrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    var goButton : UIButton!
    
    let width = UIScreen.mainScreen().bounds.width
    let height = UIScreen.mainScreen().bounds.height
    
    //MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        guideSocrollView.delegate = self
        
        //设置导航图片
        setGuidePage()
        //新增goButton按钮
        addGoButton()
    }
    
    //MARK: - Func
    ///设置导航图片
    func setGuidePage(){
        guideSocrollView.contentSize = CGSizeMake(width * 4, height)
        
        for i in 1...4{

            let imageView = UIImageView(frame: CGRect(x: width * CGFloat(i - 1), y: 0, width: width, height: height))
            if IS_IPHONE{
                if width == 320 && height == 480 {
                    imageView.image = UIImage(named: "guide\(i)IP4")
                }else{
                    imageView.image = UIImage(named: "guide\(i)")
                }
            }else{
                imageView.image = UIImage(named: "guide\(i)iPad")
            }
            
            guideSocrollView.addSubview(imageView)
        }
    }

    ///新增goButton按钮
    func addGoButton(){
        goButton = UIButton(frame: CGRect(x: width * 3 , y: height - 60 , width: width, height: 60))
        goButton.center.x = self.view.center.x + width * 3
        goButton.setBackgroundImage(UIImage.imageWithColor(UIColor.colorFromHex("#FE6158"), size: CGSizeMake( width, 60)), forState: .Normal)
        goButton.setBackgroundImage(UIImage.imageWithColor(UIColor.colorFromHex("#FF928C"), size: CGSizeMake( width, 60)), forState: .Highlighted)
        goButton.setTitle("开始体验", forState: .Normal)
        goButton.setTitleColor(UIColor.whiteColor(),forState: .Normal) //普通状态下文字的颜色
        goButton.setTitleColor(UIColor.whiteColor(),forState: .Highlighted) //触摸状态下文字的颜色
        goButton.titleLabel?.font = goButtonFont
        goButton.addTarget(self, action: #selector(GuideViewController.handleGoMain), forControlEvents: .TouchUpInside)
        guideSocrollView.addSubview(goButton)
        //guideSocrollView.bringSubviewToFront(goButton)
        self.goButton.layer.opacity = 0
    }
    
    ///返回主页面
    func handleGoMain(){
        let mainPageVC = storyboard!.instantiateViewControllerWithIdentifier("mainPage")
        self.presentViewController(mainPageVC, animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        //获取当前显示页面
        let currectPage = Int(scrollView.contentOffset.x / width)
        
        //goButton淡出效果
        if currectPage == 3 {
            self.pageControl.hidden = true
            UIView.animateWithDuration(0.7, animations: {
                self.goButton.layer.opacity = 1
            })
        }else if  currectPage == 2{
            self.goButton.layer.opacity = 0
            UIView.animateWithDuration(0.7, animations: {
                self.pageControl.hidden = false
                //注册通知
                if IS_IOS8 {
                    let uns = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
                    UIApplication.sharedApplication().registerUserNotificationSettings(uns)
                }
            })
        } else{
            self.goButton.layer.opacity = 0
            UIView.animateWithDuration(0.7, animations: {
                self.pageControl.hidden = false
            })
        }
        

        //设置页面控制器当前属性
        pageControl.currentPage = currectPage
    }

}
