import HealthKit
import SwiftUI

@main
struct WaterloggedApp: App {
    // TODO: - Use a StateObject or EnvironmentObject property wrapper here around a model or something.
    private var healthStore: HKHealthStore?
    
    var body: some Scene {
        WindowGroup {
            if HKHealthStore.isHealthDataAvailable() {
                WaterloggedView(healthStore: HKHealthStore())
            } else {
                HealthDataUnavailableView()
            }
        }
    }
}
