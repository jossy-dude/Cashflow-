# CashFlow AI - Budget Tracker

A modern, feature-rich budget tracker app with email-based SMS parsing for Ethiopian banks (CBE, Telebirr, BOA, Dashen, Bunna).

## Features

- 📧 **IMAP Email Parsing**: Automatically fetches and parses forwarded SMS messages from bank emails
- 🏦 **Multi-Bank Support**: CBE, Telebirr, BOA, Dashen, and Bunna
- 📊 **Dashboard**: Glassmorphism-style cards with sync status and spending overview
- 📝 **Review Inbox**: Queue of parsed transactions requiring user confirmation
- 💰 **Budget Management**: Create categories with monthly limits and track spending
- 📈 **Analytics**: Fees & VAT breakdown with visualizations
- 🎨 **Theme Engine**: Multiple themes (Midnight, Solar, Leaf, Dynamic)
- ✏️ **Manual Entry**: Add transactions manually for untracked expenses

## Project Structure

```
cashflow-ai/
├── backend/
│   ├── api_server.py          # Flask API server
│   ├── email_parser.py        # IMAP email parser with bank templates
│   └── requirements.txt       # Python dependencies
└── flutter_app/
    ├── lib/
    │   ├── main.dart          # App entry point
    │   ├── models/            # Data models
    │   ├── providers/         # State management
    │   ├── screens/           # UI screens
    │   ├── services/          # API services
    │   └── theme/             # App theming
    └── pubspec.yaml           # Flutter dependencies
```

## Backend Setup

1. **Install Python dependencies:**
```bash
cd backend
pip install -r requirements.txt
```

2. **Configure environment variables:**
Create a `.env` file in the `backend` directory:
```
IMAP_SERVER=imap.gmail.com
EMAIL_ADDRESS=your-email@gmail.com
APP_PASSWORD=your-app-password
PORT=5000
```

3. **Run the API server:**
```bash
python api_server.py
```

The server will start on `http://localhost:5000`

## Flutter App Setup

1. **Install Flutter dependencies:**
```bash
cd flutter_app
flutter pub get
```

2. **Update API base URL:**
Edit `lib/services/api_service.dart` and update the `baseUrl` if your backend is running on a different host/port.

3. **Run the app:**
```bash
flutter run
```

## Email Configuration

### Gmail Setup

1. Enable 2-Step Verification on your Google Account
2. Generate an App Password:
   - Go to Google Account → Security → 2-Step Verification → App passwords
   - Select "Mail" and "Other (Custom name)"
   - Enter "CashFlow AI" and generate
   - Copy the 16-character password

3. Forward bank SMS messages to your Gmail account

### Supported Banks

- **CBE** (Commercial Bank of Ethiopia)
- **Telebirr** (Ethio Telecom)
- **BOA** (Bank of Abyssinia)
- **Dashen Bank**
- **Bunna Bank**

## API Endpoints

- `GET /api/health` - Health check
- `POST /api/sync` - Sync and parse unread emails
  ```json
  {
    "imap_server": "imap.gmail.com",
    "email_address": "your@email.com",
    "app_password": "your-app-password"
  }
  ```
- `POST /api/test-connection` - Test IMAP connection

## Transaction Parsing

The parser extracts:
- Amount (debit as negative)
- Transaction type (debit/credit)
- Bank name
- Counterparty name
- VAT (15%)
- Service fees
- Transaction ID
- Date and time

All transactions start with `category: "undefined"` and require user confirmation in the Review Inbox.

## Development

### Backend
- Python 3.8+
- Flask for REST API
- IMAP for email fetching
- Regex-based parsing for bank SMS formats

### Frontend
- Flutter 3.0+
- Material Design 3
- Provider for state management
- fl_chart for visualizations

## License

MIT License
