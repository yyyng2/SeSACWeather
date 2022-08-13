//
//  WeatherAPIManager.swift
//  SeSACWeather
//
//  Created by Y on 2022/08/13.
//

import Foundation
import CoreLocation

import Alamofire
import SwiftyJSON

class WeatherAPIManager{
    static let shared = WeatherAPIManager()
    private init(){}

    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?"
    
    struct Weather{
        var main: String
        var temp: Int
        var wind: Int
    }
    


    
    var stringArray: [Weather] = []
    
    func callRequest(lat: Double, lon: Double, completionHandler: @escaping ([Weather]) -> ()){
    
        let url = "\(weatherURL)lat=\(lat)&lon=\(lon)&appid=\(APIKey.openWeather)"
        
        AF.request(url, method: .get).validate().responseData { [self] response in
            switch response.result{
            case .success(let value):
                let json = JSON(value)
            
                
                let main = json["weather"][0]["main"].stringValue
                
                let temp = Int(json["main"]["temp"].doubleValue - 273.16)
                let wind = Int(json["wind"]["speed"].doubleValue)
       

                stringArray.append(Weather(main: main, temp: temp, wind: wind))
                
                completionHandler(stringArray)
   
            case .failure(let error):
                print(error)
            }
        }
    }
}

