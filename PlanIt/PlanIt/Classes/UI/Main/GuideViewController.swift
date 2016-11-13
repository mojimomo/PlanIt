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
    
    let width = UIScreen.main.bounds.width
    let height = UIScreen.main.bounds.height
    
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
        guideSocrollView.contentSize = CGSize(width: width * 4, height: height)
        
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
        goButton.setBackgroundImage(UIImage.imageWithColor(UIColor.colorFromHex("#FE6158"), size: CGSize( width: width, height: 60)), for: UIControlState())
        goButton.setBackgroundImage(UIImage.imageWithColor(UIColor.colorFromHex("#FF928C"), size: CGSize( width: width, height: 60)), for: .highlighted)
        goButton.setTitle(NSLocalizedString("Continue", comment: "引导页"), for: UIControlState())
        goButton.setTitleColor(UIColor.white,for: UIControlState()) //普通状态下文字的颜色
        goButton.setTitleColor(UIColor.white,for: .highlighted) //触摸状态下文字的颜色
        goButton.titleLabel?.font = goButtonFont
        goButton.addTarget(self, action: #selector(GuideViewController.handleGoMain), for: .touchUpInside)
        guideSocrollView.addSubview(goButton)
        //guideSocrollView.bringSubviewToFront(goButton)
        self.goButton.layer.opacity = 0
    }
    
    ///返回主页面
    func handleGoMain(){
        let mainPageVC = storyboard!.instantiateViewController(withIdentifier: "mainPage")
        self.present(mainPageVC, animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //获取当前显示页面
        let currectPage = Int(scrollView.contentOffset.x / width)
        
        //goButton淡出效果
        if currectPage == 3 {
            self.pageControl.isHidden = true
            UIView.animate(withDuration: 0.7, animations: {
                self.goButton.layer.opacity = 1
            })
        }else if  currectPage == 2{
            self.goButton.layer.opacity = 0
            UIView.animate(withDuration: 0.7, animations: {
                self.pageControl.isHidden = false
                //注册通知
                if IS_IOS8 {
                    let uns = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                    UIApplication.shared.registerUserNotificationSettings(uns)
                }
            })
        } else{
            self.goButton.layer.opacity = 0
            UIView.animate(withDuration: 0.7, animations: {
                self.pageControl.isHidden = false
            })
        }
        

        //设置页面控制器当前属性
        pageControl.currentPage = currectPage
    }

}
