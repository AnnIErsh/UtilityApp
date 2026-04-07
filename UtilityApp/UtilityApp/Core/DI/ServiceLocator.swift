import Foundation

final class ServiceLocator {
    private var services: [String: Any] = [:]

    func register<Service>(_ type: Service.Type, service: Service) {
        services[String(describing: type)] = service
    }

    func resolve<Service>(_ type: Service.Type) -> Service {
        guard let service = services[String(describing: type)] as? Service else {
            fatalError("Service not registered: \(type)")
        }
        return service
    }
}
