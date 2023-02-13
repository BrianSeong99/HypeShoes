//
//  ContentView.swift
//  frontend
//
//  Created by JIN WOO SEONG on 2023/2/12.
//

import SwiftUI
import Charts

struct AccelXChartData: Identifiable {
    let id = UUID()
    let AccelX: Int
    let Index: Int
}

extension AccelXChartData {
    static let accelXData: [AccelXChartData] = [
        .init(AccelX: 34, Index: 0),
        .init(AccelX: 175, Index: 1),
        .init(AccelX: 2, Index: 2),
        .init(AccelX: 265, Index: 3),
        .init(AccelX: 45, Index: 4),
        .init(AccelX: 26, Index: 5),
        .init(AccelX: 41, Index: 6),
    ]
}

//struct ShoeData {
//    let AccelX: Int
////    let AccelY: Int
////    let AccelZ: Int
////    let GyroX: Int
////    let GyroY: Int
////    let GyroZ: Int
////    let Pressure0: Int
////    let Pressure1: Int
////    let Pressure2: Int
////    let Pressure3: Int
////    let Pressure4: Int
//    let Time: Int64
//}

//class ViewController: UIViewController {
//
//  // Outlet for the line chart
//  @IBOutlet weak var lineChartView: LineChartView!
//
//  // Array to store chart data
//  var chartData = [ChartDataEntry]()
//
//  // Timer to update the chart every second
//  var updateTimer: Timer!
//
//  override func viewDidLoad() {
//    super.viewDidLoad()
//    // Populate the chart data array with initial values
//    for i in 0..<10 {
//      chartData.append(ChartDataEntry(x: Double(i), y: Double(i)))
//    }
//
//    // Start the update timer
//    updateTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateChartData), userInfo: nil, repeats: true)
//  }
//
//  // Method to update the chart data
//  @objc func updateChartData() {
//    // Append new data to the chart data array
//    chartData.append(ChartDataEntry(x: Double(chartData.count), y: Double.random(in: 0..<10)))
//
//    // Update the chart data set
//    let lineChartDataSet = LineChartDataSet(entries: chartData, label: "Line Chart Data")
//    lineChartDataSet.colors = [UIColor.red]
//    lineChartDataSet.lineWidth = 2.0
//    lineChartDataSet.drawCirclesEnabled = false
//
//    // Update the chart data
//    let lineChartData = LineChartData(dataSet: lineChartDataSet)
//    lineChartView.data = lineChartData
//  }
//
//}


struct LiveView: View {
    @State private var accelXData = AccelXChartData.accelXData
        
    var body: some View {
        VStack {
            Text("SmartShoes")
                .font(.largeTitle)
                .foregroundColor(.primary)
            Chart {
                ForEach(accelXData) { data in
                    LineMark(
                        x: .value("Index", data.Index),
                        y: .value("AccelX", data.AccelX)
                    )
                }
                .foregroundStyle(.orange.gradient)
                .interpolationMethod(.catmullRom)
            }
        }
        .padding()
    }
}

struct LiveView_Previews: PreviewProvider {
    static var previews: some View {
        LiveView()
    }
}
