#!/usr/bin/env python3
"""
Flask API server for CashFlow AI backend
Provides REST endpoints for email parsing and transaction management
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
from email_parser import parse_emails, EmailParser
import logging

load_dotenv()

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


@app.route('/api/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'ok', 'service': 'CashFlow AI Backend'})


@app.route('/api/sync', methods=['POST'])
def sync_emails():
    """Sync and parse unread emails"""
    try:
        data = request.json
        imap_server = data.get('imap_server', 'imap.gmail.com')
        email_address = data.get('email_address')
        app_password = data.get('app_password')
        
        if not email_address or not app_password:
            return jsonify({'error': 'Missing email credentials'}), 400
        
        transactions = parse_emails(imap_server, email_address, app_password)
        
        return jsonify({
            'success': True,
            'count': len(transactions),
            'transactions': transactions
        })
    except Exception as e:
        logger.error(f"Sync error: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/api/test-connection', methods=['POST'])
def test_connection():
    """Test IMAP connection"""
    try:
        data = request.json
        imap_server = data.get('imap_server', 'imap.gmail.com')
        email_address = data.get('email_address')
        app_password = data.get('app_password')
        
        if not email_address or not app_password:
            return jsonify({'error': 'Missing credentials'}), 400
        
        parser = EmailParser(imap_server, email_address, app_password)
        if parser.connect():
            parser.disconnect()
            return jsonify({'success': True, 'message': 'Connection successful'})
        else:
            return jsonify({'success': False, 'message': 'Connection failed'}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)
