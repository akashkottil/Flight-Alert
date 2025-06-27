import SwiftUI

struct FACreate: View {
    var body: some View {
        VStack(spacing:30){
            Image("FALogoBlue")
            Text("Let us know your departure airports. we’ll customize the best flight deals for you!")
                .padding(.horizontal,40)
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
            Button(action: {
                // Your action here
                print("Pickup location tapped")
            }) {
                Text("Pick departure city")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .padding()
//                    .padding(.horizontal,20)
                    .frame(maxWidth: .infinity)
                    .background(Color("FABlue"))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 4)
            }
            .padding(.horizontal,30)
        }
    }
}


#Preview {
    FACreate()
}
