//
//  StatisticsViewController.swift
//  PlanIt
//
//  Created by Ken on 16/5/24.
//  Copyright © 2016年 Ken. All rights reserved.
//

import UIKit

class StatisticsViewController: UIViewController, PieChartDataSource ,TagListViewDelegate , PNChartDelegate{
    var project = Project(){
        didSet{
            //根据project初始化程序
            processes = Process().loadData(project.id)
            projectName = project.name
            projectPercent = project.percent
            for tag in project.tags{
                tagListView.addTag(tag.name)
            }
            //根据不同项目完成度
            switch project.isFinished {
            case ProjectIsFinished.NotBegined:
                surplusLabel?.text = "未开始"
                progressView.setProgress(0 , animated: false)
            case ProjectIsFinished.NotFinished:
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
    var processes = [Process]()
    var projectName = ""{
        didSet{
            self.title = projectName
        }
    }
    
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
            pieChartView.backgroundColor = UIColor.clearColor()
        }
    }
    @IBOutlet weak var lineChartView: UIView!
    
    func updateUI(){
        self.view.setNeedsDisplay()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

    }
    
     // MARK: percentForPieChart Delegate
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
    
    //MARK: PNChart Delegate
    func userClickedOnLineKeyPoint(point: CGPoint, lineIndex: Int, keyPointIndex: Int)
    {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex) and point index is \(keyPointIndex)")
    }
    
    func userClickedOnLinePoint(point: CGPoint, lineIndex: Int)
    {
        print("Click Key on line \(point.x), \(point.y) line index is \(lineIndex)")
    }
    
    func userClickedOnBarChartIndex(barIndex: Int)
    {
        print("Click  on bar \(barIndex)")
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
            result += "延迟"
        }
        
        //判断时间
        if timeInterval < 60{
            result += "1分钟内"
        }else if timeInterval / 60 < 60 {
            tmp = Int(timeInterval)
            result += "\(tmp)分"
        }else if timeInterval / 60 / 60 < 24 {
            tmp = Int(timeInterval / 60)
            result += "\(tmp)小"
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
    
    func drawLineChart(){
        var lineChart:PNLineChart = PNLineChart(frame: CGRectMake(lineChartBound , view.bounds.height/2 - lineChartBound, view.bounds.width - 2 * lineChartBound, view.bounds.height / 2 - 2 * lineChartBound))
        lineChart.yLabelFormat = "%1.1f"
        lineChart.showLabel = false
        lineChart.backgroundColor = UIColor.clearColor()
        lineChart.xLabels = ["SEP 1","SEP 2","SEP 3","SEP 4","SEP 5","SEP 6","SEP 7"]
        lineChart.showCoordinateAxis = false
        lineChart.delegate = self
        
        // Line Chart Nr.1
        var data01Array: [CGFloat] = [60.1, 160.1, 126.4, 262.2, 186.2, 127.2, 176.2]
        var data01:PNLineChartData = PNLineChartData()
        data01.color = PNGreenColor
        data01.itemCount = data01Array.count
        data01.inflexionPointStyle = PNLineChartData.PNLineChartPointStyle.PNLineChartPointStyleCycle
        data01.getData = ({(index: Int) -> PNLineChartDataItem in
            var yValue:CGFloat = data01Array[index]
            var item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        lineChart.chartData = [data01]
        lineChart.strokeChart()
        
        //        lineChart.delegate = self
         view.addSubview(lineChart)
    }
}