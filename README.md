# waterlogged
iOS 14 project to explore static Widget configuration

## Description
Waterlogged is an iOS app that provides users with a way to log water information to HealthKit. This information is then viewable in the Health app. Currently, the app only supports fl oz (US) units.

Users can set a target goal for fl oz to drink daily, and the app tracks how close the user is to reaching the goal. 

## Developer Notes
Currently, the Xcode 12 beta is needed in order to run the app. 

The app is written 100% in SwiftUI, and it uses HealthKit for logging water data. Additionally, it uses WidgetKit for the `widget-complete` branch's widget code.

When testing the widget functionality, ensure the `WaterloggedWidgetExtension` target is set as the run destination. 
