import HealthKit
import SwiftUI

struct WaterLoggedView: View {
    var fluidOunces = [4, 8, 12, 16, 20, 24, 28, 32, 36]
    var healthStore: HKHealthStore
    var typesToShare: Set<HKSampleType>  = [HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.dietaryWater)!]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Text("Waterlogged")
                .font(.title)
                .padding(.bottom, 200)
                .padding(.top, 80)
                .foregroundColor(Color(red: 27/256, green: 40/256, blue: 69/256))
            
            Text("How much water did you drink (fl oz)?")
                .font(.headline)
                .padding(.bottom, 20)
                .foregroundColor(Color(red: 27/256, green: 40/256, blue: 69/256))
            
            ScrollView {
                LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                    ForEach(fluidOunces, id: \.self) { fluidOunce in
                        Button(action: {
                            logWater(fluidOunce)
                        }) {
                            Text("\(fluidOunce)")
                                .frame(minWidth: 40, maxWidth: .infinity, minHeight: 40)
                        }
                        .foregroundColor(.white)
                        .frame(minWidth: 40, maxWidth: .infinity, minHeight: 40)
                        .padding(.all, 20)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 30/256, green: 59/256, blue: 112/256), Color(red: 41/256, green: 83/256, blue: 155/256)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(20)
                    }
                }
            }
        }
        .padding(.all, 40)
        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 8/256, green: 200/256, blue: 246/256), Color(red: 77/256, green: 93/256, blue: 251/256)]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: requestHealthAccess)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        WaterLoggedView(healthStore: HKHealthStore())
    }
}
