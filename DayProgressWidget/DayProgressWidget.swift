//
//  DayProgressWidget.swift
//  DayProgressWidget
//
//  Created by Sachin Sampathkumar on 21/04/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    @AppStorage("wakeUp", store: UserDefaults(suiteName: "group.com.sachin.DayProgress"))
    var wakeUpStoreData : Data = Data()
    
    @AppStorage("sleep", store: UserDefaults(suiteName: "group.com.sachin.DayProgress"))
    var sleepStoreData : Data = Data()
    
    func placeholder(in context: Context) -> TimeEntry {
        var wakeUp: Date = Date()
        var sleep: Date = Date()
        
        do {
            wakeUp = try JSONDecoder().decode(Date.self, from: wakeUpStoreData)
            sleep = try JSONDecoder().decode(Date.self, from: sleepStoreData)
        } catch {
            let currentTimeComponent = Calendar.current.dateComponents(in: .current, from: Date())
            wakeUp = Calendar.current.date(from: DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 7, minute: 30)) ?? Date()
            sleep = Calendar.current.date(from: DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 23, minute: 30)) ?? Date()
        }
        
        return TimeEntry(date: Date(), wakeUp: wakeUp, sleep: sleep)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TimeEntry) -> ()) {
        var wakeUp: Date = Date()
        var sleep: Date = Date()
        
        do {
            wakeUp = try JSONDecoder().decode(Date.self, from: wakeUpStoreData)
            sleep = try JSONDecoder().decode(Date.self, from: sleepStoreData)
        } catch {
            let currentTimeComponent = Calendar.current.dateComponents(in: .current, from: Date())
            wakeUp = Calendar.current.date(from: DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 7, minute: 30)) ?? Date()
            sleep = Calendar.current.date(from: DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 23, minute: 30)) ?? Date()
        }
        
        let entry = TimeEntry(date: Date(), wakeUp: wakeUp, sleep: sleep)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var wakeUp: Date = Date()
        var sleep: Date = Date()
        
        do {
            wakeUp = try JSONDecoder().decode(Date.self, from: wakeUpStoreData)
            sleep = try JSONDecoder().decode(Date.self, from: sleepStoreData)
        } catch {
            let currentTimeComponent = Calendar.current.dateComponents(in: .current, from: Date())
            wakeUp = Calendar.current.date(from: DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 7, minute: 30)) ?? Date()
            sleep = Calendar.current.date(from: DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 23, minute: 30)) ?? Date()
        }
        
        var entries: [TimeEntry] = []
        
        // Generate a timeline consisting of 60 entries an minute apart, starting from the current date.
        let currentDate = Date()
        for minutesOffSet in 0 ..< 6 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minutesOffSet * 10, to: currentDate)!
            let entry = TimeEntry(date: entryDate, wakeUp: wakeUp, sleep: sleep)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TimeEntry: TimelineEntry {
    var date: Date
    let wakeUp: Date
    let sleep: Date
}

struct PlaceHolderView : View {
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    ProgressCircle(value: Double(50),
                                   maxValue: 100,
                                   style: .line,
                                   backgroundEnabled: true,
                                   backgroundColor: .green,
                                   foregroundColor: .red,
                                   lineWidth: 10)
                        .frame(height: 100)
                    
                    Text("50%")
                        .font(.title)
                        .foregroundColor(Color.green)
                        .bold()
                }
            }
        }
    }
    
}

struct DayProgressWidgetEntryView : View {
    
    private let maxValue: Double = 100;
    var progress : Double
    var date : Date
    var wakeUp : Date
    var sleep : Date
    
    init(entry: Provider.Entry) {
        date = entry.date
        wakeUp = entry.wakeUp
        sleep = entry.sleep
        
        progress = getProgress(date: date, a: wakeUp, b: sleep)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    ProgressCircle(value: progress,
                                   maxValue: self.maxValue,
                                   style: .line,
                                   backgroundEnabled: true,
                                   backgroundColor: .green,
                                   foregroundColor: .red,
                                   lineWidth: 10)
                        .frame(height: 100)
                    
                    Text(String(Int(progress)) + "%")
                        .font(.title)
                        .foregroundColor(getTextColor(progressValue: Int(progress)))
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

func getProgress(date: Date, a: Date, b: Date) -> Double {
    let currentTime = date
    let currentTimeComponent = Calendar.current.dateComponents(in: .current, from: currentTime)
    
    let aComponent = Calendar.current.dateComponents(in: .current, from: a)
    let bComponent = Calendar.current.dateComponents(in: .current, from: b)
    
    let wakeUpDateComponent = DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: aComponent.hour, minute: aComponent.minute)
    let sleepDateComponent = DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: bComponent.hour, minute: bComponent.minute)
    
    var wakeUp = Calendar.current.date(from: wakeUpDateComponent)!
    var sleep = Calendar.current.date(from: sleepDateComponent)!
    
    let todayAtFour = DateComponents(year: currentTimeComponent.year, month: currentTimeComponent.month, day: currentTimeComponent.day, hour: 4)
    let todayAtFourDate = Calendar.current.date(from: todayAtFour)!
    
    // Check if user has set
    // 1. Sleep time between midnight and 4 AM
    // 2. You have crossed your wake up time
    // If so, push the sleep date to tomorrow
    if(sleep < todayAtFourDate && currentTime > wakeUp) {
        let tomorrowSleep = DateComponents(year: sleepDateComponent.year, month: sleepDateComponent.month, day: sleepDateComponent.day! + 1, hour: sleepDateComponent.hour, minute: sleepDateComponent.minute)
        sleep = Calendar.current.date(from: tomorrowSleep)!
    }
    
    // Check if user has set
    // 1. Sleep time between 4 AM and Midnight, basically user sleeps before midnight
    // 2. You have not crossed your sleep time
    // If so, push the wake up date to yesterday
    if(sleep < todayAtFourDate && currentTime < sleep) {
        let yesterdayWakeUp = DateComponents(year: wakeUpDateComponent.year, month: wakeUpDateComponent.month, day: wakeUpDateComponent.day! - 1, hour: wakeUpDateComponent.hour, minute: wakeUpDateComponent.minute)
        wakeUp = Calendar.current.date(from: yesterdayWakeUp)!
    }
    
    let totalDuration = sleep.timeIntervalSince(wakeUp)
    let currentRemainingDuration = currentTime.timeIntervalSince(wakeUp)
    let percent = (currentRemainingDuration/totalDuration) * 100
    
    // You are in your sleep cycle
    if(currentRemainingDuration < 0 && totalDuration < 0){
        return percent * -1
    }
    
    return percent
}

@main
struct DayProgressWidget: Widget {
    let kind: String = "DayProgressWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            DayProgressWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Day Progress")
        .description("This is to display the percentage of day already spent")
    }
}

struct DayProgressWidget_Previews: PreviewProvider {
    static var previews: some View {
        PlaceHolderView()
    }
}
