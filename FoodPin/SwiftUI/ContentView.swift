//
//  SwiftUIView.swift
//  FoodPin
//
//  Created by Makaveli Ohaya on 5/9/20.
//  Copyright © 2020 Makaveli Ohaya. All rights reserved.
//
import Foundation
import UIKit
import SwiftUI
import SDWebImageSwiftUI
import WebKit
import CoreLocation

struct HiddenNavigationBar: ViewModifier {
    func body(content: Content) -> some View {
        content
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
    }
}

extension View {
    func hiddenNavigationBarStyle() -> some View {
        modifier( HiddenNavigationBar() )
    }
}


struct ContentView: View {
    
    //@ObservedObject var obs = observer()

@ObservedObject var locationViewModel = LocationViewModel()
    
   
    
    var body: some View {
        ActivityIndicatorView(isDisplayed: .constant(true)) {
        VStack{
           
       
        NavigationView{
            
            List {
                
                
                
                ForEach(self.locationViewModel.datas, id: \.id) { data in
                    Card(image: data.image, name: data.name, weburl: data.webUrl)
                    
                }
                
            }.navigationBarTitle("Near By Restaurants").foregroundColor(/*@START_MENU_TOKEN@*/.red/*@END_MENU_TOKEN@*/)
            
            /*
            List(locationViewModel.datas){i in
                
                Card(image: i.image, name: i.name, weburl: i.webUrl) //rating: i.rating)
                
            }.navigationBarTitle("Near By Restaurants")
            */
        }
            
            }
        }
        
    }
    
}
 
struct ActivityIndicator : UIViewRepresentable {
  
    typealias UIViewType = UIActivityIndicatorView
    let style : UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> ActivityIndicator.UIViewType {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: ActivityIndicator.UIViewType, context: UIViewRepresentableContext<ActivityIndicator>) {
        uiView.startAnimating()
    }
  
}


struct ActivityIndicatorView<Content> : View where Content : View {
    
    @Binding var isDisplayed : Bool
    var content: () -> Content
    
    var body : some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                if (!self.isDisplayed) {
                    self.content()
                } else {
                    self.content()
                        .disabled(true)
                        .blur(radius: 3)
                    
                    VStack {
                        Text("LOADING")
                        ActivityIndicator(style: .large)
                    }
                    .frame(width: geometry.size.width/2.0, height: 200.0)
                    .background(Color.secondary.colorInvert())
                    .foregroundColor(Color.primary)
                    .cornerRadius(20)
                }
            }
        }
    }
    
    
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        
            
        
        ContentView()
        
    }
}

class observer : ObservableObject{
     
    @Published var datas = [datatype]()
    @ObservedObject var locationViewModel = LocationViewModel()
    init() {
        
        print("Latitude: \(locationViewModel.userLatitude)")
        print("Longitude: \(locationViewModel.userLongitude)")
        
        let url1 = "https://developers.zomato.com/api/v2.1/geocode?lat=\(locationViewModel.userLatitude)=\(locationViewModel.userLongitude)"
        let api = "64d2d705881152ccb8e4cfa15f6dc722"
        
        let url = URL(string: url1)
        var request = URLRequest(url: url!)
    
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue(api, forHTTPHeaderField: "user-key")
        request.httpMethod = "GET"
        
        let sess = URLSession(configuration: .default)
        sess.dataTask(with: request) { (data, _, _) in
            
            do{
                
                let fetch = try JSONDecoder().decode(Type.self, from: data!)
                print(fetch)
                
                for i in fetch.nearby_restaurants
                {
                    
                    
                    DispatchQueue.main.async {
                        
                        self.datas.append(datatype(id: i.restaurant.id, name: i.restaurant.name, image: i.restaurant.thumb, //rating: //i.restaurant.user_rating.aggregate_rating,//
                            webUrl: i.restaurant.url))
                    }

                }
            }
            catch{
                
               fatalError("Fetch Error: \(error.localizedDescription)")
                
            }
            
        }.resume()

    }
}

struct datatype : Codable,Identifiable {
    
    var id : String
    var name : String
    var image : String
 //   var rating : String
    var webUrl : String
}

struct Type : Decodable {
    
    var nearby_restaurants : [Type1]
}

struct Type1 : Decodable{
    
    
    var restaurant : Type2
}


struct Type2 : Decodable {
    
    var id : String
    var name : String
    var url : String
    var thumb : String
    
 //   var user_rating : Type3
}
struct Type3 : Decodable {
    
//    var aggregate_rating : Int
}


struct Card : View {
    
    var image = ""
    var name = ""
    var weburl = ""
  //  var rating = ""
    
    var body : some View{

        NavigationLink(destination: register(url: weburl, name: name)) {
            
            HStack{
                if image != "" {
                    AnimatedImage(url: URL(string: image)!).padding(.all).frame(width: 100, height: 100).cornerRadius(10)
                }
               
                
                VStack(alignment: .leading) {
                    
                    Text(name).fontWeight(.heavy)
               //     Text(rating)
                }.padding(.vertical, 10)
                
            }
        }
    }
}
struct register : View {
    
    var url = ""
    var name = ""
    
    var body : some View{
        
        WebView(url: url).navigationBarTitle(name)
    }
}



struct WebView : UIViewRepresentable {
    
    var url = ""
    
    func makeUIView(context: UIViewRepresentableContext<WebView>) -> WKWebView {
        
        let web = WKWebView()
        web.load(URLRequest(url: URL(string: url)!))
        return web
    }
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        
    }
}
