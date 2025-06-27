import SwiftUI

struct AlertView: View {
    var body: some View {
        ZStack {
            GradientColor.BlueWhite
                .ignoresSafeArea()
            VStack {
                FAheader()
                ScrollView {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Today's price drop alerts")
                                .font(.system(size: 20, weight: .bold))
                            Text("Price dropped by at least 30%")
                                .font(.system(size: 14, weight: .regular))
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    
                    FACard()
                        .padding()
                    
                    // Add extra padding at bottom to prevent content from being hidden behind the button
                    Color.clear
                        .frame(height: 80)
                }
            }
            
            // Fixed bottom button
            VStack {
                Spacer()
                
                Button(action: {
                    // Add your action here
                    print("Add new alert tapped")
                }) {
                    HStack {
                        HStack{
                            Image("FAPlus")
                            Text("Add new alert")
                        }
                        .padding()
                         Rectangle()
                                         .fill(Color.white.opacity(0.4))
                                         .frame(width: 1, height: 50)
                        HStack{
                            Image("FAHamburger")
                        }
                        .padding()
                        
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 18))
                    .background(Color("FABlue"))
                    .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
            }
        }
    }
}

#Preview {
    AlertView()
}
