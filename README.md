# tumba-app-ios

This project is an iOS application built with Swift that interacts with a Ruby on Rails backend via API. The app mirrors core functionalities of the web version, allowing users to manage profiles and collections directly from their iPhone.

## Project Highlights
- User authentication with secure token handling
- Creating, editing, and deleting collections and profiles
- Fetching and displaying posts and products
- Token-based session management via Keychain
- API communication with Alamofire
- Efficient data caching and UI updates
- Clean MVVM architecture with modular structure

## Tools & Technologies
- Swift
- UIKit & SwiftUI
- MVVM Architecture
- Alamofire
- WaterfallGrid
- Keychain API

## Project Structure
<pre>
TUMBA/
├── Keychain/           <i># Token management and secure storage</i>
├── Models/             <i># Database models (MVVM)</i>
├── Networking/         <i># Parameterized API requests and loaders</i>
├── Preview Content/    <i># SwiftUI preview assets</i>
├── Screens/            <i># MVVM-based UI screens (Views & ViewModels)</i>
├── Services/           <i># API service logic and endpoint handlers</i>
├── Shared/             <i># Shared utilities and components</i>
├── ContentView.swift   <i># Main app entry screen</i>
├── Info.plist          <i># Font and permissions configuration</i>
├── TUMBAApp.swift      <i># App lifecycle and setup</i>
└── .DS_Store           <i># (System file, not needed)</i>
</pre>

## Backend Integration
The app communicates with a custom Ruby on Rails backend through secure, token-based RESTful API endpoints. All user actions — from login to collection creation — are synchronized with the server in real time.  
Backend source code is available here: [GitHub - TUMBA](https://github.com/IrinaApolonnik/TUMBA)

## How to Run
1. Clone the repository  
   `git clone https://github.com/Imnlvv/tumba-app-ios.git`
2. Open `TUMBA.xcodeproj` or `TUMBA.xcworkspace` in Xcode
3. Make sure your development environment supports Swift 5+
4. Run on a simulator or physical device with iOS 15+

## Notes
- Ensure the backend server is available for API interaction.
- The app uses `Alamofire` for networking and `Keychain` for secure data storage.
