# Khaata - Personal Finance Tracker

A comprehensive personal finance and budget tracking app built with Flutter for **Android and iOS**.

## Features

### Core Features
- **Expense & Income Tracking**: Track both expenses and income with detailed categorization
- **Multiple Payment Methods**: Support for Cash, Debit Cards, and Credit Cards
- **Monthly Tracking**: Navigate and manage transactions by month with swipe gestures
- **Pie Chart Visualization**: Beautiful pie charts showing expense breakdown by category
- **Transaction History**: Dedicated history screen filtered by the selected month
- **CSV Import**: Import transaction history from compatible CSV files
- **CSV Export**: Export transaction data to CSV files for backup and analysis
- **Dark Mode**: Full dark mode support
- **Currency Settings**: Configurable currency symbol

### Predefined Categories

#### Expense Categories
- Home, Pet, Car, Transport, Health, Food, Shopping, Entertainment
- Education, Utilities, Insurance, Taxes, Gifts, Travel
- Personal Care, Sports, Books, Technology, Clothing, Other

#### Income Categories
- Salary, Deposits, Loan, Carry Over, Investment, Freelance
- Bonus, Refund, Gift, Rental, Business, Other

### Payment Methods
- Cash
- Debit Card
- Credit Card

## Technical Architecture

### Design Patterns
- **Provider Pattern**: State management using Provider package
- **Singleton Pattern**: Database and CSV services
- **Repository Pattern**: Data access through service layer
- **Clean Architecture**: Separation of concerns with models, services, providers, and UI

### Database
- **SQLite**: Local database for transaction storage
- **CRUD Operations**: Full Create, Read, Update, Delete functionality
- **Monthly Queries**: Efficient queries for monthly data aggregation

### State Management
- **Provider**: Centralized state management
- **ChangeNotifier**: Reactive UI updates
- **Async Operations**: Proper handling of database operations

## Project Structure

```
lib/
├── constants/
│   └── app_constants.dart              # App constants, colors, categories
├── models/
│   └── transaction.dart                # Transaction data model
├── providers/
│   ├── transaction_provider.dart       # Transaction state management
│   └── settings_provider.dart         # App settings state (theme, currency)
├── screens/
│   ├── dashboard_screen.dart           # Main dashboard
│   ├── transaction_history_screen.dart # Monthly transaction history
│   └── settings_screen.dart           # App settings
├── services/
│   ├── database_service.dart           # SQLite operations
│   └── csv_service.dart               # CSV import/export functionality
├── utils/
│   └── helpers.dart                   # Utility functions
├── widgets/
│   ├── add_transaction_screen.dart     # Add transaction form
│   ├── edit_transaction_screen.dart    # Edit/delete transaction form
│   └── transaction_list.dart          # Transaction list widget
└── main.dart                          # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android device or emulator **or** iOS device/simulator (iOS 13.0+)
- CocoaPods (for iOS builds)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd khaata
```

2. Install dependencies:
```bash
flutter pub get
```

3. (iOS only) Install CocoaPods dependencies:
```bash
cd ios && pod install && cd ..
```

4. Run the app:
```bash
flutter run
```

## Usage

### Adding Transactions
1. Tap **+ Expense** or **+ Income** quick-add buttons on the dashboard
2. Select a category from the grid
3. Enter amount and optional description
4. Choose payment method and date
5. Tap **Save Transaction**

### Viewing Data
- **Dashboard**: Overview with income, expenses, balance, and pie chart for the selected month
- **Transaction History**: Tap "View Transaction History" to see all transactions for the current month, filterable by type
- **Month Navigation**: Swipe left/right on the dashboard to navigate between months

### Importing Data
1. Tap the menu icon in the app bar and select **Import from CSV**
2. Select a CSV file from your device
3. All transactions will be imported and the dashboard will refresh

### Exporting Data
1. Tap the menu icon in the app bar
2. Choose **Export Current Month** or **Export All Data**
3. CSV file will be saved to device storage (Documents on iOS, Downloads on Android)

## Future Features

### Paid Features (Premium)
1. **Custom Categories**: Add new categories and rename existing ones
2. **Cloud Backup**: Connect to Google Drive, Dropbox for data backup
3. **Data Restore**: Restore data when upgrading devices
4. **Advanced Analytics**: Detailed financial insights and reports
5. **Budget Planning**: Set monthly budgets and track progress

### Additional Features
- Multi-currency support
- Recurring transactions
- Bill reminders
- Financial goals tracking
- Investment portfolio tracking
- Tax reporting tools

## Dependencies

- **sqflite**: Local SQLite database
- **provider**: State management
- **fl_chart**: Charts and graphs
- **csv**: CSV import/export functionality
- **intl**: Internationalization and date formatting
- **flutter_slidable**: Swipe-to-delete actions
- **path_provider**: File system access
- **permission_handler**: Device permissions
- **file_picker**: File selection for CSV import
- **shared_preferences**: Persistent settings storage

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feat/your-feature`)
3. Make your changes
4. Submit a pull request

> **Note:** By contributing, you agree that your contributions will be licensed under the same AGPL-3.0 license.

## License

This project is licensed under the **GNU Affero General Public License v3.0 (AGPL-3.0)**.

- Free to use and modify for open-source projects (with attribution)
- Commercial or proprietary use requires a separate license

See [LICENSE](LICENSE) for the full license text and [COMMERCIAL.md](COMMERCIAL.md) for commercial licensing enquiries.

> Built on [Khaata](https://github.com/hamzaawan99/khaata) — Copyright (c) 2024–2026 Hamza Awan

## Support

For support and questions, please open an issue in the repository.

