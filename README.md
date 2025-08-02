# Khaata - Finance & Budget Tracking App

A comprehensive finance and budget tracking app similar to Monefy, built with Flutter for Android.

## Features

### Core Features
- **Expense & Income Tracking**: Track both expenses and income with detailed categorization
- **Multiple Payment Methods**: Support for Cash, Debit Cards, and Credit Cards
- **Monthly Tracking**: View and manage transactions by month
- **Pie Chart Visualization**: Beautiful pie charts showing expense breakdown by category
- **CSV Export**: Export transaction data to CSV files for backup and analysis

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
│   └── app_constants.dart          # App constants, colors, categories
├── models/
│   └── transaction.dart            # Transaction data model
├── providers/
│   └── transaction_provider.dart   # State management
├── screens/
│   └── dashboard_screen.dart       # Main dashboard
├── services/
│   ├── database_service.dart       # SQLite operations
│   └── csv_service.dart           # CSV export functionality
├── widgets/
│   ├── add_transaction_screen.dart # Add transaction form
│   └── transaction_list.dart      # Transaction list widget
└── main.dart                      # App entry point
```

## Getting Started

### Prerequisites
- Flutter SDK (3.8.1 or higher)
- Android Studio / VS Code
- Android device or emulator

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

3. Run the app:
```bash
flutter run
```

## Usage

### Adding Transactions
1. Tap the floating action button (+)
2. Select transaction type (Income/Expense)
3. Enter amount, select category, add description
4. Choose payment method and date
5. Save the transaction

### Viewing Data
- **Dashboard**: Overview with income, expenses, and balance
- **Pie Chart**: Visual breakdown of expenses by category
- **Transaction List**: Detailed list of all transactions
- **Month Navigation**: Navigate between months using arrow buttons

### Exporting Data
1. Tap the download icon in the app bar
2. Choose to export current month or all data
3. CSV file will be saved to device storage

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

- **sqflite**: Local database
- **provider**: State management
- **fl_chart**: Charts and graphs
- **csv**: CSV export functionality
- **intl**: Internationalization and date formatting
- **flutter_slidable**: Swipe actions
- **path_provider**: File system access
- **permission_handler**: Android permissions
- **file_picker**: File selection

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.
