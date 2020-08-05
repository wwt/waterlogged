import SwiftUI

struct CircularProgressView: View {
    var progress: CGFloat // TODO: - Add @Binding back
    
    private let colors: [Color] = [.lightBlue, .purpleBlue]
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.outlineBlue, lineWidth: 20)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: colors),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 20, lineCap: .round)
            ).rotationEffect(.degrees(-90))
            Circle()
                .frame(width: 20, height: 20)
                .foregroundColor(Color.lightBlue)
                .offset(y: -150)
        }.frame(idealWidth: 300, idealHeight: 300, alignment: .center)
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    @State static var progress: CGFloat = 0.70
    
    static var previews: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            CircularProgressView(progress: progress)
                .fixedSize()
        }
    }
}
