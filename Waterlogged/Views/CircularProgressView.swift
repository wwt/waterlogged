import SwiftUI

struct CircularProgressView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let progress: CGFloat
    private let colors: [Color] = [.lightBlue, .purpleBlue]
    private var formattedProgress: String {
        String(format: "%.0f", progress * 100)
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.outlineBlue.opacity(0.2), lineWidth: 20)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(gradient: Gradient(colors: colors), startPoint: .topTrailing, endPoint: .bottomLeading),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round, miterLimit: .infinity, dash: [20, 0], dashPhase: 0)
            )
            .rotationEffect(.degrees(-90))
            .shadow(color: Color.darkBlueText.opacity(0.1), radius: 3, x: 0, y: 3)
            
            Text("\(formattedProgress)%")
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(colorScheme == .dark ? .lightBlue : .darkBlueText)
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    @State static var progress: CGFloat = 0.70
    
    static var previews: some View {
        CircularProgressView(progress: progress)
            .frame(width: 300, height: 300)
            .environment(\.colorScheme, .dark)
    }
}
