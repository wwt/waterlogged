import HealthKit
import SwiftUI
import WidgetKit

struct WaterloggedView: View {
    @ObservedObject var model: WaterloggedModel
    @State private var isShowingDetailView = false
    
    var body: some View {
        NavigationView {
            VStack {
                if !model.dailyTarget.isEmpty {
                    Text("Daily Target: \(model.dailyTarget) fl oz")
                        .font(.title)
                        .foregroundColor(.darkBlueText)
                        .padding()
                } else {
                    Text("Set a target to start tracking your water")
                        .font(.headline)
                        .foregroundColor(.darkBlueText)
                        .padding()
                }
                
                CircularProgressView(progress: model.progress)
                    .frame(width: 200, height: 200)
                
                Text("You've drank \(model.formattedDailyTotal) fl oz today!")
                    .font(.headline)
                    .foregroundColor(.darkBlueText)
                    .padding()
                
                if model.remainingWater != 0 {
                    Text("Drink \(model.formattedRemainingWater) more fl oz to meet your goal.")
                        .font(.headline)
                        .foregroundColor(.darkBlueText)
                        .padding()
                }
                
                VStack {
                    Text("How much water did you drink (fl oz)?")
                        .font(.headline)
                        .foregroundColor(.darkBlueText)
                    
                    TextField("Enter amount in fl oz...", text: $model.amount) {
                        model.logWater()
                    }
                    .padding()
                    .background(Color(.displayP3, white: 1.0, opacity: 0.4))
                    .cornerRadius(12)
                }
                .padding()
            }
            .onAppear {
                model.loadWater()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: [Color.lightBlue.opacity(0.6), Color.purpleBlue.opacity(0.6)]
                    ),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .ignoresSafeArea(.container)
            .navigationBarTitle("Waterlogged")
            .sheet(isPresented: $isShowingDetailView) {
                DailyTargetView(dailyTarget: $model.dailyTarget)
            }
            .navigationBarItems(trailing:
                Button("Set Target") {
                    isShowingDetailView.toggle()
                }
            )
        }
        .onAppear {
            model.requestHealthAccess()
        }
    }
}

struct WaterloggedView_Previews: PreviewProvider {
    static var previews: some View {
        WaterloggedView(model: WaterloggedModel(HKHealthStore()))
    }
}
