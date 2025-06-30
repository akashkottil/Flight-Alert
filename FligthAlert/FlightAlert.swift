import SwiftUI

struct FlightAlert : View {
    var body: some View {
        
//        if new your or not created any alerts yet then display FACreateView() otherwise display FAAlertVIew()
//        FAAlertView()
        FACreateView()
    }
}


#Preview {
    FlightAlert()
}
