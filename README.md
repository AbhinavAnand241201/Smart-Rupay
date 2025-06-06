# Smart-Rupay - Personal Finance Manager

## Overview
Smart-Rupay is a comprehensive personal finance management app built with SwiftUI, designed to help users track their spending, set budgets, and achieve financial goals. The app features a modern, dark-themed UI with a focus on financial wellness and user experience.

## Features

### 1. Financial Wellness Dashboard
- Overall wellness score visualization
- Budget adherence tracking
- Emergency fund progress monitoring
- Savings rate analysis
- Oracle tips for financial improvement

### 2. Budget Management
- Category-based budget tracking
- Visual progress indicators
- Spending limits and alerts
- Budget vs. actual spending comparison

### 3. Financial Goals
- Goal setting with target amounts
- Progress tracking
- Deadline-based goals
- Visual progress indicators

### 4. Achievements & Badges
- Gamified experience with financial milestones
- Visual badge collection
- Achievement tracking
- Progress indicators

### 5. Authentication
- Secure login/signup
- User profile management
- Secure data storage

## UI/UX Design

### Color Scheme
- **Primary Background**: `#151618` (Dark gray)
- **Card Background**: `#26292E` (Slightly lighter gray)
- **Primary Accent**: `#3AD7D5` (Teal)
- **Text Primary**: `#FFFFFF` (White)
- **Text Secondary**: `#A0A0A0` (Light gray)
- **Warning/Error**: `#FF4500` (Orange-red)
- **Success**: `#39FF14` (Neon green)

### Typography
- **Headings**: SF Pro Display, Bold
- **Body Text**: SF Pro Text, Regular
- **Secondary Text**: SF Pro Text, Light

### Icons
- SF Symbols for consistent system integration
- Custom icons for financial categories

## Technical Architecture

### File Structure
```
trial-1235/
├── Views/
│   ├── RupayOracleView.swift      # Main dashboard
│   ├── FinancialGoalRowView.swift # Goal list item
│   ├── AddFinancialGoalView.swift # Goal creation
│   ├── LoginScreenView.swift      # Authentication
│   └── SignUpScreenView.swift     # User registration
│
├── Models/
│   ├── Transaction.swift          # Transaction data model
│   ├── FinancialGoal.swift        # Goal data model
│   ├── BudgetStatusItem.swift     # Budget tracking
│   └── Badge.swift               # Achievement system
│
├── ViewModels/
│   ├── RupayOracleViewModel.swift # Main business logic
│   └── FinancialGoalsViewModel.swift # Goals management
│
└── Utilities/
    ├── Extensions/               # SwiftUI extensions
    └── Constants.swift           # App-wide constants
```

### Key Components

#### 1. RupayOracleView
- Main dashboard view
- Displays financial wellness score
- Shows key metrics and tips
- Navigation hub to other features

#### 2. Financial Management
- Transaction tracking
- Budget management
- Goal setting and tracking
- Financial insights

#### 3. Authentication
- Secure user authentication
- Session management
- User preferences

## Dependencies
- SwiftUI (built-in)
- Combine (built-in)
- Core Data (for local storage)

## Getting Started

### Prerequisites
- Xcode 14.0+
- iOS 16.0+
- Swift 5.7+

### Installation
1. Clone the repository
2. Open `trial-1235.xcodeproj` in Xcode
3. Build and run on a simulator or device

## Future Enhancements
1. Cloud sync
2. Advanced reporting
3. Multi-currency support
4. Recurring transactions
5. Investment tracking

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
