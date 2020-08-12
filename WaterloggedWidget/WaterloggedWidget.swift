import HealthKit
import SwiftUI
import WidgetKit

struct WaterloggedEntry: TimelineEntry {
    let date: Date
    let dailyTotal: Double
}

struct Provider: TimelineProvider {
    private let healthStore = HKHealthStore()
    private let typesToShare: Set<HKSampleType> = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!]
    
    func snapshot(with context: Context, completion: @escaping (WaterloggedEntry) -> ()) {
        let entry = WaterloggedEntry(date: Date(), dailyTotal: 0)
        completion(entry)
    }
    
    func timeline(with context: Context, completion: @escaping (Timeline<WaterloggedEntry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let status = healthStore.authorizationStatus(for: HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!)
        
        if status == .sharingAuthorized {
            loadWater { dailyTotal in
                let entry = WaterloggedEntry(date: currentDate, dailyTotal: dailyTotal)
                let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
                completion(timeline)
            }
        } else {
            let entry = WaterloggedEntry(date: currentDate, dailyTotal: 0)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
    
    private func loadWater(completion: @escaping (Double) -> Void) {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        var interval = DateComponents()
        interval.day = 1
        
        let calendar = Calendar.current
        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            let startDate = calendar.startOfDay(for: Date())
            
            var sum = 0.0
            
            results?.enumerateStatistics(from: startDate, to: Date()) { result, _ in
                sum += result.sumQuantity()?.doubleValue(for: HKUnit.fluidOunceUS()) ?? 0
            }
            
            completion(sum)
        }
        
        healthStore.execute(query)
    }
}

struct WidgetEntryView: View {
    @AppStorage("dailyTarget", store: UserDefaults(suiteName: "group.waterlogged")) var dailyTarget: String = ""
    @Environment(\.widgetFamily) var family
    let entry: Provider.Entry
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(
                    colors: [Color.lightBlue.opacity(0.6), Color.purpleBlue.opacity(0.6)]
                ),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            switch family {
            case .systemMedium:
                HStack {
                    let target = Double(dailyTarget) ?? 180 // This is nil coalesced specifically for previews to show the progress.
                    let progress = CGFloat(entry.dailyTotal / target)
                    CircularProgressView(progress: progress)
                        .padding()
                        .frame(width: 160, height: 160)
                    
                    VStack {
                        let total = String(format: "%.0f", entry.dailyTotal)
                        Text("\(total) fl oz drank today")
                            .font(.headline)
                            .foregroundColor(.darkBlueText)
                        
                        if entry.dailyTotal < target {
                            let remaining = String(format: "%.0f", target - entry.dailyTotal)
                            Text("Drink \(remaining) more fl oz to meet goal")
                                .font(.subheadline)
                                .foregroundColor(.darkBlueText)
                        }
                    }
                }
                .padding()
                
            default:
                Text("This is an unsupported use case.")
            }
        }
    }
}

@main
struct WaterloggedWidget: Widget {
    private let kind = "WaterloggedWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: kind,
            provider: Provider()
        ) { entry in
            WidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemMedium])
    }
}

struct WidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        WidgetEntryView(entry: Provider.Entry(date: Date(), dailyTotal: 40))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
