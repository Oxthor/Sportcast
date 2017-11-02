//
//  ForecastViewController.swift
//  Sportcast
//
//  Created by Alexandre Rubio on 8/10/17.
//  Copyright © 2017 Alexandre Rubio. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation
import WatchConnectivity

class ForecastViewController: UIViewController {
  
  let locationManager = CLLocationManager()
  var currentPlacemark: CLPlacemark?
  
  var session: WCSession? {
    didSet {
      if let session = session {
        session.delegate = self
        session.activate()
      }
    }
  }
 
  // Retrieve all forecast data except from current weather
  // Group them by date
  lazy var fetchedResultController: NSFetchedResultsController<Forecast> = {
    let predicate = NSPredicate(format: "current == false")
    let fetchRequest = Forecast.sortedFetchRequest(with: predicate)
    
    let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                         managedObjectContext: CoreDataStack.context,
                                         sectionNameKeyPath: #keyPath(Forecast.mediumDate),
                                         cacheName: nil)
    frc.delegate = self
    
    do {
      try frc.performFetch()
    } catch let error {
      print("Error: \(error.localizedDescription)")
    }
    
    return frc
  }()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var cityLabel: UILabel!
  @IBOutlet weak var temperatureLabel: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(cleanOldForecasts), name:
      NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    tableView.register(UINib(nibName: K.Cells.DateSectionHeader, bundle: nil), forHeaderFooterViewReuseIdentifier: K.Cells.DateSectionHeader)
    
    session = WCSession.default
    cleanOldForecasts()
    setupLocationManager()
    loadForecastData()
  }
  
  @objc func cleanOldForecasts() {
    Forecast.deleteAllBefore(date: Date())
  }

  func setupLocationManager() {
    self.locationManager.requestAlwaysAuthorization()
    self.locationManager.requestWhenInUseAuthorization()
    
    if CLLocationManager.locationServicesEnabled() {
      locationManager.delegate = self
      locationManager.distanceFilter = 100.0
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.startUpdatingLocation()
    }
  }
  
  func setupHeader(with city: String, temperature: String) {
    DispatchQueue.main.async {
      self.cityLabel.text = city
      self.temperatureLabel.text = temperature
    }
  }
  
  func loadForecastData() {
    guard let locality = currentPlacemark?.locality else { return }
    SportcastAPI.shared.getWeather(range: .threeHours, type: .cityName, value: locality) { result in
      switch result {
      case .failure(let error): print(error.description)
      case .success(let jsonList):
        let forecast = jsonList.flatMap({ Forecast.create(with: $0) })
        self.saveWatchData(forecast: Array(forecast.prefix(upTo: K.Values.WatchForecastItems)))
      }
    }
    
    SportcastAPI.shared.getWeather(range: .current, type: .cityName, value: locality) { result in
      switch result {
      case .failure(let error): print(error.description)
      case .success(let jsonList):
        guard let currentWeather: Forecast = jsonList.flatMap({
          let forecast = Forecast.create(with: $0)
          forecast?.current = true
          return forecast
        }).first else { return }
        self.setupHeader(with: locality, temperature: currentWeather.temperatureFormatted)
      }
    }
  }
  
  func saveWatchData(forecast: [Forecast]) {
    if let session = session {
      let message = [K.Watch.UserDefaults.Time: forecast.map{ $0.time },
                     K.Watch.UserDefaults.Temperature: forecast.map{ $0.temperatureFormatted },
                     K.Watch.UserDefaults.Wind: forecast.map{ $0.windSpeedFormatted },
                     K.Watch.UserDefaults.Precipitation: forecast.map{ $0.precipitation.description }]
      
      session.sendMessage(message, replyHandler: nil, errorHandler: { (error) in
        print("MESSAGE SENDER ERROR: \(error.localizedDescription)")
      })
    }
  }
}

// MARK: WCSessionDelegate
extension ForecastViewController: WCSessionDelegate {
  func sessionDidBecomeInactive(_ session: WCSession) {
    print("INACTIVE!!!!!")
  }
  
  func sessionDidDeactivate(_ session: WCSession) {
    print("DEACTIVATED!!!!")
  }
  
  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error = error {
      print(error.localizedDescription)
      return
    }
    
    print("ACTIVATED!!!!")
  }
}

// MARK: UITableViewDataSource
extension ForecastViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: K.Cells.ForecastCell) as! ForecastCell
    cell.configure(with: fetchedResultController.object(at: indexPath))
    return cell
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    guard let sections = fetchedResultController.sections else { return 0 }
    return sections.count
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = fetchedResultController.sections?[section] else { return 0 }
    return section.numberOfObjects
  }
}

// MARK: UITableViewDelegate
extension ForecastViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    guard let sectionInfo = fetchedResultController.sections?[section] else { return UIView() }
    
    let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: K.Cells.DateSectionHeader) as! DateSectionHeader
    sectionHeader.configure(with: sectionInfo.name)
    
    return sectionHeader
  }
  
  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 50.0
  }
}

// MARK: NSFetchedResultsControllerDelegate
extension ForecastViewController: NSFetchedResultsControllerDelegate {
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert: tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
    case .delete: tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
    case .move: tableView.reloadSections(IndexSet(integer: sectionIndex), with: .fade)
    case .update:
      tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
      tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
    }
  }
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }

  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      guard let indexPath = newIndexPath else { fatalError("Index path should not be nil") }
      tableView.insertRows(at: [indexPath], with: .fade)
    case .update:
      guard let indexPath = indexPath else { fatalError("Index path should not be nil") }
      guard let forecast = controller.object(at: indexPath) as? Forecast,
          let cell = tableView.cellForRow(at: indexPath) as? ForecastCell else { break }
      cell.configure(with: forecast)
    case .move:
      guard let indexPath = indexPath else { fatalError("Index path should not be nil") }
      guard let newIndexPath = newIndexPath else { fatalError("New index path should not be nil") }
      tableView.deleteRows(at: [indexPath], with: .fade)
      tableView.insertRows(at: [newIndexPath], with: .fade)
    case .delete:
      guard let indexPath = indexPath else { fatalError("Index path should not be nil") }
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }

  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
}

// MARK: CLLocationManagerDelegate
extension ForecastViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = manager.location else { return }
    
    let geocoder = CLGeocoder()
    geocoder.reverseGeocodeLocation(location) {
      (placemarks, error) -> Void in
      if let error = error {
        print(error)
        return
      }
      
      if let placemarks = placemarks, placemarks.count > 0 {
        let placemark = placemarks[0]
        if let locality = placemark.locality {
          if self.currentPlacemark?.locality == nil ||
            (self.currentPlacemark?.locality != nil && locality != self.currentPlacemark?.locality) {
            self.currentPlacemark = placemark
            self.loadForecastData()
          }
        }
      }
    }
  }
}
