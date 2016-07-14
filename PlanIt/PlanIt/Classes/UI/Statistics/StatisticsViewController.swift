//
//  StatisticsViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/24.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, PieChartDataSource ,TagListViewDelegate, EditProjectTableViewDelegate{
    ///统计页面当前项目
    var project = Project()
    ///此项目的所有进度数据
    var processDates = [ProcessDate]()
    ///chart数据
    lazy var chartData = [Double]()
    ///chart标签
    lazy var chartLabel = [String]()
    
    var processDatesDicts = [[String : Int]]()
    var projectName = ""{
        didSet{
            self.title = projectName
        }
    }

    var lineChartViewFrame: CGRect{
        set{
            
        }
        get{
//            let staticRect = UIApplication.sharedApplication().statusBarFrame
//            let navRect =  self.navigationController?.navigationBar.frame
//            let height = self.view.bounds.height - staticRect.height - navRect!.height - 30 - 220
            return CGRectMake(0, 0, self.view.bounds.width, self.view.bounds.height / 2 - 30)
        }
    }
    
    @IBOutlet weak var prompLabel: UILabel!
    @IBOutlet weak var surplusLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tagListView: TagListView!{
        didSet{
            tagListView.delegate = self
            tagListView.textFont = UIFont.systemFontOfSize(12)
            tagListView.shadowRadius = 0
            tagListView.shadowOpacity = 0
            tagListView.shadowColor = UIColor.blackColor()
            tagListView.shadowOffset = CGSizeMake(1, 1)
            tagListView.alignment = .Left
            tagListView.textColor = UIColor.blackColor()
            tagListView.selectedTextColor = UIColor.blackColor()
            tagListView.textFont = tagFontinstatistics!
        }
    }
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var inforView: UIView!
    @IBOutlet weak var pieChartView: KDCircularProgress!{
        didSet{
//            pieChartView.dataSource = self
//            pieChartView.scale = 0.8
//            pieChartView.backgroundColor = UIColor.clearColor()
//            ///颜色
//            pieChartView.color = UIColor ( red: 0.4353, green: 0.8157, blue: 0.0, alpha: 1.0 )
//            ///外圈颜色 默认灰色
//            pieChartView.outGroundColor = UIColor(red: 239.0 / 255, green: 240.0 / 255, blue: 241.0 / 255, alpha: 1.0)
            pieChartView.startAngle = -90
            pieChartView.progressThickness = 0.5
            pieChartView.trackThickness = 0.5
            pieChartView.clockwise = true
            pieChartView.gradientRotateSpeed = 2
            pieChartView.roundedCorners = true
            pieChartView.glowMode = .NoGlow
            pieChartView.glowAmount = 0.9
            pieChartView.setColors(UIColor ( red: 0.4902, green: 0.9098, blue: 0.0627, alpha: 1.0 ) ,UIColor ( red: 0.4, green: 0.7294, blue: 0.0471, alpha: 1.0 ))
            pieChartView.trackColor = UIColor ( red: 0.9412, green: 0.9412, blue: 0.9412, alpha: 1.0 )
 
        }
    }
    @IBOutlet weak var lineChartView: UIView!
    
    // The type of the current graph we are showing.
    enum GraphType {
        case Dark
        case Dot
        case Pink
        
        mutating func next() {
            switch(self) {
            case .Dark:
                self = GraphType.Dot
            case .Dot:
                self = GraphType.Pink
            case .Pink:
                self = GraphType.Dark
            }
        }
    }
    
    ///曲线图
    var graphView: ScrollableGraphView!
    var currentGraphType = GraphType.Dark
    var graphConstraints = [NSLayoutConstraint]()
    var label = UILabel()
    var labelConstraints = [NSLayoutConstraint]()
    ///曲线图数据
    let numberOfDataItems = 29
    //lazy var data: [Double] = self.generateRandomData(self.numberOfDataItems, max: 50)
    //lazy var labels: [String] = self.generateSequentialLabels(self.numberOfDataItems, text: "FEB")
    
    
    func updateUI(){
        self.view.setNeedsDisplay()
        self.pieChartView.setNeedsDisplay()
    }
    
    // MARK: - View lifecye
    override func viewWillAppear(animated: Bool) {
        if let currentProject = Project().loadData(project.id){
            project = currentProject
            //根据project初始化程序
            processDates = ProcessDate().loadData(project.id)
            projectName = project.name
            tagListView.removeAllTags()
            for tag in project.tags{
                tagListView.addTag(tag.name)
            }
            //根据不同项目完成度
            switch project.isFinished {
            case .NotBegined:
                prompLabel?.text = "距离项目开始"
                let restString = project.beginTimeDate.compareCurrentTime()
                surplusLabel?.text = restString
                progressView.setProgress(0 , animated: false)
            case .NotFinished:
                prompLabel?.text = "距离项目截止"
                let restString = project.endTimeDate.compareCurrentTime()
                surplusLabel?.text = restString
                let timePercent = project.beginTimeDate.percentFromCurrentTime(project.endTimeDate)
                progressView.setProgress(Float(timePercent), animated: false)
            case .Finished:
                surplusLabel?.text = "已完成"
                progressView.setProgress(1 , animated: false)
            case .OverTime:
                prompLabel?.text = "超出项目截止"
                let restString = project.endTimeDate.compareCurrentTime()
                surplusLabel?.text = restString
                let timePercent = project.beginTimeDate.percentFromCurrentTime(project.endTimeDate)
                progressView.setProgress(Float(timePercent), animated: false)
            default:break
            }
//            pieChartView.animateFromAngle(0, toAngle: Double(project.percent) / 100 * 360, duration: 2) { completed in
//                if completed {
//                    print("animation stopped, completed")
//                } else {
//                    print("animation stopped, was interrupted")
//                }
//            }
            pieChartView.angle = Double(project.percent) / 100 * 360
            percentLabel.text = "\(Int(project.percent))%"
            percentLabel.sizeToFit()
            endTimeLabel.text = "截止：\(project.endTime)"
            loadProcessDate()
            drawLineChart()
            updateUI()
            
        }
        //修改样式
        self.navigationController?.navigationBar.barTintColor = otherNavigationBackground
        self.navigationController?.navigationBar.setBackgroundImage(nil, forBarMetrics: .Default)
        self.navigationController?.navigationBar.shadowImage = nil
        

    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //历史按钮
        let historyButton = UIButton(frame:CGRectMake(0, 0, 24, 24))
        historyButton.setImage(UIImage(named: "history"), forState: .Normal)
        historyButton.addTarget(self,action:Selector("openHistory"),forControlEvents:.TouchUpInside)
        let historyBarButton = UIBarButtonItem(customView: historyButton)
        
        //编辑项目按钮
        let editButton = UIButton(frame:CGRectMake(0, 0, 24, 24))
        editButton.setImage(UIImage(named: "edit"), forState: .Normal)
        editButton.addTarget(self,action:Selector("editProject"),forControlEvents:.TouchUpInside)
        let editBarButton = UIBarButtonItem(customView: editButton)
        
        //按钮间的空隙
        let gap = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil,
            action: nil)
        gap.width = 15;
        
        //用于消除右边边空隙，要不然按钮顶不到最边上
        let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil,
            action: nil)
        spacer.width = -10;
        
        let backButtom = UIBarButtonItem(image: UIImage(named: "back"), style: .Plain, target: self, action: "dismiss")
        //设置按钮
        self.navigationItem.rightBarButtonItems = [spacer, historyBarButton, gap, editBarButton]
        self.navigationItem.leftBarButtonItem = backButtom
        
        //setupConstraints()
        
        //addLabel(withText: "DARK (TAP HERE)")
    }
    
    func dismiss(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
     // MARK: - PercentForPieChart Delegate
    func percentForPieChartView(sneder: PieChartView) -> Double? {
        return 0
    }


    
    // MARK: - TagListView Delegate
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.selected = !tagView.selected
    }
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }

    
     //MARK: - Func
    ///读取进度数据
    func loadProcessDate(){
        
        chartData.removeAll()
        chartLabel.removeAll()
        
        processDates = ProcessDate().loadData(project.id)
        
        let beginDate = project.beginTimeDate
        let endDate = project.endTimeDate
        let days = beginDate.daysToEndDate(endDate)
        var date = beginDate
        if processDates.count == 0 {
            for var day = 0; day < days ; day++ {
                chartData.append(0)
                chartLabel.append(date.FormatToStringMMMMDD())
                date = date.increase1Day()!
            }
        }
        
        for var day = 0; day < days ; day++ {
            for processDate in processDates{
                if processDate.recordTimeDate == date {
                    //processDatesDicts.append([processDate.recordTime : Int(processDate.done)])
                    chartData.append(processDate.done)
                    chartLabel.append(date.FormatToStringMMMMDD())
                    break
                }else if processDate ==  processDates.last{
                    //processDatesDicts.append([date.FormatToStringYYYYMMDD() : 0])
                    chartData.append(0)
                    chartLabel.append(date.FormatToStringMMMMDD())
                }
            }
            date = date.increase1Day()!
        }
    }
    
    


    ///画直线图
    func drawLineChart(){
        if graphView == nil{
            graphView = ScrollableGraphView(frame: lineChartViewFrame)
            graphView = createDarkGraph(lineChartViewFrame)
            self.lineChartView.addSubview(graphView)
        }
        
        graphView.setData(chartData, withLabels: chartLabel)
        self.lineChartView.insertSubview(graphView, belowSubview: label)
    }
    
    ///打开历史页面
    func openHistory(){
        let historyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Processes") as!
            ProcessesTableViewController
        historyViewController.project = project
        historyViewController.title = "添加记录"
        historyViewController.view.backgroundColor = self.view.backgroundColor
        self.navigationController?.pushViewController(historyViewController, animated: true)
    }
    
    func editProject(){
        let editProjectViewController = self.storyboard?.instantiateViewControllerWithIdentifier("EditProject") as! EditProjectTableViewController
        editProjectViewController.title = "修改项目"
        editProjectViewController.delegate  = self
        editProjectViewController.tableState = .Edit
        editProjectViewController.view.backgroundColor = allBackground
        editProjectViewController.modalTransitionStyle = .CoverVertical
        let navController = UINavigationController.init(rootViewController: editProjectViewController)

        //状态栏和导航栏不透明
        navController.navigationBar.translucent = false
        //设计背景色
        navController.navigationBar.barTintColor = otherNavigationBackground

        //去除导航栏分栏线
//        navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = navigationTintColor
        navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        self.navigationController?.presentViewController(navController, animated: true, completion: nil)
        editProjectViewController.project = self.project
    }
    
    //MARK: - GraphView Func
    func didTap(gesture: UITapGestureRecognizer) {
        
        currentGraphType.next()
        
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        
        switch(currentGraphType) {
        case .Dark:
            addLabel(withText: "DARK")
            graphView = createDarkGraph(lineChartViewFrame)
        case .Dot:
            addLabel(withText: "DOT")
            graphView = createDotGraph(lineChartViewFrame)
        case .Pink:
            addLabel(withText: "PINK")
            graphView = createPinkMountainGraph(lineChartViewFrame)
        }
        
        //graphView.setData(data, withLabels: labels)
        self.view.insertSubview(graphView, belowSubview: label)
        
        setupConstraints()
    }
    
    private func createDarkGraph(frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame)
        
        graphView.backgroundFillColor = UIColor.clearColor()
        
        graphView.lineWidth = 1.5
        graphView.lineColor = UIColor ( red: 0.3059, green: 0.7059, blue: 0.9725, alpha: 1.0 )

        graphView.lineStyle = ScrollableGraphViewLineStyle.Smooth
        
        graphView.shouldFill = true
        graphView.fillType = ScrollableGraphViewFillType.Gradient
        graphView.fillColor = UIColor.colorFromHex("#555555")
        graphView.fillGradientType = ScrollableGraphViewGradientType.Linear
        graphView.fillGradientStartColor = UIColor ( red: 0.7188, green: 0.8874, blue: 0.9846, alpha: 1.0 )
        graphView.fillGradientEndColor = UIColor ( red: 0.9601, green: 0.984, blue: 0.9961, alpha: 1.0 )


        graphView.dataPointSpacing = 80
        graphView.dataPointSize = 2
        graphView.dataPointFillColor = UIColor ( red: 99 / 255, green: 180 / 255 , blue: 225 / 255, alpha: 1.0 )
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(8)
        graphView.referenceLineColor = UIColor ( red: 0.8118, green: 0.9333, blue: 1.0, alpha: 1.0 )
        graphView.referenceLineLabelColor = UIColor ( red: 0.6118, green: 0.6824, blue: 0.749, alpha: 1.0 )

        graphView.numberOfIntermediateReferenceLines = 3
        graphView.dataPointLabelColor = UIColor ( red: 0.6549, green: 0.7137, blue: 0.7725, alpha: 1.0 )
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.Elastic
        graphView.animationDuration = 1.5
        graphView.rangeMax = 50
        graphView.referenceLineNumberOfDecimalPlaces = 1
        graphView.shouldRangeAlwaysStartAtZero = true
        
        return graphView
    }
    
    private func createDotGraph(frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame:frame)
        
        graphView.backgroundFillColor = UIColor.colorFromHex("#00BFFF")
        graphView.lineColor = UIColor.clearColor()
        
        graphView.dataPointSize = 5
        graphView.dataPointSpacing = 80
        graphView.dataPointLabelFont = UIFont.boldSystemFontOfSize(10)
        graphView.dataPointLabelColor = UIColor.whiteColor()
        graphView.dataPointFillColor = UIColor.whiteColor()
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(10)
        graphView.referenceLineColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        graphView.referenceLineLabelColor = UIColor.whiteColor()
        graphView.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.Both
        
        graphView.numberOfIntermediateReferenceLines = 9
        
        graphView.rangeMax = 50
        
        return graphView
    }
    
    private func createPinkMountainGraph(frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame:frame)
        
        graphView.backgroundFillColor = UIColor.colorFromHex("#222222")
        graphView.lineColor = UIColor.clearColor()
        
        graphView.shouldFill = true
        graphView.fillColor = UIColor.colorFromHex("#FF0080")
        
        graphView.shouldDrawDataPoint = true
        graphView.dataPointSpacing = 80
        graphView.dataPointLabelFont = UIFont.boldSystemFontOfSize(10)
        graphView.dataPointLabelColor = UIColor.whiteColor()
        
        graphView.referenceLineThickness = 1
        graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(10)
        graphView.referenceLineColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        graphView.referenceLineLabelColor = UIColor.whiteColor()
        graphView.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.Both
        
        graphView.numberOfIntermediateReferenceLines = 1
        
        graphView.shouldAdaptRange = true
        
        graphView.rangeMax = 50
        
        return graphView
    }
    
    private func setupConstraints() {
        
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        
        let topConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1, constant: 0)
        
        //let heightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
        
        //graphConstraints.append(heightConstraint)
        
        self.view.addConstraints(graphConstraints)
    }
    
    /// 添加和更新图切换标签在屏幕的右上角
    private func addLabel(withText text: String) {
        
        label.removeFromSuperview()
        label = createLabel(withText: text)
        label.userInteractionEnabled = true
        
        let rightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -20)
        
        let topConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
        
        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40)
        let widthConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: label.frame.width * 1.5)
        
        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: "didTap")
        label.addGestureRecognizer(tapGestureRecogniser)
        
        self.view.insertSubview(label, aboveSubview: graphView)
        self.view.addConstraints([rightConstraint, topConstraint, heightConstraint, widthConstraint])
    }
    
    private func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        
        label.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
        
        label.text = text
        label.textColor = UIColor.whiteColor()
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.boldSystemFontOfSize(14)
        
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        
        return label
    }
    
    /// 数据生成
    private func generateRandomData(numberOfItems: Int, max: Double) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(random()) % max
            
            if(random() % 100 < 10) {
                randomNumber *= 3
            }
            
            data.append(randomNumber)
        }
        return data
    }
    
    private func generateSequentialLabels(numberOfItems: Int, text: String) -> [String] {
        var labels = [String]()
        for i in 0 ..< numberOfItems {
            labels.append("\(text) \(i+1)")
        }
        return labels
    }
    
    // MARK: - EditProjectTableViewDelegate
    func goBackAct(){
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    

}


    