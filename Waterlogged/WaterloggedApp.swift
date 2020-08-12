import HealthKit
import SwiftUI

@main
struct WaterloggedApp: App {
    @StateObject var model = WaterloggedModel(HKHealthStore())
    
    var body: some Scene {
        WindowGroup {
            if HKHealthStore.isHealthDataAvailable() {
                WaterloggedView()
                    .environmentObject(model)
            } else {
                Text("Health data is unavailable.")
            }
        }
    }
}
