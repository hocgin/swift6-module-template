//
//  Todo.swift
//  App
//
//  Created by hocgin on 2025/6/6.
//
import ComposableArchitecture
import CoreLocationClient
import Foundation
import SwiftUI

enum CancelID: Int {
    case locationManager
}

@Reducer
struct QLocation {
    @Dependency(\.locationManager) var locationManager

    @ObservableState
    struct State: Equatable, Identifiable {
        let id: UUID = .init()
        var isLoading: Bool = false
        var isRequestingCurrentLocation: Bool = false
        @Presents public var alert: AlertState<Action.Alert>?
//        @Presents var sheet: ActionSheetState<Action.Sheet>?
//        @Presents var confirmationDialog: ConfirmationDialogState<Action.Dialog>?
        var latitude: Double?
        var longitude: Double?
    }

    enum Action: BindableAction, Sendable {
        case binding(BindingAction<State>)
        case onAppear
        case setAlert(AlertState<Action.Alert>?)
        case startRequestingCurrentLocation
        case currentLocationButtonTapped
        case locationManager(LocationManager.Action)
        case alert(PresentationAction<Action.Alert>)
        case loaded(String)

        public enum Alert: Equatable {
            case dismissButtonTapped
        }
    }

    @ReducerBuilder<State, Action>
    var LocationReducer: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            /// 允许定位权限
            case .locationManager(.didChangeAuthorization(.authorizedAlways)),
                 .locationManager(.didChangeAuthorization(.authorizedWhenInUse)):
                return state.isRequestingCurrentLocation ? .run { _ in await locationManager.requestLocation() } : .none

            /// 拒绝定位权限
            case .locationManager(.didChangeAuthorization(.denied)):
                if state.isRequestingCurrentLocation {
                    state.alert = .init(
                        title: TextState("Location makes this app better. Please consider giving us access.")
                    )
                    state.isRequestingCurrentLocation = false
                }
                return .none

            /// 位置发生更新
            case let .locationManager(.didUpdateLocations(locations)):
                state.isRequestingCurrentLocation = false
                guard let location = locations.first else { return .none }
                state.latitude = location.coordinate.latitude
                state.longitude = location.coordinate.longitude
                debugPrint("location = \(location)")
                return .none

            case let .locationManager(other):
                if case let .didChangeAuthorization(status) = other {
                    debugPrint("location.locationManager.didChangeAuthorization.status = \(status)")
                } else {
                    debugPrint("location.locationManager.other = \(other)")
                }
                return .none

            default:
                return .none
            }
        }
    }

    var body: some ReducerOf<Self> {
        LocationReducer
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                debugPrint("加载项 新数据..")
                state.isLoading = true

                return .run { send in
                    await withTaskGroup(of: Void.self) { group in
                        await locationManager.set(
                            activityType: .other,
                            allowsBackgroundLocationUpdates: false,
                            desiredAccuracy: kCLLocationAccuracyBest,
                            distanceFilter: 10,
                            pausesLocationUpdatesAutomatically: false,
                            showsBackgroundLocationIndicator: false
                        )

                        group.addTask {
                            await withTaskCancellation(id: CancelID.locationManager, cancelInFlight: true) {
                                for await action in await locationManager.delegate() {
                                    await send(.locationManager(action), animation: .default)
                                }
                            }
                        }
                        group.addTask {
                            await send(.currentLocationButtonTapped)
                        }
                        group.addTask {
                            await send(.loaded("ok"))
                        }
                    }
                }
            /// 开启请求位置
            case .startRequestingCurrentLocation:
                state.isRequestingCurrentLocation = true
                return .run { _ in
                    #if os(macOS)
                    await locationManager.requestAlwaysAuthorization()
                    #else
                    await locationManager.requestWhenInUseAuthorization()
                    #endif
                }
            case .currentLocationButtonTapped:
                return .run { send in
                    guard await locationManager.locationServicesEnabled() else {
                        await send(.setAlert(.init(title: TextState("Location services are turned off."))))
                        return
                    }
                    switch await locationManager.authorizationStatus() {
                    case .notDetermined:
                        await send(.startRequestingCurrentLocation)

                    case .restricted:
                        await send(.setAlert(.init(title: TextState("Please give us access to your location in settings."))))

                    case .denied:
                        await send(.setAlert(.init(title: TextState("Please give us access to your location in settings."))))

                    case .authorizedAlways, .authorizedWhenInUse:
//                        await locationManager.startUpdatingLocation()
                        await locationManager.requestLocation()

                    @unknown default:
                        break
                    }
                }
            case let .setAlert(alert):
                state.alert = alert
                return .none
            case let .loaded(result):
                debugPrint("加载完成..\(result)")
                state.isLoading = false
                return .none
            default:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
        .signpost()
    }
}

struct QLocationView: View {
    @Bindable var store: StoreOf<QLocation>

    var body: some View {
        VStack {
            WithViewStore(store, observe: { $0 }) { store in
                Text("Todo.\(store.id)")
                Text("latitude.\(store.latitude ?? .zero),\(store.longitude ?? .zero)")
                Text("\(store.isLoading ? "加载中" : "加载完成")")
            }
        }
        .alert(store: store.scope(state: \.$alert, action: \.alert))
        .onAppear {
            store.send(.onAppear)
        }
    }
}

/// =======================================================

extension QLocation.State {
    static let mock: Self = .init()
}

#Preview {
    QLocationView(
        store: Store(initialState: .mock) { QLocation() }
    )
}
