//
//  DayProgressWidget.swift
//  DayProgressWidget
//
//  Created by Sachin Sampathkumar on 21/04/21.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of 60 entries an minute apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct DayProgressWidgetEntryView : View {
    
    private let maxValue: Double = 100;
    let progress : Double
    var textColor : Color
    
    init(entry: Provider.Entry) {
        progress = getProgress(currentDate: entry.date);
        
        switch Int(progress) {
        case 0..<25:
            textColor = Color.green
        case 25..<50:
            textColor = Color.yellow
        case 50..<75:
            textColor = Color.orange
        case 75..<100:
            textColor = Color.red
        default:
            textColor = Color.green
        }
        
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
                        .foregroundColor(textColor)
                        .bold()
                }
            }
        }
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
                    .stroke(lineWidth: self.lineWidth)
                    .foregroundColor(self.backgroundColor)
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

func getProgress(currentDate: Date) -> Double {
    let now = Calendar.current.dateComponents(in: .current, from: currentDate)
    
    var initialDate = currentDate
    var finalDate = currentDate
    
    let todayAtOne = DateComponents(year: now.year, month: now.month, day: now.day, hour: 1)
    let todayAtOneDate = Calendar.current.date(from: todayAtOne)!
    
    // If we are awake in the morning and not at night
    if(currentDate > todayAtOneDate) {
        let today = DateComponents(year: now.year, month: now.month, day: now.day, hour: 11)
        initialDate = Calendar.current.date(from: today)!
        let tomorrow = DateComponents(year: now.year, month: now.month, day: now.day! + 1, hour: 1)
        finalDate = Calendar.current.date(from: tomorrow)!
    } else {
        let yesterday = DateComponents(year: now.year, month: now.month, day: now.day! - 1, hour: 1)
        initialDate = Calendar.current.date(from: yesterday)!
        finalDate = todayAtOneDate
    }
    
    let totalDuration = finalDate.timeIntervalSince(initialDate)
    let currentRemainingDuration = currentDate.timeIntervalSince(initialDate)
    let percent = (currentRemainingDuration/totalDuration) * 100
    
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
        DayProgressWidgetEntryView(entry: SimpleEntry(date: Date()))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
