# Padel iOS mobile app instructions
The mobile app for iOS consists of 4 screens: Sessions, New Session, Match and Summary.
String assets should be localizable.
App should support both light and dark modes.
- Session has two states: Empty and History
- Session Empty State:
    - Contains action button at the bottom with String "Start new session" to create a new match session.
    - Contains empty state image "tennisball.cicle", title "No sessions yet" and subtitle "Let's play some Padel", all centered and localized.
- Session History State:
    - Contains a list of previous match sessions with SessionCard view (I will write it on my own).
    - Contains action button at the bottom with String "Start new session" to create a new match session.
- New Session screen:
  - It has time picker that supports hh:mm:ss format.
  - Contains action button at the bottom with String "Start new session" to start a new match session.
- Match screen:
  - Logic-wise, it is completely the same as the watch app.
  - The UI is also very simliar, but quadrants for showing whose turn is, is displayed at the top of the screen.
  - At the buttom, in the BottomSheet is on top left ProgressIndicator showing the current time elapsed, Timer in the center and top right is the Cancel button.
  - In the center of the BottomSheet is the big Play/Pause button which disables the match UI and starts/stops the timer. 
- Summary screen:
  - It shows which team won the match. Passed time and the final score.
  - Also shows trophy icon

## Application Architecture
Follow Clean architecture guidelines in combination with MVVM. 
- Domain layer for the models and business logic.
- Presentation layer should have all screens represented as folders (like package by feature), inside each folder: State, ViewModel and View.
- States are enums, ViewModels are ObservableObjects and Views are SwiftUI views.
