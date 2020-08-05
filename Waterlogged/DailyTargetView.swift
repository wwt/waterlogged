import SwiftUI

struct DailyTargetView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var dailyTarget: String
    
    var body: some View {
        VStack {
            Text("How much water do you want to drink each day?")
                .font(.headline)
                .foregroundColor(.darkBlueText)
            
            TextField("Enter amount in fl oz...", text: $dailyTarget){
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
            .background(Color(.displayP3, white: 1.0, opacity: 0.4))
            .cornerRadius(12)
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(LinearGradient(gradient: Gradient(colors: [.lightBlue, .purpleBlue]), startPoint: .topLeading, endPoint: .bottomTrailing))
        .edgesIgnoringSafeArea(.all)
    }
}

struct DailyTargetView_Previews: PreviewProvider {
    @State static var dailyTarget = "160"
    
    static var previews: some View {
        DailyTargetView(dailyTarget: $dailyTarget)
    }
}
