//
//  ContentView.swift
//  DayProgress
//
//  Created by Sachin Sampathkumar on 21/04/21.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    
    @AppStorage("wakeUp", store: UserDefaults(suiteName: "group.com.sachin.DayProgress"))
    var wakeUpStoreData : Data = Data()
    
    @AppStorage("sleep", store: UserDefaults(suiteName: "group.com.sachin.DayProgress"))
    var sleepStoreData : Data = Data()
    
    private let maxValue: Double = 100;
    @State private var wakeUp: Date = Date()
    @State private var sleep: Date = Date()
    
    init() {
        do {
            let storedWakeUp = try JSONDecoder().decode(Date.self, from: wakeUpStoreData)
            self._wakeUp = State(initialValue: storedWakeUp)
            let storedSleep = try JSONDecoder().decode(Date.self, from: sleepStoreData)
            self._sleep = State(initialValue: storedSleep)
        } catch {
            let currentTimeComponent = Calendar.current.dateComponents(in: .current, from: Date())
            let todayAtSeven = DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 7, minute: 30)
            let todayAtEleven = DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 23, minute: 30)
            
            guard let wakeUpEncode = try? JSONEncoder().encode(todayAtSeven) else {return}
            self.wakeUpStoreData = wakeUpEncode
            guard let sleepEncode = try? JSONEncoder().encode(todayAtEleven) else {return}
            self.sleepStoreData = sleepEncode
            
            self._wakeUp = State(initialValue: Calendar.current.date(from: todayAtSeven)!)
            self._sleep = State(initialValue: Calendar.current.date(from: todayAtEleven)!)
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Wake up")
                    .font(.body)
                    .foregroundColor(Color.green)
                
                DatePicker("Wake up", selection: $wakeUp, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .background(Color.gray)
                    .accentColor(Color.orange)
                    .labelsHidden()
                    .frame(width: 200, height: 80, alignment: .center)
                    .clipped()
                    .padding(.bottom, 20)
                    .onChange(of: wakeUp, perform:{ value in
                        guard let storeData = try? JSONEncoder().encode(value) else {return}
                        self.wakeUpStoreData = storeData
                        WidgetCenter.shared.reloadAllTimelines()
                    })
                
                Text("Sleep")
                    .font(.body)
                    .foregroundColor(Color.red)
                
                DatePicker("Sleep", selection: $sleep, displayedComponents: .hourAndMinute)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .background(Color.gray)
                    .accentColor(Color.orange)
                    .labelsHidden()
                    .frame(width: 200, height: 80, alignment: .center)
                    .clipped()
                    .padding(.bottom, 20)
                    .onChange(of: sleep, perform:{ value in
                        guard let storeData = try? JSONEncoder().encode(value) else {return}
                        self.sleepStoreData = storeData
                        WidgetCenter.shared.reloadAllTimelines()
                    })
                
                ZStack {
                    ProgressCircle(value: getProgress(a: wakeUp, b: sleep),
                                   maxValue: self.maxValue,
                                   style: .line,
                                   backgroundEnabled: true,
                                   backgroundColor: .green,
                                   foregroundColor: .red,
                                   lineWidth: 10)
                        .frame(height: 100)
                    
                    Text(String(Int(getProgress(a: wakeUp, b: sleep))) + "%")
                        .font(.title)
                        .foregroundColor(getTextColor(progressValue: Int(getProgress(a: wakeUp, b: sleep))))
                        .bold()
                }
            }
        }
    }
}

func getTextColor(progressValue: Int) -> Color {
    switch progressValue {
        case 0..<25:
            return Color.green
        case 25..<50:
            return Color.yellow
        case 50..<75:
            return Color.orange
        case 75..<100:
            return Color.red
        default:
            return Color.green
        }
}

struct ProgressCircle: View {
    enum Stroke {
        case line
        case dotted
        
        func strokeStyle(lineWidth: CGFloat) -> StrokeStyle {
            switch self {
            case .line:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round)
            case .dotted:
                return StrokeStyle(lineWidth: lineWidth,
                                   lineCap: .round,
                                   dash: [12])
            }
        }
    }
    
    private let value: Double
    private let maxValue: Double
    private let style: Stroke
    private let backgroundEnabled: Bool
    private let backgroundColor: Color
    private let foregroundColor: Color
    private let lineWidth: CGFloat
    
    init(value: Double,
         maxValue: Double,
         style: Stroke = .line,
         backgroundEnabled: Bool = true,
         backgroundColor: Color = Color.white,
         foregroundColor: Color = Color.black,
         lineWidth: CGFloat = 10) {
        self.value = value
        self.maxValue = maxValue
        self.style = style
        self.backgroundEnabled = backgroundEnabled
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            if self.backgroundEnabled {
                Circle()
                    .stroke(style: self.style.strokeStyle(lineWidth: self.lineWidth))
                    .foregroundColor(self.backgroundColor)
                    .rotationEffect(Angle(degrees: -90))
            }
            
            Circle()
                .trim(from: 0, to: CGFloat(self.value / self.maxValue))
                .stroke(style: self.style.strokeStyle(lineWidth: self.lineWidth))
                .foregroundColor(self.foregroundColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.easeIn)
        }
    }
}

func getProgress(a: Date, b: Date) -> Double {
    var wakeUp = a
    var sleep = b
    let wakeUpDateComponent = Calendar.current.dateComponents(in: .current, from: wakeUp)
    let sleepDateComponent = Calendar.current.dateComponents(in: .current, from: sleep)
    
    let currentTime = Date()
    let currentTimeComponent = Calendar.current.dateComponents(in: .current, from: currentTime)
    
    let todayAtFour = DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 4)
    let todayAtFourDate = Calendar.current.date(from: todayAtFour)!
    
    // Check if user has set
    // 1. Sleep time between midnight and 4 AM
    // 2. We have crossed 4 AM today
    // If so, push the sleep date to tomorrow
    if(sleep < todayAtFourDate && currentTime > todayAtFourDate) {
        let tomorrowSleep = DateComponents(year: sleepDateComponent.year, month: sleepDateComponent.month, day: sleepDateComponent.day! + 1, hour: sleepDateComponent.hour, minute: sleepDateComponent.minute)
        sleep = Calendar.current.date(from: tomorrowSleep)!
    }
    
    // Check if user has set
    // 1. Sleep time between 4 AM and Midnight, basically user sleeps before midnight
    // 2. We have crossed 4 AM today
    // If so, push the wake up date to yesterday
    if(sleep > todayAtFourDate && currentTime < todayAtFourDate) {
        let yesterdayWakeUp = DateComponents(year: wakeUpDateComponent.year, month: wakeUpDateComponent.month, day: wakeUpDateComponent.day! - 1, hour: wakeUpDateComponent.hour, minute: wakeUpDateComponent.minute)
        wakeUp = Calendar.current.date(from: yesterdayWakeUp)!
    }
    
    let totalDuration = sleep.timeIntervalSince(wakeUp)
    let currentRemainingDuration = currentTime.timeIntervalSince(wakeUp)
    let percent = (currentRemainingDuration/totalDuration) * 100
    
    return percent
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
