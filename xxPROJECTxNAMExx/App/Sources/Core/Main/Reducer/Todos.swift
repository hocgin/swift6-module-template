@Reducer
struct Todos {
  @ObservableState
  struct State: Equatable {
  }

  enum Action: BindableAction, Sendable {
  }

  @Dependency(\.continuousClock) var clock
  @Dependency(\.uuid) var uuid
  private enum CancelID { case todoCompletion }

  var body: some Reducer<State, Action> {
  }
}