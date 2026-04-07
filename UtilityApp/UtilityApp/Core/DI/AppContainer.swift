import Foundation

final class AppContainer {
    let locator = ServiceLocator()

    init() {
        let coreDataStack = CoreDataStack()
        let dataService = CoreDataDataService(stack: coreDataStack)
        let repository = AppRepositoryImpl(dataService: dataService)
        let useCaseFactory = AppUseCaseFactory(repository: repository)

        locator.register(DataService.self, service: dataService)
        locator.register(AppRepository.self, service: repository)
        locator.register(AppUseCaseFactory.self, service: useCaseFactory)
    }
}
