import SwiftUI

struct ContentViewa: View {
    @State private var scrollOffset: CGFloat = 0

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack {
                    ForEach(0..<20) { index in
                        Text("Item \(index)")
                            .padding()
                    }
                }
            }
            .background(
                GeometryReader { scrollProxy in
                    Color.clear
                        .onAppear {
                            self.scrollOffset = scrollProxy.frame(in: .global).minY
                        }
                }
            )
            .overlay(
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: 50, height: 50)
                    .offset(y: max(scrollOffset, 0))
            )
        }
    }
}

struct ContentViewa_Previews: PreviewProvider {
    static var previews: some View {
        ContentViewa()
    }
}
