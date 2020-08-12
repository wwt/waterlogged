import HealthKit
import SwiftUI
import WidgetKit

final class WaterloggedModel: ObservableObject {
    @AppStorage("dailyTarget", store: UserDefaults(suiteName: "group.waterlogged")) var dailyTarget: String = ""
    @Published var amount = ""
    @Published var dailyTotal = 0.0
    @Published var progress: CGFloat = 0
    
    private let store: HKHealthStore
    private let typesToShare: Set<HKSampleType>  = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!]
    
    var remainingWater: Double {
        guard let dailyTarget = Double(dailyTarget) else { return 0 }
        
        if dailyTotal >= dailyTarget {
            return 0
        }
        
        return dailyTarget - dailyTotal
    }
    
    var formattedDailyTotal: String {
        String(format: "%.2f", dailyTotal)
    }
    
    var formattedRemainingWater: String {
        String(format: "%.2f", remainingWater)
    }
    
    init(_ store: HKHealthStore) {
        self.store = store
    }
    
    func loadWater() {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        var interval = DateComponents()
        interval.day = 1
        
        let calendar = Calendar.current
        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            let startDate = calendar.startOfDay(for: Date())
            
            results?.enumerateStatistics(from: startDate, to: Date()) { [weak self] result, stop in
                guard let self = self else { return }
                
                let sum = result.sumQuantity()?.doubleValue(for: HKUnit.fluidOunceUS()) ?? 0
                DispatchQueue.main.async {
                    self.dailyTotal = sum
                    self.progress = CGFloat(self.dailyTotal / (Double(self.dailyTarget) ?? 1))
                }
                print("Time: \(result.startDate), \(sum)")
            }
        }
        
        store.execute(query)
    }
    
    func logWater() {
        guard let amount = Int(amount) else { return }
        
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let quantityUnit = HKUnit(from: "fl_oz_us")
        let quantityAmount = HKQuantity(unit: quantityUnit, doubleValue: Double(amount))
        
        let date = Date()
        let sample = HKQuantitySample(type: quantityType, quantity: quantityAmount, start: date, end: date)
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)!
        let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType, start: date, end: date, objects: [sample])
        
        store.save(waterCorrelationForWaterAmount) { [weak self] success, error in
            guard let self = self else { return }
            
            if success {
                print("💧logging \(amount)💧")
                self.loadWater() // Reload water to set dailyProgress and update view
                WidgetCenter.shared.reloadAllTimelines()
            }
            
            if let error = error {
                print("Error occured requesting access to health data: \(error)")
            }
        }
    }
    
    func requestHealthAccess() {
        store.requestAuthorization(toShare: typesToShare, read: nil) { _, error in
            if let error = error {
                print("Error occured requesting access to health data: \(error)")
            }
        }
    }
}
