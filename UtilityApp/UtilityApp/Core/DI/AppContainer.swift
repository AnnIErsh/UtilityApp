import Foundation

final class AppContainer {
    let locator = ServiceLocator()

    init() {
        let coreDataStack = CoreDataStack()
        let dataService = CoreDataDataService(stack: coreDataStack)
        let repository = AppRepositoryImpl(dataService: dataService)
        let focusNotificationService = LocalFocusNotificationService()
        let useCaseFactory = AppUseCaseFactory(
            repository: repository,
            focusNotificationService: focusNotificationService
        )

        locator.register(DataService.self, service: dataService)
        locator.register(AppRepository.self, service: repository)
        locator.register(FocusNotificationService.self, service: focusNotificationService)
        locator.register(AppUseCaseFactory.self, service: useCaseFactory)
    }
}
