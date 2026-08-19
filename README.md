# Pulse HRMS - Attendance & Leave Management Portal

Pulse HRMS is a modern Human Resource Management System mobile application built with Flutter. It follows Clean Architecture principles and uses BLoC for state management and Hive for local persistence.

##  Features

- **Authentication:** Secure login with local session persistence.
- **Live Dashboard:** Real-time clock-in/clock-out functionality with a live working hour timer.
- **Attendance Tracking:** Comprehensive history of attendance with status indicators (Present, Absent, On Leave, Holiday).
- **Quick Actions:** Easy navigation to apply for leaves and view monthly records.
- **Offline First:** All data is stored locally using Hive NoSQL database, ensuring the app works without an active internet connection.
- **Auto-Seeding:** The app automatically generates 45 days of mock attendance data on the first run for demonstration purposes.

##  Demo Credentials

To explore the app without creating a custom account, use the following credentials:

- **Employee ID:** `emp001`
- **Password:** `password123`

## Tech Stack

- **Framework:** [Flutter](https://flutter.dev/)
- **State Management:** [Flutter BLoC](https://pub.dev/packages/flutter_bloc)
- **Dependency Injection:** [GetIt](https://pub.dev/packages/get_it)
- **Local Storage:** [Hive](https://pub.dev/packages/hive_flutter)
- **Architecture:** Clean Architecture (Data, Domain, Presentation layers)

##  Project Structure

```text
lib/
├── core/                # Constants, Theme, DI, Errors, Utils
├── data/                # Repositories Impl, DataSources, Models
├── domain/              # Entities, Repository Interfaces, UseCases
└── presentation/        # BLoC, Screens, Widgets
```

## ⚙️ Setup Instructions

1.  **Prerequisites:**
    - Flutter SDK installed (`flutter doctor` should be green).
    - Android Studio or VS Code with Flutter extension.

2.  **Clone & Install:**
    ```bash
    git clone <repository-url>
    cd hrms_app
    flutter pub get
    ```

3.  **Run the App:**
    ```bash
    flutter run
    ```

## 📖 Architecture Overview

The app is divided into three main layers:
- **Presentation:** Contains the UI and BLoCs. BLoCs handle events from the UI and emit states based on business logic.
- **Domain:** The core of the app. It contains the business logic (UseCases) and data structures (Entities) that are independent of any external library.
- **Data:** Implements the repository interfaces defined in the Domain layer. It handles data retrieval from the local Hive database and mapping between Models (Data) and Entities (Domain).

## 📄 License

This project is for demonstration purposes.
