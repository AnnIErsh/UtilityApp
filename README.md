# 🚀 Focus Flow App

## 🧩 Main Features

### ✅ Tasks

* Create, complete, and delete tasks
* Swipe actions + task details modal
* First-launch starter tasks

---

### 🔁 Habits

* Create, increment, and delete habits
* Weekly progress tracking *(X / target per week)*
* Automatic weekly reset *(calendar-based)*
* First-launch starter habits

---

### ⏱ Focus Timer

* Start / Pause / Resume / Reset
* State persists across tab switches and app lifecycle
* Kill-safe recovery via persisted session metadata
* Local notifications:

  * Running state
  * Completion alerts
* Notification actions support *(pause / complete handling)*

---

### 📊 Dashboard & Stats

* Aggregated metrics from:

  * Tasks
  * Habits
  * Focus sessions

---

## 🛠 Tech Stack

* 💻 **Swift**
* 🎨 **SwiftUI**
* 🗄 **Core Data**
* 🔔 **UserNotifications**
* ⚡ **UserDefaults** *(lightweight state persistence)*

---

## 🏗 Architecture

The app follows a **layered architecture**:

### 🔹 Core / DI

* `AppContainer`
* `ServiceLocator`

### 🔹 Core / Domain

* Repositories *(contracts)*
* UseCases *(business logic)*

### 🔹 Core / Services

* Infrastructure layer:

  * `CoreDataDataService`
  * Notification services

### 🔹 Core / Data

* Core Data stack
* Managed object definitions

### 🔹 Core / Models

* Domain-facing models

### 🔹 Features/*

* SwiftUI views
* ViewModels per screen

### 🔹 Shared / Theme

* 🎨 Design system:

  * Theme tokens
  * Typography
  * Layout metrics
  * Shared UI helpers

---

## 🔄 Data Flow

```text
View → ViewModel → UseCase → Repository → Service → Core Data
```

💡 This separation ensures:

* Clean architecture
* Testability
* Maintainability

---

## 💾 Persistence Notes

* First-launch seed data is created once
* Habit weekly reset uses calendar-based week keys
* Focus timer:

  * Stores pending session state
  * Recovers after app termination

---

## ▶️ Build & Run

1. Open `UtilityApp.xcodeproj` in Xcode
2. Select **UtilityApp scheme**
3. Run on:

   * iOS Simulator
   * Physical device

---

## 🗺 Roadmap Ideas

* 📱 Live Activities / Dynamic Island support
* 📈 Habit history tracking for analytics
* ☁️ Cloud sync
* 🧪 Expanded unit & UI tests

---

## ✨ Summary

**Focus Flow** is a productivity app combining:

* Task management
* Habit tracking
* Focus sessions

—all in a clean, scalable architecture with modern iOS technologies 🚀
