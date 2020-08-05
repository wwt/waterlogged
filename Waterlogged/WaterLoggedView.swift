import HealthKit
import SwiftUI
import WidgetKit

struct WaterloggedView: View {
    // TODO: - Move these into a model and use @StateObject or @ObservedObject
    @AppStorage("dailyTarget", store: UserDefaults(suiteName: "group.waterlogged")) var dailyTarget: String = ""
    @State private var amount = ""
    @State private var dailyTotal = 0.0
    @State private var isShowingDetailView = false
    @State private var progress: CGFloat = 0
    
    private var remainingWater: Double {
        guard let dailyTarget = Double(dailyTarget) else { return 0 }
        
        if dailyTotal >= dailyTarget {
            return 0
        }
        
        return dailyTarget - dailyTotal
    }
    
    let fluidOunces = [4, 8, 12, 16, 20, 24, 28, 32, 36]
    var healthStore: HKHealthStore
    let typesToShare: Set<HKSampleType>  = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!]
    
    var body: some View {
        NavigationView {
            VStack {
                if !dailyTarget.isEmpty {
                    Text("Daily Target: \(dailyTarget) fl oz")
                        .font(.title)
                        .foregroundColor(.darkBlueText)
                        .padding()
                }
                
                CircularProgressView(progress: progress)
                    .fixedSize()
                
                let total = String(format: "%.2f", dailyTotal)
                Text("You've drank \(total) fl oz today!")
                    .font(.headline)
                    .foregroundColor(.darkBlueText)
                    .padding()
                
                if remainingWater != 0 {
                    let remaining = String(format: "%.2f", remainingWater)
                    Text("Drink \(remaining) more fl oz to meet your goal.")
                        .font(.headline)
                        .foregroundColor(.darkBlueText)
                        .padding()
                }
                
                Text("How much water did you drink (fl oz)?")
                    .font(.headline)
                    .foregroundColor(.darkBlueText)
                    .padding(.top)
                
                TextField("Enter amount in fl oz...", text: $amount) {
                    if let amount = Int(amount) {
                        logWater(amount)
                    }
                }
                .padding()
                .background(Color(.displayP3, white: 1.0, opacity: 0.4))
                .cornerRadius(12)
                .padding()
            }
            .onAppear {
                loadWater()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(LinearGradient(gradient: Gradient(colors: [.lightBlue, .purpleBlue]), startPoint: .topLeading, endPoint: .bottomTrailing))
            .edgesIgnoringSafeArea(.all)
            .navigationBarTitle("Waterlogged")
            .sheet(isPresented: $isShowingDetailView, content: {
                DailyTargetView(dailyTarget: $dailyTarget)
            })
            .navigationBarItems(trailing:
                Button("Set Target") {
                    isShowingDetailView.toggle()
                }
            )
        }
        .onAppear {
            requestHealthAccess()
        }
    }
    
    private func loadWater() {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        var interval = DateComponents()
        interval.day = 1
        
        let calendar = Calendar.current
        let anchorDate = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date())!
        
        let query = HKStatisticsCollectionQuery(quantityType: quantityType, quantitySamplePredicate: nil, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        
        query.initialResultsHandler = { query, results, error in
            let startDate = calendar.startOfDay(for: Date())
            
            results?.enumerateStatistics(from: startDate, to: Date(), with: { result, stop in
                let sum = result.sumQuantity()?.doubleValue(for: HKUnit.fluidOunceUS()) ?? 0
                dailyTotal = sum
                progress = CGFloat(dailyTotal / (Double(dailyTarget) ?? 1))
                print("Time: \(result.startDate), \(sum)")
            })
        }
        
        healthStore.execute(query)
    }
    
    private func logWater(_ amount: Int) {
        let quantityType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let quantityUnit = HKUnit(from: "fl_oz_us")
        let quantityAmount = HKQuantity(unit: quantityUnit, doubleValue: Double(amount))
        
        let date = Date()
        let sample = HKQuantitySample(type: quantityType, quantity: quantityAmount, start: date, end: date)
        let correlationType = HKObjectType.correlationType(forIdentifier: HKCorrelationTypeIdentifier.food)!
        let waterCorrelationForWaterAmount = HKCorrelation(type: correlationType, start: date, end: date, objects: [sample])
        
        healthStore.save(waterCorrelationForWaterAmount) { success, error in
            if success {
                print("💧logging \(amount)💧")
                loadWater() // Reload water to set dailyProgress and update view
                WidgetCenter.shared.reloadAllTimelines()
            }
            
            if let error = error {
                print("Error occured requesting access to health data: \(error)")
            }
        }
    }
    
    private func requestHealthAccess() {
        healthStore.requestAuthorization(toShare: typesToShare, read: nil) { _, error in
            if let error = error {
                print("Error occured requesting access to health data: \(error)")
            }
        }
    }
}

struct WaterloggedView_Previews: PreviewProvider {
    static var previews: some View {
        WaterloggedView(healthStore: HKHealthStore())
    }
}
