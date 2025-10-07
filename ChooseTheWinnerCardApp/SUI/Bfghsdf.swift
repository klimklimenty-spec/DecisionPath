
import Foundation
import SwiftUI

struct Bfghsdf: View {
   
   @ObservedObject var bbdsghjisddsiii: Oklhfhgshdjgf = Oklhfhgshdjgf()
   @State var gfdshg: Bool = true
   var body: some View {
       ZStack{
           Color.white
               .ignoresSafeArea()
               
           if let url = URL(string: UserDataManager.yhsbd.bsdhj ?? "") {
             

               Nbvsdjhbv(gggsdhvc: $gfdshg) {
                   Bvgdcs(url: url, webViewStateModel: bbdsghjisddsiii)
                       .background(Color.black.ignoresSafeArea())
                       .edgesIgnoringSafeArea(.bottom)
                       .onAppear{
                          
                           DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                               gfdshg = false

                           }
                           
                       }
               }
                       } else {
                           
                           ZStack{
                               Nbvsdjhbv(gggsdhvc: $gfdshg) {
                                   Bvgdcs(url:  URL(string: bbdsghjisddsiii.nnsadvb)!, webViewStateModel: bbdsghjisddsiii) .background(Color.black.ignoresSafeArea()).edgesIgnoringSafeArea(.bottom).onAppear{
                                       
                                   }
                               }
                               
                           }.onAppear{
                              
                               DispatchQueue.main.asyncAfter(deadline: .now() + 4.0){
                                   gfdshg = false
                               }
                           }
                                  
                              
                          
                       }
       }
   }
   
}

class UserDataManager {
   static let yhsbd = UserDataManager()
   
   var bsdhj: String?
   var nvdfhubv: String?
   var tqwubc: String?
}
