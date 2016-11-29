//
//  StatisticsViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/24.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit
import Popover
class StatisticsViewController: UIViewController, PieChartDataSource ,TagListViewDelegate, EditProjectTableViewDelegate, UITableViewDelegate, UITableViewDataSource {
    enum LineChartType{
        case year, month, week, day
    }
    ///查询数据日期
    var searchDate: Date = Date()
    ///表格类型
    var lineChartType: LineChartType = .day
    ///选中菜单
    var selectRow = 1
    ///统计页面当前项目
    var project = Project()
    ///此项目的所有进度数据
    var processDates = [ProcessDate]()
    ///chart数据
    lazy var chartData = [Double]()
    ///chart标签
    lazy var chartLabel = [String]()
    ///chart标题按钮
    @IBOutlet weak var chartTitleButton: UIButton!
    ///chart上一个按钮
    @IBOutlet weak var nextButton: UIButton!
    ///chart下一个按钮
    @IBOutlet weak var backButton: UIButton!
    ///菜单
    fileprivate var popover: Popover!
    ///菜单文字
    fileprivate var texts = [NSLocalizedString("Month", comment: ""), NSLocalizedString("Day", comment: "")]
    
    fileprivate var effectView :DynamicBlurView!
    ///菜单弹窗参数
    fileprivate var popoverOptions: [PopoverOption] = [
        .cornerRadius(5.0),
        .animation(.none)
    ]
    fileprivate var chartTitle = ""{
        didSet{
            chartTitleButton.setTitle(chartTitle, for: UIControlState())
        }
    }
    
    fileprivate var projectName = ""{
        didSet{
            self.title = projectName
        }
    }

    fileprivate var lineChartViewFrame: CGRect{
        get{
            if IS_IPHONE {
                return CGRect(x: 0, y: 64, width: self.view.bounds.width, height: 210 )
            }
            else {
                return CGRect(x: 0, y: 64, width: self.view.bounds.width, height: self.view.bounds.height - 531.0 )
            }
        }
    }
    
    fileprivate var effectViewFrame: CGRect{
        get{
            if IS_IPHONE {
                return CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 210 + 64)
            }
            else {
                return CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height - 531.0  + 64)
            }
        }
    }

    @IBOutlet weak var needLabel: UILabel!
    ///剩余每天完成的量 2 小时
    @IBOutlet weak var needFinishLabel: UILabel!
    ///已完成 50 / 100 小时
    @IBOutlet weak var doneLabel: UILabel!
    ///距离截止
    @IBOutlet weak var prompLabel: UILabel!
    ///距离截止 15天
    @IBOutlet weak var surplusLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var tagListView: TagListView!{
        didSet{
            tagListView.delegate = self
            tagListView.textFont = UIFont.systemFont(ofSize: 12)
            tagListView.shadowRadius = 0
            tagListView.shadowOpacity = 0
            tagListView.shadowColor = UIColor.black
            tagListView.shadowOffset = CGSize(width: 1, height: 1)
            tagListView.alignment = .left
            tagListView.textColor = UIColor.black
            tagListView.selectedTextColor = UIColor.black
            tagListView.textFont = tagFontinstatistics
        }
    }
    @IBOutlet weak var percentLabel: UILabel!
    ///截止：2016年12月12日
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
            pieChartView.glowMode = .noGlow
            pieChartView.glowAmount = 0.9
            pieChartView.set(colors: UIColor( red: 0.4902, green: 0.9098, blue: 0.0627, alpha: 1.0 ) ,UIColor ( red: 0.4, green: 0.7294, blue: 0.0471, alpha: 1.0 ))
            pieChartView.trackColor = UIColor ( red: 0.9412, green: 0.9412, blue: 0.9412, alpha: 1.0 )
 
        }
    }
    @IBOutlet weak var lineChartView: UIView!
    
    // The type of the current graph we are showing.
    enum GraphType {
        case dark
        case dot
        case pink
        
        mutating func next() {
            switch(self) {
            case .dark:
                self = GraphType.dot
            case .dot:
                self = GraphType.pink
            case .pink:
                self = GraphType.dark
            }
        }
    }
    
    ///曲线图
    var graphView: ScrollableGraphView!
    var currentGraphType = GraphType.dark
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
    
    // MARK: - View Lifecycle
    override func viewWillAppear(_ animated: Bool) {
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
            case .notBegined:
                prompLabel?.text = NSLocalizedString("Starts in", comment: "")
                let restString = project.beginTimeDate.compareCurrentTime()
                surplusLabel?.text = restString
                surplusLabel.changeTextAttributeByRange(NSMakeRange(restString.characters.count - 2, 2), font: UIFont.systemFont(ofSize: 17), color: UIColor.colorFromHex("#9D9D9D"))
                progressView.setProgress(0 , animated: false)
            case .notFinished:
                prompLabel?.text = NSLocalizedString("Due in", comment: "")
                let restString = project.endTimeDate.compareCurrentTime()
                surplusLabel?.text = restString
                surplusLabel.changeTextAttributeByRange(NSMakeRange(restString.characters.count - 2, 2), font: UIFont.systemFont(ofSize: 17), color: UIColor.colorFromHex("#9D9D9D"))
                let timePercent = project.beginTimeDate.percentFromCurrentTime(project.endTimeDate)
                progressView.setProgress(Float(timePercent), animated: false)
            case .finished:
                surplusLabel?.text = NSLocalizedString("Completed", comment: "")
                progressView.setProgress(1 , animated: false)
                project.percent = 100
            case .overTime:
                prompLabel?.text = NSLocalizedString("Overdue by", comment: "")
                let restString = project.endTimeDate.compareCurrentTime()
                surplusLabel?.text = restString
                surplusLabel.changeTextAttributeByRange(NSMakeRange(restString.characters.count - 2, 2), font: UIFont.systemFont(ofSize: 17), color: UIColor.colorFromHex("#9D9D9D"))
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

            //余下每天需完成
            needLabel.isHidden = false
            needFinishLabel.isHidden = false
            if project.type == .normal && project.isFinished == .notFinished{
                needLabel.text = NSLocalizedString("Left Daily Work", comment: "")
                let days = Date().daysToEndDate(project.endTimeDate)
                let times = (project.rest / Double(days)).toIntCarry()
                needFinishLabel.text = "\(times) " + project.unit
                needFinishLabel.changeTextAttributeByRange(NSMakeRange(needFinishLabel.text!.characters.count - project.unit.characters.count, project.unit.characters.count), font: UIFont.systemFont(ofSize: 17), color: UIColor.colorFromHex("#9D9D9D"))
            }else if project.type == .punch && project.isFinished == .notFinished{
                needLabel.text = NSLocalizedString("Left Daily Mark", comment: "")
                let days = Date().daysToEndDate(project.endTimeDate)
                let times = (project.rest / Double(days)).toIntCarry()
                needFinishLabel.text = "\(times) " + "✓"
                needFinishLabel.changeTextAttributeByRange(NSMakeRange(needFinishLabel.text!.characters.count - 2, 2), font: UIFont.systemFont(ofSize: 17), color: UIColor.colorFromHex("#9D9D9D"))
            }else{
                needLabel.isHidden = true
                needFinishLabel.isHidden = true
            }
            //已完成
            doneLabel.text = "\(Int(project.complete)) / \(Int(project.total)) " + project.unit
            let cutString = " / \(Int(project.total)) " + project.unit
            doneLabel.changeTextAttributeByRange(NSMakeRange(doneLabel.text!.characters.count - cutString.characters.count, cutString.characters.count), font: UIFont.systemFont(ofSize: 17), color: UIColor.colorFromHex("#9D9D9D"))
            //百分比
            pieChartView.angle = Double(project.percent) / 100 * 360            
            percentLabel.text = "\(Int(project.percent))%"
            //距离截止
            percentLabel.sizeToFit()
            endTimeLabel.text = NSLocalizedString("Due on ", comment: "") + project.endTimeShow
            //设置表格标题
            chartTitle = searchDate.FormatToStringYYYYMM()
            
            if searchDate.FormatToStringYYYYMM() == project.beginTimeDate.FormatToStringYYYYMM(){
                backButton.isEnabled = false
            }else{
                backButton.isEnabled = true
            }
            
            nextButton.isEnabled = false
            //画表格
            loadProcessData()
            updateUI()
            
        }
        //修改样式
        self.navigationController?.navigationBar.barTintColor = otherNavigationBackground
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        moveToToday()
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //历史按钮
        let historyButton = UIButton(frame:CGRect(x: 0, y: 0, width: 24, height: 24))
        historyButton.setImage(UIImage(named: "history"), for: UIControlState())
        historyButton.addTarget(self,action:#selector(StatisticsViewController.openHistory),for:.touchUpInside)
        let historyBarButton = UIBarButtonItem(customView: historyButton)
        
        //编辑项目按钮
        let editButton = UIButton(frame:CGRect(x: 0, y: 0, width: 24, height: 24))
        editButton.setImage(UIImage(named: "edit"), for: UIControlState())
        editButton.addTarget(self,action:#selector(StatisticsViewController.editProject),for:.touchUpInside)
        let editBarButton = UIBarButtonItem(customView: editButton)
        
        //按钮间的空隙
        let gap = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
            action: nil)
        gap.width = 15;
        
        //用于消除右边边空隙，要不然按钮顶不到最边上
        let spacer = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil,
            action: nil)
        spacer.width = -10;
        
        let backButtom = UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(StatisticsViewController.handleDismiss))
        //设置按钮
        self.navigationItem.rightBarButtonItems = [spacer, historyBarButton, gap, editBarButton]
        self.navigationItem.leftBarButtonItem = backButtom
        
        //修改progressView高度
        self.progressView.transform = CGAffineTransform(scaleX: 1.0, y: 4.5)
        self.progressView.trackTintColor = UIColor.colorFromHex("#F5F4F2")
        
        //setupConstraints()
        
        //addLabel(withText: "DARK (TAP HERE)")
        
        //修改chartTitleButton
        chartTitleButton.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        chartTitleButton.titleLabel!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
        chartTitleButton.imageView!.transform = CGAffineTransform(scaleX: -1.0, y: 1.0);
    }
    
    func handleDismiss(){
        self.navigationController?.popToRootViewController(animated: true)
    }
    
     // MARK: - PercentForPieChart Delegate
    func percentForPieChartView(_ sneder: PieChartView) -> Double? {
        return 0
    }


    
    // MARK: - TagListView Delegate
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag pressed: \(title), \(sender)")
        tagView.isSelected = !tagView.isSelected
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        print("Tag Remove pressed: \(title), \(sender)")
        sender.removeTagView(tagView)
    }

    
     //MARK: - Func
    ///更改表格类型
    @IBAction func changeType(_ sender: UIButton) {
        callChartMenu()
    }
    
    ///上一个
    @IBAction func back(_ sender: UIButton) {
        if lineChartType == .day{
            searchDate = searchDate.increaseMonths(-1)!
        }else if lineChartType == .month{
            searchDate = searchDate.increaseYears(-1)!
        }
        changeButtonEnabled()
        loadChartData()
        drawLineChart()
    }
    
    ///下一个
    @IBAction func next(_ sender: UIButton) {
        if lineChartType == .day{
            searchDate = searchDate.increaseMonths(1)!
        }else if lineChartType == .month{
            searchDate = searchDate.increaseYears(1)!
        }
        changeButtonEnabled()
        loadChartData()
        drawLineChart()
    }
    
    ///图表中移动到今天
    fileprivate func moveToToday(){
        if project.isFinished == .notBegined{
            return
        }
        if lineChartType == .day{
            if searchDate.FormatToStringYYYYMM() == Date().FormatToStringYYYYMM(){
                let offset = graphView.contentSize.width - graphView.bounds.size.width
                if offset > 0 {
                    graphView.setContentOffset(CGPoint( x: offset , y: 0), animated: true)
                    graphView.bouncesZoom = false
                }
                
            }
        }else if lineChartType == .month{
            if searchDate.FormatToStringYYYY() == Date().FormatToStringYYYY(){
                let offset = graphView.contentSize.width - graphView.bounds.size.width
                if offset > 0 {
                    graphView.setContentOffset(CGPoint( x: offset, y: 0), animated: true)
                    graphView.bouncesZoom = false
                }
            }
        }
    }
    
    fileprivate func addVisualEffectView(){
        if project.isFinished == .notBegined{
            
            if effectView == nil{
                effectView = DynamicBlurView(frame: effectViewFrame)
                
//                let blur = UIBlurEffect(style: .Light)                
//                effectView = UIVisualEffectView(effect: blur)
//                effectView.frame = effectViewFrame
//                
//                let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blur)
//                let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
//                vibrancyEffectView.frame = effectViewFrame
//                effectView.contentView.addSubview(vibrancyEffectView)

                let button = UIButton(type: .custom)
                button.setImage( UIImage(named: "timer"), for: UIControlState())
                button.setTitle(NSLocalizedString("  Not Started", comment: ""), for: UIControlState())
                button.setTitleColor(UIColor.colorFromHex("#AFAFAF"), for: UIControlState())
                button.titleLabel!.font = UIFont.systemFont(ofSize: 19)
                button.sizeToFit()
                button.center = effectView.center
                effectView.addSubview(button)
            }
            lineChartView.addSubview(effectView)
            effectView.blurRadius = 10
            chartTitleButton.isEnabled = false
        }else{
            chartTitleButton.isEnabled = true
        }
    }
    
    ///根据搜索的日期修改按钮状态
    func changeButtonEnabled(){
        if lineChartType == .day{
            if searchDate.FormatToStringYYYYMM() == Date().FormatToStringYYYYMM(){
                nextButton.isEnabled = false
            }else{
                nextButton.isEnabled = true
            }
            
            if searchDate.FormatToStringYYYYMM() == project.beginTimeDate.FormatToStringYYYYMM(){
                backButton.isEnabled = false
            }else{
                backButton.isEnabled = true
            }
        }else if lineChartType == .month{
            if searchDate.FormatToStringYYYY() == Date().FormatToStringYYYY(){
                nextButton.isEnabled = false
            }else{
                nextButton.isEnabled = true
            }
            if searchDate.FormatToStringYYYY() == project.beginTimeDate.FormatToStringYYYY(){
                backButton.isEnabled = false
            }else{
                backButton.isEnabled = true
            }
        }
    }
    
    ///更改现状图
    @IBAction func changeLineChart(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex{
        case 0:
            lineChartType = .month
        case 1:
            lineChartType = .week
        case 2:
            lineChartType = .day
        default:break
        }
        loadProcessData()
    }
    
    ///点击点开菜单
    func callChartMenu() {
        let tableView = UITableView(frame: CGRect(x: 0, y: 0, width: 130, height: 105 ))
        tableView.tableHeaderView = UIView(frame:CGRect(x: 0, y: 0, width: 130, height: 10))
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.separatorStyle = .none
        self.popover = Popover(options: self.popoverOptions, showHandler: nil, dismissHandler: nil)
        self.popover.show(tableView, fromView: chartTitleButton)
    }
    
    ///读取进度数据
    func loadChartData(){
        //清除之前的数据
        chartData.removeAll()
        chartLabel.removeAll()
        
        //按照日统计
        if lineChartType == .day{
            let beginDate = searchDate.getMonthBeginAndEnd().firstDay
            var endDate : Date?
            if searchDate.FormatToStringYYYYMM() != Date().FormatToStringYYYYMM(){
                endDate = searchDate.getMonthBeginAndEnd().lastDay
            }else{
                endDate = Date()
            }
            if beginDate != nil && endDate != nil {
                let days = beginDate!.daysToEndDate(endDate!) + 1
                var date = beginDate!.increaseDays(-1)!
                for _ in 0 ..< days  {
                    if processDates.count == 0 {
                        chartData.append(0)
                    }
                    for processDate in processDates{
                        if processDate.recordTimeDate == date {
                            chartData.append(processDate.done)
                            break
                        }else if processDate ==  processDates.last{
                            chartData.append(0)
                        }
                    }
                    chartLabel.append(date.FormatToStringDD())
                    date = date.increase1Day()!
                }
            }

            //按照周统计
        }else if lineChartType == .week{
            let beginDate = project.beginTimeDate
            let endDate = project.endTimeDate
            let weeks = beginDate.weeksToEndDate(endDate) + 2
            var date = project.beginTimeDate.increaseDays(-7)!
            for _ in 0 ..< weeks  {
                let weekString = date.FormatToStringYYYY() + "第\(date.getWeekOfYear())周"
                var total = 0.0
                for processDate in processDates{
                    if processDate.week == weekString {
                        total += processDate.done
                    }
                }
                chartData.append(total)
                chartLabel.append(weekString)
                date = date.increaseDays(7)!
            }
            
            //按照月统计
        }else if lineChartType == .month{
            let beginDate = searchDate.getYearBeginAndEnd().firstDay
            var endDate : Date?
            if searchDate.FormatToStringYYYY() != Date().FormatToStringYYYY(){
                endDate = searchDate.getYearBeginAndEnd().lastDay
            }else{
                endDate = Date().getMonthBeginAndEnd().lastDay
            }
            if beginDate != nil && endDate != nil {
                var date = beginDate!
                while date.FormatToStringYYYYMM() !=  endDate!.FormatToStringYYYYMM() {
                    var total = 0.0
                    let monthString = date.FormatToStringYYYYMM()
                    for processDate in processDates{
                        if processDate.month == monthString {
                            total += processDate.done
                        }
                    }
                    chartData.append(total)
                    chartLabel.append(date.FormatToStringMMMM())
                    date = date.increase1Month()!
                }
            }
        }

    }
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    ///读取进度数据
    func loadProcessData(){
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            [weak self] in
            //数据库加载数据
            self?.processDates = ProcessDate().loadData(self!.project.id)
            //加载表格数据
            self?.loadChartData()
            DispatchQueue.main.async{
                self?.indicator.stopAnimating()
                self?.drawLineChart()
                self?.indicator.isHidden = true
            }
        }
     }
    
    


    ///画直线图
    func drawLineChart(){        
        if effectView != nil{
            effectView.removeFromSuperview()
        }
        
        if graphView == nil{
            graphView = ScrollableGraphView(frame: lineChartViewFrame)
            graphView = createDarkGraph(lineChartViewFrame)
            self.lineChartView.addSubview(graphView)
        }
        graphView.backgroundColor = UIColor.white
        graphView.set(data: chartData, withLabels: chartLabel)
        self.lineChartView.insertSubview(graphView, belowSubview: label)
        //写标题
        if lineChartType == .day{
            chartTitle = searchDate.FormatToStringYYYYMM()
        }else if lineChartType == .month{
            chartTitle = searchDate.FormatToStringYYYY()
        }
        //移动到今天
        moveToToday()
        addVisualEffectView()
    }
    
    ///打开历史页面
    func openHistory(){
        let historyViewController = self.storyboard?.instantiateViewController(withIdentifier: "Processes") as!
            ProcessesTableViewController
        historyViewController.project = project
        historyViewController.title = NSLocalizedString("History", comment: "")
        historyViewController.view.backgroundColor = self.view.backgroundColor
        self.navigationController?.pushViewController(historyViewController, animated: true)
    }
    
    func editProject(){
        let editProjectViewController = self.storyboard?.instantiateViewController(withIdentifier: "EditProject") as! EditProjectTableViewController
        editProjectViewController.title = NSLocalizedString("Edit Project", comment: "")
        editProjectViewController.delegate  = self
        editProjectViewController.tableState = .edit
        editProjectViewController.view.backgroundColor = allBackground
        editProjectViewController.modalTransitionStyle = .coverVertical
        let navController = UINavigationController.init(rootViewController: editProjectViewController)

        //状态栏和导航栏不透明
        navController.navigationBar.isTranslucent = false
        //设计背景色
        navController.navigationBar.barTintColor = otherNavigationBackground

        //去除导航栏分栏线
//        navController.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: .Default)
//        navController.navigationBar.shadowImage = UIImage()
        navController.navigationBar.tintColor = navigationTintColor
        navController.navigationBar.titleTextAttributes = {navigationTitleAttribute}()
        self.navigationController?.present(navController, animated: true, completion: nil)
        editProjectViewController.project = self.project
    }
    
    //MARK: - GraphView Func
    func didTap(_ gesture: UITapGestureRecognizer) {
        
        currentGraphType.next()
        
        self.view.removeConstraints(graphConstraints)
        graphView.removeFromSuperview()
        
        switch(currentGraphType) {
        case .dark:
            addLabel(withText: "DARK")
            graphView = createDarkGraph(lineChartViewFrame)
        case .dot:
            addLabel(withText: "DOT")
            graphView = createDotGraph(lineChartViewFrame)
        case .pink:
            addLabel(withText: "PINK")
            graphView = createPinkMountainGraph(lineChartViewFrame)
        }
        
        //graphView.setData(data, withLabels: labels)
        self.view.insertSubview(graphView, belowSubview: label)
        
        setupConstraints()
    }
    
    fileprivate func createDarkGraph(_ frame: CGRect) -> ScrollableGraphView {
        let graphView = ScrollableGraphView(frame: frame)
        
        graphView.backgroundFillColor = UIColor.clear
        
        graphView.lineWidth = 1.5
        graphView.lineColor = UIColor ( red: 0.3059, green: 0.7059, blue: 0.9725, alpha: 1.0 )

        graphView.lineStyle = ScrollableGraphViewLineStyle.smooth
        
        graphView.shouldFill = true
        graphView.fillType = ScrollableGraphViewFillType.gradient
        graphView.fillColor = UIColor.colorFromHex("#555555")
        graphView.fillGradientType = ScrollableGraphViewGradientType.linear
        graphView.fillGradientStartColor = UIColor ( red: 0.7188, green: 0.8874, blue: 0.9846, alpha: 1.0 )
        graphView.fillGradientEndColor = UIColor ( red: 0.9601, green: 0.984, blue: 0.9961, alpha: 1.0 )


        graphView.dataPointSpacing = 80
        graphView.dataPointSize = 2
        graphView.dataPointFillColor = UIColor ( red: 99 / 255, green: 180 / 255 , blue: 225 / 255, alpha: 1.0 )
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
        graphView.referenceLineColor = UIColor ( red: 0.8118, green: 0.9333, blue: 1.0, alpha: 1.0 )
        graphView.referenceLineLabelColor = UIColor ( red: 0.6118, green: 0.6824, blue: 0.749, alpha: 1.0 )

        graphView.numberOfIntermediateReferenceLines = 3
        graphView.dataPointLabelColor = UIColor ( red: 0.6549, green: 0.7137, blue: 0.7725, alpha: 1.0 )
        
        graphView.shouldAnimateOnStartup = true
        graphView.shouldAdaptRange = true
        graphView.adaptAnimationType = ScrollableGraphViewAnimationType.elastic
        graphView.animationDuration = 1.5
        graphView.rangeMax = 50
        graphView.referenceLineNumberOfDecimalPlaces = 1
        graphView.shouldRangeAlwaysStartAtZero = true
        
        return graphView
    }
    
    fileprivate func createDotGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame:frame)
        
        graphView.backgroundFillColor = UIColor.colorFromHex("#00BFFF")
        graphView.lineColor = UIColor.clear
        
        graphView.dataPointSize = 5
        graphView.dataPointSpacing = 80
        graphView.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.dataPointLabelColor = UIColor.white
        graphView.dataPointFillColor = UIColor.white
        
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        graphView.referenceLineLabelColor = UIColor.white
        graphView.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        
        graphView.numberOfIntermediateReferenceLines = 9
        
        graphView.rangeMax = 50
        
        return graphView
    }
    
    fileprivate func createPinkMountainGraph(_ frame: CGRect) -> ScrollableGraphView {
        
        let graphView = ScrollableGraphView(frame:frame)
        
        graphView.backgroundFillColor = UIColor.colorFromHex("#222222")
        graphView.lineColor = UIColor.clear
        
        graphView.shouldFill = true
        graphView.fillColor = UIColor.colorFromHex("#FF0080")
        
        graphView.shouldDrawDataPoint = true
        graphView.dataPointSpacing = 80
        graphView.dataPointLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.dataPointLabelColor = UIColor.white
        
        graphView.referenceLineThickness = 1
        graphView.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 10)
        graphView.referenceLineColor = UIColor.white.withAlphaComponent(0.5)
        graphView.referenceLineLabelColor = UIColor.white
        graphView.referenceLinePosition = ScrollableGraphViewReferenceLinePosition.both
        
        graphView.numberOfIntermediateReferenceLines = 1
        
        graphView.shouldAdaptRange = true
        
        graphView.rangeMax = 50
        
        return graphView
    }
    
    fileprivate func setupConstraints() {
        
        self.graphView.translatesAutoresizingMaskIntoConstraints = false
        graphConstraints.removeAll()
        
        let topConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self.view, attribute: NSLayoutAttribute.left, multiplier: 1, constant: 0)
        
        //let heightConstraint = NSLayoutConstraint(item: self.graphView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Height, multiplier: 1, constant: 0)
        
        graphConstraints.append(topConstraint)
        graphConstraints.append(bottomConstraint)
        graphConstraints.append(leftConstraint)
        graphConstraints.append(rightConstraint)
        
        //graphConstraints.append(heightConstraint)
        
        self.view.addConstraints(graphConstraints)
    }
    
    /// 添加和更新图切换标签在屏幕的右上角
    fileprivate func addLabel(withText text: String) {
        
//        label.removeFromSuperview()
//        label = createLabel(withText: text)
//        label.userInteractionEnabled = true
//        
//        let rightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1, constant: -20)
//        
//        let topConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: 20)
//        
//        let heightConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: 40)
//        let widthConstraint = NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: label.frame.width * 1.5)
//        
//        let tapGestureRecogniser = UITapGestureRecognizer(target: self, action: Selector("didTap"))
//        label.addGestureRecognizer(tapGestureRecogniser)
//        
//        self.view.insertSubview(label, aboveSubview: graphView)
//        self.view.addConstraints([rightConstraint, topConstraint, heightConstraint, widthConstraint])
    }
    
    fileprivate func createLabel(withText text: String) -> UILabel {
        let label = UILabel()
        
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        label.text = text
        label.textColor = UIColor.white
        label.textAlignment = NSTextAlignment.center
        label.font = UIFont.boldSystemFont(ofSize: 14)
        
        label.layer.cornerRadius = 2
        label.clipsToBounds = true
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.sizeToFit()
        
        return label
    }
    
    /// 数据生成
    fileprivate func generateRandomData(_ numberOfItems: Int, max: Double) -> [Double] {
        var data = [Double]()
        for _ in 0 ..< numberOfItems {
            var randomNumber = Double(arc4random()).truncatingRemainder(dividingBy: max)
            
            if(arc4random() % 100 < 10) {
                randomNumber *= 3
            }
            
            data.append(randomNumber)
        }
        return data
    }
    
    fileprivate func generateSequentialLabels(_ numberOfItems: Int, text: String) -> [String] {
        var labels = [String]()
        for i in 0 ..< numberOfItems {
            labels.append("\(text) \(i+1)")
        }
        return labels
    }
    
    // MARK: - EditProjectTableViewDelegate
    func goBackAct(_ state: EditProjectBackState){
        switch state {
        case .editSucceess:
            callAlertSuccess(NSLocalizedString("Done!", comment: ""))
        case .deleteSucceess:
            self.navigationController?.popToRootViewController(animated: true)
        default:break
        }
        
        
    }
    // MARK: - UITableViewDataSource
    ///确认节数
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    ///确定每行高度
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    ///确定行数
    func tableView(_ tableView:UITableView, numberOfRowsInSection section:Int) -> Int {
        return 2
    }
    
    ///配置cell内容
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) ->
        UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = self.texts[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = navigationFontColor
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightLight)
        cell.selectionStyle = .none
        if (indexPath as NSIndexPath).row == selectRow{
            cell.accessoryType = .checkmark
        }else{
            cell.accessoryType = .none
        }
        return cell
    }
    
    //选中cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectRow == (indexPath as NSIndexPath).row {
            return
        }
        //去掉勾
        if let oldCell = tableView.cellForRow(at: IndexPath(row: selectRow, section: 0)){
            oldCell.accessoryType = .none
        }
        //打钩
        if let cell = tableView.cellForRow(at: indexPath){
            cell.accessoryType = .checkmark
            selectRow = (indexPath as NSIndexPath).row
            if  (indexPath as NSIndexPath).row == 0{
                lineChartType = .month
            }else if (indexPath as NSIndexPath).row == 1{
                lineChartType = .day
            }
        }
        
        //关闭谭传
        self.popover.dismiss()
        //更改表格
        changeButtonEnabled()
        loadProcessData()
    }
}

    
