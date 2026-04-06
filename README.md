# Zovryn Finance 🚀

Welcome to **Zovryn Finance**! This is my personal finance tracking app designed to help users keep a close eye on their transactions, set financial goals, and get intelligent insights into their spending habits. 

## 📱 What is Zovryn Finance?

I built Zovryn because I wanted a smooth, secure, and beautiful way to manage my finances on the go. The project is structured with a robust Clean Architecture backend and a buttery smooth frontend, allowing for solid data handling and an incredible user experience.

### Key Features
- **Dashboard & Insights**: Get a quick glance at your financial health and dive deep into your spending trends.
- **Transactions Management**: Easily log, categorize, and track your daily transactions.
- **Financial Goals**: Set saving goals and watch your progress over time.
- **Biometric Security**: Built-in local authentication so your financial data stays private.
- **Local Notifications**: Smart reminders to keep you on track with your goals.
- **Premium Design Aesthetics**: Includes a custom design system with two gorgeous modes: "Financial Architect" (Light Mode) and "Midnight Ledger" (Dark Mode). The UI has a text-dominant, borderless aesthetic (following the "No-Line" rule).

## 🛠 Tech Stack & Architecture

I wanted to build something highly maintainable and production-ready, so I chose a modern, scalable tech stack:

### Frontend (`frontend_mob`)
- **Framework**: Flutter (compatible with 3.27+)
- **State Management**: BLoC pattern for predictable and testable state.
- **Dependency Injection**: `get_it` & `injectable` to keep everything decoupled and modular.
- **Routing**: `go_router` for seamless navigation flows.

### Backend (`Backend`)
- **Framework**: .NET / C# structured using Clean Architecture Principles (`Domain`, `Application`, `Infrastructure`, `API`).
- **Containerization**: Includes Docker support (`Dockerfile` & `docker-compose.yml`) for easy deployment and environment setups.

## 🚀 Getting Started

If you want to spin the app up locally, follow these steps:

### Prerequisites
- Flutter SDK (latest stable, ideally 3.27+)
- .NET SDK (for the backend)
- Docker (optional, for running the backend stack)

### Running the Frontend
1. Clone the repo and navigate to the project directory.
2. Go to the frontend folder:
   ```bash
   cd frontend_mob
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

### Running the Backend
1. Navigate to the backend directory:
   ```bash
   cd Backend
   ```
2. You can either run it directly via the .NET CLI or use Docker Compose to spin up the entire environment.
   ```bash
   docker-compose up -d
   ```

## 💡 Why This Approach? (Technical Trade-offs)

Throughout development, I made a few key architectural choices:
- **Clean Architecture (.NET)**: By separating Domain, Application, and Infrastructure layers, the backend is highly testable and agnostic to the database or external frameworks. It's built for scale.
- **BLoC over providers**: As the app scales (e.g., adding insights and goal tracking), tracking complex state changes becomes much more manageable and predictable using BLoC.
- **GetIt + Injectable**: Allows me to swap out frontend implementations easily (like switching between a mock API and a real backend interface) without touching UI code.
- **Custom Design System**: Instead of relying heavily on default Material components, I wanted a premium, unique look. Hence the strict implementation of our design system, ensuring it scales beautifully between light and dark modes without relying on hardcoded values.

## 🤝 Next Steps

This project is constantly evolving. My next focuses involve expanding analytics and adding more automated categorization for transactions. Reach out if you have any feedback or ideas!

---
*Built with ❤️ and a lot of coffee.*
