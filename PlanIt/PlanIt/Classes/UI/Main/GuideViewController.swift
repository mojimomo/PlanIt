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
        guideSocrollView.contentSize = CGSizeMake(width * 3, height)
        
        for i in 1...3{

            let imageView = UIImageView(frame: CGRect(x: width * CGFloat(i - 1), y: 0, width: width, height: height))
            //imageView.image = UIImage(named: "guide\(i)")
            if i == 1{
                imageView.image = UIImage.imageWithColor(UIColor.redColor(), size: CGSizeMake(width, height))
            }else if i == 2{
                 imageView.image = UIImage.imageWithColor(UIColor.greenColor(), size: CGSizeMake(width, height))
            }else{
                 imageView.image = UIImage.imageWithColor(UIColor.blueColor(), size: CGSizeMake(width, height))
            }
            
            guideSocrollView.addSubview(imageView)
        }
    }

    ///新增goButton按钮
    func addGoButton(){
        goButton = UIButton(frame: CGRect(x: width * 2 , y: height - 100 , width: 100, height: 35))
        goButton.center.x = self.view.center.x + width * 2
        goButton.setImage(UIImage(named: "goButton"), forState: .Normal)
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
        if currectPage == 2 {
            self.pageControl.hidden = true
            UIView.animateWithDuration(1.5, animations: {
                self.goButton.layer.opacity = 1
            })
        }else{
            UIView.animateWithDuration(1.5, animations: {
                self.goButton.layer.opacity = 0
                self.pageControl.hidden = false
            })
        }
        
        //设置页面控制器当前属性
        pageControl.currentPage = currectPage
    }

}
