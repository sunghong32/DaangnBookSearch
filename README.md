# DaangnBookSearch 📚  
Book search iOS app using **UIKit**, **Clean Architecture**, and **MVI pattern**.  
Network layer implemented without third-party libraries (custom Provider/Target).

---

## 📖 Overview
This project is an iOS pre-assignment for Carrot.  
It is a book search application built with UIKit, designed to demonstrate Clean Architecture and MVI pattern implementation.

Users can:
- Search books using [itbook.store API](https://api.itbook.store/)
- View detailed book information
- Load book cover images with memory + disk caching
- Experience smooth pagination and error handling

---

## 🧱 Architecture

**Architecture Pattern:** Clean Architecture + MVI  
**UI Framework:** UIKit (code-based, no storyboard)  
**Async Pattern:** async/await  
**Cache:** NSCache + Disk cache  
**Test Coverage:** Unit tests for Network, UseCase, Reducer  

---

## ⚙️ Tech Stack

| Layer | Description |
|-------|--------------|
| **Presentation** | UIKit ViewControllers with MVI (State / Intent / Reducer) |
| **Domain** | Business logic with `UseCase` and `Entity` |
| **Data** | Network communication using custom `NetworkProvider` & `NetworkTarget` |
| **Core** | Common utilities and logger |
| **Tests** | Unit tests for provider, repository, and reducer |

---

## 🔌 Network Layer
Custom network layer inspired by **Moya**, but implemented manually without any third-party library.

- `NetworkTarget`: defines API endpoint, path, and HTTP method  
- `NetworkProvider`: executes requests using `URLSession`  
- `ItBookTarget`: defines book search and detail APIs

---

## 📦 Features
- Book search with pagination  
- Book detail view  
- Image caching (memory + disk)  
- Clean Architecture separation  
- Custom networking (no Moya, no Alamofire)  
- Unit tests for core logic  

---

## 🚀 Requirements
- iOS 16.0+
- Xcode 15+
- Swift 5.9+

---

## 🧪 How to Run
1. Clone the repository  
   ```bash
   git clone https://github.com/sunghong32/DaangnBookSearch.git
