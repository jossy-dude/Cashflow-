# Quick Start Guide

## Backend Setup (5 minutes)

1. **Navigate to backend directory:**
```bash
cd cashflow-ai/backend
```

2. **Create virtual environment (optional but recommended):**
```bash
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Create `.env` file:**
```bash
cp .env.example .env
# Edit .env with your email credentials
```

5. **Start the server:**
```bash
python api_server.py
```

Server runs on `http://localhost:5000`

## Flutter App Setup (5 minutes)

1. **Navigate to Flutter app directory:**
```bash
cd cashflow-ai/flutter_app
```

2. **Get dependencies:**
```bash
flutter pub get
```

3. **Run the app:**
```bash
flutter run
```

## First Time Configuration

1. **Open Settings** in the app
2. **Configure Email Connection:**
   - Enter your IMAP server (e.g., `imap.gmail.com`)
   - Enter your email address
   - Enter your app password (not regular password!)
   - Click "Test Connection"

3. **Start Syncing:**
   - Go to Dashboard
   - Click "Refresh" to sync emails
   - Check "Review Inbox" for parsed transactions

4. **Confirm Transactions:**
   - Review each transaction in the inbox
   - Assign categories if needed
   - Click "Confirm" to add to your budget

## Troubleshooting

### Backend Issues

- **IMAP connection fails:** Check your app password is correct
- **No emails found:** Make sure you have forwarded SMS messages to your email
- **Port already in use:** Change PORT in `.env` file

### Flutter Issues

- **Build errors:** Run `flutter clean` then `flutter pub get`
- **API connection fails:** Check backend is running and update `baseUrl` in `api_service.dart`
- **No transactions showing:** Ensure backend is running and emails are being parsed

## Next Steps

- Create custom categories in the Categories screen
- Set monthly budgets for each category
- View analytics in the Analytics screen
- Customize theme in Settings
