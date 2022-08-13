//
//  ViewController.swift
//  SeSACWeather
//
//  Created by Y on 2022/08/13.
//

import UIKit
import CoreLocation

import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var locationImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIView!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var windView: UIView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var chatLabel: UILabel!
    
    var locationManager = CLLocationManager()
    let center = [37.517829, 126.886270]
    let returnImage : [String : Any] = ["Clear":"clear", "Thunderstorm":"thunder", "Snow":"snow", "Clouds":"clouds", "Drizzle":"rain","Rain":"rain", "Mist":"atmosphere", "Smoke":"atmosphere", "Haze":"atmosphere", "Dust":"atmosphere", "Fog":"atmosphere", "Sand":"atmosphere", "Ash":"atmosphere", "Squall":"atmosphere", "Tornado":"atmosphere"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        designUI()
        designChatView()
        WeatherAPIManager.shared.callRequest(lat: center[0], lon: center[1]) { weather in
            print(weather)
            guard let returnImage = self.returnImage[weather[0].main] else { return }
            print(returnImage)
            self.weatherImage.image = UIImage(named: "\(returnImage)")
            self.tempLabel.text = "현재 온도는 \(weather[0].temp)°C 입니다."
            self.windLabel.text = "현재 풍속은 \(weather[0].wind)m/s 입니다."
        }
        getCurrentDate()
    }
    
    func getCurrentDate(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy. MM. dd   HH:mm"
        let nowDate = Date()
        let dateString = dateFormatter.string(from: nowDate)
        dateLabel.text = dateString
    }
    
  
    
    func showRequestLocationServiceAlert() {
      let requestLocationServiceAlert = UIAlertController(title: "위치정보 이용", message: "위치 서비스를 사용할 수 없습니다. 기기의 '설정>개인정보 보호'에서 위치 서비스를 켜주세요.", preferredStyle: .alert)
      let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
          if let appSetting = URL(string: UIApplication.openSettingsURLString){
              UIApplication.shared.open(appSetting)
          }
      }
      let cancel = UIAlertAction(title: "취소", style: .default)
      requestLocationServiceAlert.addAction(cancel)
      requestLocationServiceAlert.addAction(goSetting)
      
      present(requestLocationServiceAlert, animated: true, completion: nil)
    }
    

    
    func designUI(){
        view.backgroundColor = .systemMint
        dateLabel.clipsToBounds = true
        dateLabel.backgroundColor = .clear
        dateLabel.layer.cornerRadius = 10
        dateLabel.textAlignment = .center
        dateLabel.textColor = .white
        locationLabel.textColor = .white
        locationLabel.font = .systemFont(ofSize: 24)
        locationImageView.tintColor = .white
        refreshButton.tintColor = .white
        weatherImage.backgroundColor = .clear
        tempLabel.backgroundColor = .clear
        tempLabel.textColor = .black
        windLabel.backgroundColor = .clear
        windLabel.textColor = .black
        chatLabel.backgroundColor = .clear
        chatLabel.textColor = .black
    }
    
    func designChatView(){
        weatherImageView.backgroundColor = .white
        weatherImageView.clipsToBounds = true
        weatherImageView.layer.cornerRadius = 10
        tempView.clipsToBounds = true
        tempView.backgroundColor = .white
        tempView.layer.cornerRadius = 10
        windView.clipsToBounds = true
        windView.backgroundColor = .white
        windView.layer.cornerRadius = 10
        chatView.clipsToBounds = true
        chatView.backgroundColor = .white
        chatView.layer.cornerRadius = 10
        chatLabel.text = "좋은 하루 보내세요."
    }
    
    
    @IBAction func refreshButtonTapped(_ sender: UIButton) {

        locationManager.startUpdatingLocation()
   
    }
}
    


extension ViewController: CLLocationManagerDelegate{
    //유저의 위치정보 권한 여부
    func checkUserDeviceLocationServiceAuthorization(){
        
        let authorizationStatus: CLAuthorizationStatus
        //ios 14.0 이상이라면
        if #available(iOS 14.0, *){
            //인스턴스를 통해 locationManager가 가지고 있는 상태를 가져옴
            authorizationStatus = locationManager.authorizationStatus
        } else {
            authorizationStatus = CLLocationManager.authorizationStatus()
        }
        
        //"iOS 위치서비스 활성화" 여부 체크 : locationServicesEnabled()
        if CLLocationManager.locationServicesEnabled(){
            //위치 서비스가 활성화돼 있으므로 위치권한 요청이 가능해서 위치 권한을 요청(3)
            checkUserCurrentLocationAuthorization(authorizationStatus)
        } else {
            print("위치서비스가 꺼져있어 권한을 요청하지 못 합니다.")
        }
    }
    

    // 현재위치 업데이트 성공
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(#function, locations)
        
        if let coordinate = locations.last?.coordinate{
            WeatherAPIManager.shared.callRequest(lat: coordinate.latitude, lon: coordinate.longitude) { weather in
                guard let returnImage = self.returnImage[weather[0].main] else { return }
                self.weatherImage.image = UIImage(named: "\(returnImage)")
                self.tempLabel.text = "현재 온도는 \(weather[0].temp)°C 입니다."
                self.windLabel.text = "현재 풍속은 \(weather[0].wind)m/s 입니다."
            }
            getCurrentDate()

        }
        
        
        //위치 업데이트 멈춤
        locationManager.stopUpdatingLocation()
    }
    
    // 현재위치 업데이트 실패
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(#function)
    }
    
    // 사용자의 권한 상태가 바뀔때
 
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        print(#function)
        checkUserDeviceLocationServiceAuthorization()
    }
    // ios 14미만
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    // 유저의 위치에 대한 권한 설정 정보
    func checkUserCurrentLocationAuthorization(_ authorizationStatus: CLAuthorizationStatus){
        switch authorizationStatus {
        case .notDetermined:
            print("NotDetermined")
                                              //정확도 : kCLLocationAccuracy
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            
                            //앱을 사용하는 동안에 대한 위치 권한 요청, plist의 whenInUse 해줘야 -> request 메서드 사용 가능
            locationManager.requestWhenInUseAuthorization()
            

            
        case .restricted, .denied:
            print("Denied, 아이폰 설정으로 유도")
           
            showRequestLocationServiceAlert()
            
            WeatherAPIManager.shared.callRequest(lat: center[0], lon: center[1]) { weather in
                print(weather)
                guard let returnImage = self.returnImage[weather[0].main] else { return }
                print(returnImage)
                self.weatherImage.image = UIImage(named: "\(returnImage)")
                self.tempLabel.text = "현재 온도는 \(weather[0].temp)°C 입니다."
                self.windLabel.text = "현재 풍속은 \(weather[0].wind)m/s 입니다."
            }
            
        case .authorizedWhenInUse:
  
            locationManager.startUpdatingLocation()
            
        default: print("Default")
        }
    }
}
