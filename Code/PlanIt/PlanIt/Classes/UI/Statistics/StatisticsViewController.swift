//
//  StatisticsViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/24.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, PieChartDataSource ,TagListViewDelegate {
    var project = Project(){
        didSet{
            //根据project初始化程序
            processDates = ProcessDate().loadData(project.id)
            projectName = project.name
            projectPercent = project.percent
            for tag in project.tags{
                tagListView.addTag(tag.name)
            }
            //根据不同项目完成度
            switch project.isFinished {
            case ProjectIsFinished.NotBegined:
                prompLabel?.text = "距离项目开始"
                let restString = compareCurrentTime(project.beginTimeDate)
                surplusLabel?.text = restString
                progressView.setProgress(0 , animated: false)
            case ProjectIsFinished.NotFinished:
                prompLabel?.text = "距离项目截止"
                let restString = compareCurrentTime(project.endTimeDate)
                surplusLabel?.text = restString
                let timePercent = percentFromCurrentTime(project.beginTimeDate, endDate: project.endTimeDate)
                progressView.setProgress(Float(timePercent), animated: false)
            case ProjectIsFinished.Finished:
                surplusLabel?.text = "已完成"
                progressView.setProgress(1 , animated: false)
            default:break
            }
            endTimeLabel.text = "截止：\(project.endTime)"
            drawLineChart()
            updateUI()
        }
    }
    
    let lineChartBound: CGFloat = 10
    var projectPercent = 0.0
    var processDates = [ProcessDate]()
    var processDatesDict = []
    var projectName = ""{
        didSet{
            self.title = projectName
        }
    }
    var lineChartViewFrame: CGRect{
        set{
            
        }
        get{
            return CGRectMake(0, self.view.bounds.height / 2, self.view.bounds.width, self.view.bounds.height / 2)
        }
    }
    
    @IBOutlet weak var prompLabel: UILabel!
    @IBOutlet weak var surplusLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tagListView: TagListView!{
        didSet{
            tagListView.delegate = self
            tagListView.textFont = UIFont.systemFontOfSize(15)
            tagListView.shadowRadius = 2
            tagListView.shadowOpacity = 0.4
            tagListView.shadowColor = UIColor.blackColor()
            tagListView.shadowOffset = CGSizeMake(1, 1)
            tagListView.alignment = .Left
        }
    }
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var inforView: UIView!
    @IBOutlet weak var pieChartView: PieChartView!{
        didSet{
            pieChartView.dataSource = self
            pieChartView.scale = 0.8
            pieChartView.backgroundColor = UIColor.clearColor()
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
    
    //曲线图
    var graphView = ScrollableGraphView()
    var currentGraphType = GraphType.Dark
    var graphConstraints = [NSLayoutConstraint]()
    var label = UILabel()
    var labelConstraints = [NSLayoutConstraint]()
    //曲线图数据
    let numberOfDataItems = 29
    lazy var data: [Double] = self.generateRandomData(self.numberOfDataItems, max: 50)
    lazy var labels: [String] = self.generateSequentialLabels(self.numberOfDataItems, text: "FEB")
    
    
    func updateUI(){
        self.view.setNeedsDisplay()
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
        editButton.addTarget(self,action:Selector("openHistory"),forControlEvents:.TouchUpInside)
        let editBarButton = UIBarButtonItem(customView: editButton)
        
        //按钮间的空隙
        let gap = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil,
            action: nil)
        gap.width = 15;
        
        //用于消除右边边空隙，要不然按钮顶不到最边上
        let spacer = UIBarButtonItem(barButtonSystemItem: .FixedSpace, target: nil,
            action: nil)
        spacer.width = -10;
        
        //设置按钮
        self.navigationItem.rightBarButtonItems = [spacer,editBarButton,gap,historyBarButton]
        
        //创建曲线图

        
        //setupConstraints()
        
        //addLabel(withText: "DARK (TAP HERE)")
    }
    
     // MARK: PercentForPieChart Delegate
    func percentForPieChartView(sneder: PieChartView) -> Double? {
        return projectPercent
    }


    
    // MARK: TagListView Delegate
    func tagPressed(title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.selected = !tagView.selected
    }
    
    func tagRemoveButtonPressed(title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }

    
     //MARK: Func
    //与现在时间比较
    func compareCurrentTime(compareDate: NSDate) -> String{
        var timeInterval = compareDate.timeIntervalSinceNow
        var result = ""
        var tmp = 0
        
        //判断是否是负
        if timeInterval < 0{
            timeInterval = -timeInterval
            prompLabel?.text = "超出项目截止"
        }
        
        //判断时间
        if timeInterval < 60{
            result += "1分钟内"
        }else if timeInterval / 60 < 60 {
            tmp = Int(timeInterval / 60 )
            result += "\(tmp)分"
        }else if timeInterval / 60 / 60 < 24 {
            tmp = Int(timeInterval / 60 / 24)
            result += "\(tmp)小时"
        }else if timeInterval / 60 / 60 / 24 < 30 {
            tmp = Int(timeInterval / 60 / 60 / 24 )
            result += "\(tmp)天"
        }else if timeInterval / 60 / 60 / 24 / 30 < 12 {
            tmp = Int(timeInterval / 60 / 60 / 24 / 30 )
            result += "\(tmp)月"
        }else{
            tmp = Int(timeInterval / 60 / 60 / 24 / 30 / 12)
            result += "\(tmp)年"
        }
        return result
    }
    
    //计算时间百分比
    func percentFromCurrentTime(beginDate: NSDate, endDate: NSDate) -> Double{
        let timeEnd = endDate.timeIntervalSince1970
        let timeBegin = beginDate.timeIntervalSince1970
        let currentDate = NSDate()
        let timecurrent = currentDate.timeIntervalSince1970
        let percent = (timecurrent - timeBegin)/(timeEnd - timeBegin)
        return percent
    }
    
    //画直线图
    func drawLineChart(){
        graphView = ScrollableGraphView(frame: lineChartViewFrame)
        graphView = createDarkGraph(lineChartViewFrame)
        
        graphView.setData(data, withLabels: labels)
        self.view.addSubview(graphView)
    }
    
    //打开历史页面
    func openHistory(){
        let historyViewController = self.storyboard?.instantiateViewControllerWithIdentifier("Processes") as!
            ProcessesTableViewController
        historyViewController.view.backgroundColor = self.view.backgroundColor
        self.navigationController?.pushViewController(historyViewController, animated: true)
    }
    
    //MARK: GraphView Func
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
        
        graphView.setData(data, withLabels: labels)
        self.view.insertSubview(graphView, belowSubview: label)
        
        setupConstraints()
    }
    
    private func createDarkGraph(frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame)
        
        graphView.backgroundFillColor = UIColor.colorFromHex("#333333")
        
        graphView.lineWidth = 1
        graphView.lineColor = UIColor.colorFromHex("#777777")
        graphView.lineStyle = ScrollableGraphViewLineStyle.Smooth
        
        graphView.shouldFill = true
        graphView.fillType = ScrollableGraphViewFillType.Gradient
        graphView.fillColor = UIColor.colorFromHex("#555555")
        graphView.fillGradientType = ScrollableGraphViewGradientType.Linear
        graphView.fillGradientStartColor = UIColor.colorFromHex("#555555")
        graphView.fillGradientEndColor = UIColor.colorFromHex("#444444")
        
        graphView.dataPointSpacing = 80
        graphView.dataPointSize = 2
        graphView.dataPointFillColor = UIColor.whiteColor()
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFontOfSize(8)
        graphView.referenceLineColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
        graphView.referenceLineLabelColor = UIColor.whiteColor()
        graphView.numberOfIntermediateReferenceLines = 5
        graphView.dataPointLabelColor = UIColor.whiteColor().colorWithAlphaComponent(0.5)
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.Elastic
        graphView.animationDuration = 1.5
        graphView.rangeMax = 50
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
        
        graphView.shouldDrawDataPoint = false
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
    
    // 添加和更新图切换标签在屏幕的右上角
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
    
    // 数据生成
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

}