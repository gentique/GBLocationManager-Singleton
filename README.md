# GBLocationManager

GBLocationManager is a handy singleton class for CLLLocationManager.

## Installation

Copy paste the .swift class into your project.

## Usage
```swift
let locationManager = GBLocationManager.shared
```
## Protocol
```swift
protocol GBLocationManagerDelegate {
    func didUpdateLocation(location: CLLocation)
    func didFailWith(error: Error)
    func authorizationStatusChanged(status: CLAuthorizationStatus)
}
```
## Convenience methods
```swift
func locationServices(shouldUpdate: Bool)
func requestLocationUpdate { (success, location) in }
func checkAuthorization()

```
## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://raw.githubusercontent.com/gentique/GBLocationManager-Singleton/master/LICENSE)
