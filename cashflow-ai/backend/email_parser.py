#!/usr/bin/env python3
"""
Email-based SMS Parser for CashFlow AI
Converts IMAP email fetching to parse forwarded SMS messages from Ethiopian banks
"""

import imaplib
import email
from email.header import decode_header
from datetime import datetime, timezone
import re
import json
import logging
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DEC_AMOUNT = r'((?:\d{1,3}(?:,\d{3})*|\d+)(?:\.\d+)?)'

TEMPLATES = [
    {
        'name': 'CBE',
        'senders': ['cbe', 'commercial bank of ethiopia'],
        'body_patterns': [
            r'Current Balance is ETB',
            r'has been credited with ETB',
            r'has been debited with ETB',
            r'You have transfered ETB'
        ],
        'account_bank_tag': 'CBE',
        'fields': {
            'amount': [
                rf'You have transfer(?:ed|red) ETB\s*{DEC_AMOUNT}',
                rf'credited with ETB\s*{DEC_AMOUNT}',
                rf'debited with ETB\s*{DEC_AMOUNT}',
            ],
            'account': [r'account\s*([0-9*-]+)'],
            'balance': [
                rf'Current Balance is ETB\s*{DEC_AMOUNT}',
                rf'Your Current Balance is ETB\s*{DEC_AMOUNT}'
            ],
            'transaction_id': [
                r'id=([A-Za-z0-9-&=]+)',
                r'Ref No\s*([A-Z0-9]+)'
            ],
        }
    },
    {
        'name': 'Telebirr',
        'senders': ['127', 'telebirr', 'ethio telecom'],
        'body_patterns': [r'telebirr', r'telebirr transaction'],
        'account_bank_tag': 'Telebirr',
        'fields': {
            'amount': [rf'ETB\s*{DEC_AMOUNT}'],
            'account': [r'Account\s*([0-9*-]+)', r'Account\s*([0-9*]+)'],
            'transaction_id': [r'transaction number is\s*([A-Z0-9-]+)'],
        }
    },
    {
        'name': 'BOA',
        'senders': ['bankofabyssinia', 'boa', 'bank of abyssinia', '8397'],
        'body_patterns': [
            r'Bank of Abyssinia',
            r'your account .* was (?:credited|debited)'
        ],
        'account_bank_tag': 'BOA',
        'fields': {
            'amount': [
                rf'was (?:credited|debited) with ETB\s*{DEC_AMOUNT}',
                rf'has been (?:credited|debited) with ETB\s*{DEC_AMOUNT}'
            ],
            'account': [r'account\s*([0-9*-]+)'],
            'transaction_id': [r'trx=([A-Z0-9]+)'],
        }
    },
    {
        'name': 'Dashen',
        'senders': ['dashen', 'dashen super app', 'dashenbank'],
        'body_patterns': [r'Dashen', r'Dashen Super App'],
        'account_bank_tag': 'Dashen',
        'fields': {
            'amount': [
                rf'ETB\s*{DEC_AMOUNT}',
                rf'is credited with ETB\s*{DEC_AMOUNT}',
                rf'has been debited with ETB\s*{DEC_AMOUNT}'
            ],
            'account': [r'account\s*["\']?([0-9*-]+)["\']?'],
            'transaction_id': [r'receipt/([A-Za-z0-9/-=]+)'],
        }
    },
    {
        'name': 'Bunna',
        'senders': ['bunna', 'bunna bank'],
        'body_patterns': [r'Bunna Bank', r'Withdrawal of', r'Deposit of'],
        'account_bank_tag': 'Bunna',
        'fields': {
            'amount': [
                rf'Withdrawal of\s*{DEC_AMOUNT}\s*ETB',
                rf'A Withdrawal of\s*{DEC_AMOUNT}\s*ETB',
                rf'A Deposit of\s*{DEC_AMOUNT}\s*ETB',
                rf'has been debited with ETB\s*{DEC_AMOUNT}'
            ],
            'account': [r'account\s*([0-9*-]+)'],
            'transaction_id': [r'receipt.*trx=([A-Z0-9]+)'],
        }
    }
]


@dataclass
class ParsedTransaction:
    """Data class for parsed transaction"""
    amount: float
    account_name: str
    account_number: str
    date: str
    time: str
    type: str  # 'debit', 'credit', or ''
    category: str  # Always 'undefined' initially
    title: str  # Counterparty name
    notes: str  # Original SMS body
    link: str
    error: str
    vat: float
    service_fee: float
    tags: str
    transaction_id: str = ''
    confidence: float = 0.0
    email_id: str = ''  # IMAP message ID
    raw_email: str = ''  # Full email content for debugging


class EmailParser:
    """IMAP-based email parser for bank SMS messages"""
    
    def __init__(self, imap_server: str, email_address: str, app_password: str):
        self.imap_server = imap_server
        self.email_address = email_address
        self.app_password = app_password
        self.imap = None
    
    def connect(self) -> bool:
        """Connect to IMAP server"""
        try:
            self.imap = imaplib.IMAP4_SSL(self.imap_server)
            self.imap.login(self.email_address, self.app_password)
            logger.info(f"Connected to {self.imap_server}")
            return True
        except Exception as e:
            logger.error(f"IMAP connection failed: {e}")
            return False
    
    def disconnect(self):
        """Disconnect from IMAP server"""
        if self.imap:
            try:
                self.imap.close()
                self.imap.logout()
            except:
                pass
    
    def fetch_unread_emails(self, folder: str = 'INBOX') -> List[Dict]:
        """Fetch unread emails from specified folder"""
        if not self.imap:
            return []
        
        try:
            self.imap.select(folder)
            status, messages = self.imap.search(None, 'UNSEEN')
            if status != 'OK':
                return []
            
            email_ids = messages[0].split()
            emails = []
            
            for email_id in email_ids:
                try:
                    status, msg_data = self.imap.fetch(email_id, '(RFC822)')
                    if status != 'OK':
                        continue
                    
                    raw_email = msg_data[0][1]
                    email_message = email.message_from_bytes(raw_email)
                    
                    # Decode subject
                    subject, encoding = decode_header(email_message['Subject'])[0]
                    if isinstance(subject, bytes):
                        subject = subject.decode(encoding or 'utf-8')
                    
                    # Get body
                    body = self._get_email_body(email_message)
                    
                    # Get sender
                    sender, _ = decode_header(email_message['From'])[0]
                    if isinstance(sender, bytes):
                        sender = sender.decode('utf-8')
                    
                    # Get date
                    date_tuple = email.utils.parsedate_tz(email_message['Date'])
                    if date_tuple:
                        dt = datetime(*date_tuple[:6], tzinfo=timezone.utc)
                    else:
                        dt = datetime.now(timezone.utc)
                    
                    emails.append({
                        'id': email_id.decode(),
                        'subject': subject or '',
                        'sender': sender or '',
                        'body': body,
                        'date': dt,
                        'raw': raw_email.decode('utf-8', errors='ignore')
                    })
                except Exception as e:
                    logger.error(f"Error parsing email {email_id}: {e}")
                    continue
            
            return emails
        except Exception as e:
            logger.error(f"Error fetching emails: {e}")
            return []
    
    def _get_email_body(self, msg) -> str:
        """Extract plain text body from email"""
        body = ""
        if msg.is_multipart():
            for part in msg.walk():
                content_type = part.get_content_type()
                content_disposition = str(part.get("Content-Disposition"))
                
                if content_type == "text/plain" and "attachment" not in content_disposition:
                    try:
                        payload = part.get_payload(decode=True)
                        if payload:
                            body = payload.decode('utf-8', errors='ignore')
                            break
                    except:
                        pass
        else:
            try:
                payload = msg.get_payload(decode=True)
                if payload:
                    body = payload.decode('utf-8', errors='ignore')
            except:
                pass
        
        return body
    
    def mark_as_read(self, email_id: str):
        """Mark email as read"""
        try:
            self.imap.store(email_id, '+FLAGS', '\\Seen')
        except Exception as e:
            logger.error(f"Error marking email as read: {e}")


def safe_float(amount_str) -> float:
    """Safely convert string to float"""
    if amount_str is None:
        return 0.0
    s = str(amount_str).strip()
    if not s:
        return 0.0
    s = s.replace(',', '')
    m = re.search(r'(-?\d+(?:\.\d+)?)', s)
    return float(m.group(1)) if m else 0.0


def match_template(sender: str, body: str) -> Optional[Dict]:
    """Match email to bank template"""
    sl = (sender or '').lower()
    bl = (body or '').lower()
    
    for template in TEMPLATES:
        # Check sender
        if any(s.lower() in sl for s in template.get('senders', [])):
            return template
        
        # Check body patterns
        if any(re.search(pat, bl, re.IGNORECASE) for pat in template.get('body_patterns', [])):
            return template
    
    return None


def extract_fields(template: Dict, body: str) -> Dict:
    """Extract fields from SMS body using template patterns"""
    data = {}
    for field, pats in template.get('fields', {}).items():
        for pat in pats:
            try:
                m = re.search(pat, body, re.IGNORECASE)
                if m:
                    data[field] = m.group(1).strip() if m.lastindex and m.group(1) else ''
                    break
            except re.error:
                continue
    return data


def is_near_total(match_obj, body: str) -> bool:
    """Check if match is near 'total' keyword (to ignore)"""
    if not match_obj:
        return False
    try:
        start = match_obj.start()
        context = body[max(0, start-30):start].lower()
        return 'total' in context or 'with a total' in context or 'total of' in context
    except:
        return False


def extract_vat_and_service(body: str, principal_amount: Optional[float] = None) -> Tuple[float, float, Optional[float]]:
    """Extract VAT and service fees from SMS body"""
    vat = 0.0
    service = 0.0
    total = None
    
    # Service fee
    for m_s in re.finditer(r'(S\.charge|Service(?:\s+charge)?|service fee|service charge)[^\dE]{0,30}ETB\s*([0-9,]+(?:\.\d+)?)', body, re.IGNORECASE):
        if is_near_total(m_s, body):
            continue
        service = safe_float(m_s.group(2))
        break
    
    # VAT with percentage
    for m_vp in re.finditer(r'([0-9]{1,3})%\s*VAT(?:\s+of)?\s*(?:ETB)?\s*([0-9,]+(?:\.\d+)?)', body, re.IGNORECASE):
        if is_near_total(m_vp, body):
            continue
        vat = safe_float(m_vp.group(2))
        break
    
    # VAT without percentage
    if vat == 0.0:
        for m_v in re.finditer(r'VAT(?:\s*(?:of)?)\s*(?:ETB)?\s*([0-9,]+(?:\.\d+)?)', body, re.IGNORECASE):
            if is_near_total(m_v, body):
                continue
            vat = safe_float(m_v.group(1))
            break
    
    # Total
    m_tot = re.search(r'(?:total(?:\s+of)?|with a total of|total:)\s*ETB\s*([0-9,]+(?:\.\d+)?)', body, re.IGNORECASE)
    if m_tot:
        total = safe_float(m_tot.group(1))
    
    # Infer from total if needed
    if total is not None and principal_amount is not None and vat == 0.0 and service == 0.0:
        inferred = round(total - abs(principal_amount), 2)
        if inferred > 0.0:
            int_part = int(inferred)
            dec_part = round(inferred - int_part, 2)
            if int_part >= 1 and dec_part > 0:
                service = float(int_part)
                vat = dec_part
            elif inferred < 1.0:
                vat = inferred
            else:
                service = inferred
    
    return vat, service, total


def extract_counterparty(body: str) -> str:
    """Extract counterparty name from SMS body"""
    patterns = [
        r'\bto\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\s+on\s+\d{2}/\d{2}/\d{4}',
        r'\bto\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\s+at\s+\d{2}:\d{2}:\d{2}',
        r'\bto\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\b,',
        r'\bto\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\s+on\b',
        r'\bfrom\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\s+on\b',
        r'\bfrom\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\b[,.]',
        r'credited with ETB\s*[0-9,]+(?:\.\d+)?\s+by\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\b',
        r'credited by\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\b',
        r'by\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\s*.',
        r'BY FROM\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\b',
        r'BY\s+([A-Z][A-Za-z.\'-\s]{1,80}?)\b',
        r'\bto\s+(.+?)\s+account number\b',
        r'\bfrom\s+(.+?)\s+account\b',
    ]
    
    for pat in patterns:
        m = re.search(pat, body, re.IGNORECASE)
        if m:
            name = m.group(1).strip()
            name = re.sub(r'[\s,.]+$', '', name)
            if name.isupper():
                name = name.title()
            return name
    
    return ''


def detect_tags(body: str) -> str:
    """Detect transaction tags (ATM, PACKAGE)"""
    tags = []
    b = body.lower()
    if 'atm' in b or 'withdraw' in b or 'withdrawal' in b:
        tags.append('ATM')
    if 'package' in b:
        tags.append('PACKAGE')
    return '|'.join(tags)


def parse_email_transaction(email_data: Dict) -> Optional[ParsedTransaction]:
    """Parse a single email into a transaction"""
    sender = email_data.get('sender', '')
    body = email_data.get('body', '').strip()
    date = email_data.get('date', datetime.now(timezone.utc))
    
    # Match template
    template = match_template(sender, body)
    if not template:
        return None
    
    # Extract fields
    fields = extract_fields(template, body)
    
    # Determine bank name
    account_name = template.get('account_bank_tag', '')
    s_low = sender.lower()
    b_low = body.lower()
    
    if '127' in s_low or 'telebirr' in s_low:
        account_name = 'Telebirr'
    elif 'cbe' in s_low or 'commercial bank' in s_low or 'cbe' in b_low:
        account_name = 'CBE'
    elif 'dashen' in s_low or 'dashen' in b_low:
        account_name = 'Dashen'
    elif 'bunna' in s_low or 'bunna' in b_low:
        account_name = 'Bunna'
    elif 'bankofabyssinia' in s_low or 'abyssinia' in b_low or 'bank of abyssinia' in b_low:
        account_name = 'BOA'
    
    account_num = fields.get('account', '')
    
    # Extract amount
    amount = 0.0
    if 'amount' in fields and fields.get('amount'):
        amount = safe_float(fields.get('amount'))
    else:
        m_primary = re.search(
            r'(?:You have transfer(?:ed|red)|has been debited with|has been credited with|'
            r'was debited with|was credited with|debited with ETB|credited with ETB|transferred ETB)\s*'
            r'(?:ETB\s*)?([0-9,]+(?:\.\d+)?)',
            body, re.IGNORECASE
        )
        if m_primary:
            amount = safe_float(m_primary.group(1))
        else:
            matches = re.findall(r'ETB\s*([0-9,]+(?:\.\d+)?)', body, re.IGNORECASE)
            if matches:
                for mval in matches:
                    idx = body.lower().find(mval)
                    if idx != -1:
                        context = body[max(0, idx-40):idx+len(mval)+40].lower()
                        if 'balance' in context:
                            continue
                        amount = safe_float(mval)
                        break
                if amount == 0.0:
                    amount = safe_float(matches[0])
    
    # Skip zero amounts
    if amount == 0.0:
        return None
    
    # Determine transaction type
    tx_type = ''
    low = body.lower()
    if re.search(r'\bcredit(?:ed|s)?\b', low) or 'received' in low or 'credited with' in low:
        tx_type = 'credit'
    if re.search(r'\bdebit(?:ed|s)?\b', low) or 'withdraw' in low or 'debited with' in low or \
       'has been debited' in low or 'your account has been debited' in low:
        tx_type = 'debit'
    
    # Apply sign for debit
    if tx_type == 'debit' and amount > 0:
        amount = -abs(amount)
    
    # Extract VAT and service fees
    vat, service_fee, total = extract_vat_and_service(body, principal_amount=amount if amount != 0 else None)
    
    # Extract counterparty
    title = extract_counterparty(body) or ''
    title = title.strip()
    
    # Extract links
    links = re.findall(r'https?://\S+', body)
    
    # Detect tags
    tags = detect_tags(body)
    
    # Calculate confidence (simple heuristic)
    confidence = 0.0
    if amount != 0:
        confidence += 0.3
    if tx_type:
        confidence += 0.2
    if account_name:
        confidence += 0.2
    if fields.get('transaction_id'):
        confidence += 0.2
    if title:
        confidence += 0.1
    
    # Transaction ID
    transaction_id = fields.get('transaction_id', '')
    
    return ParsedTransaction(
        amount=amount,
        account_name=account_name,
        account_number=account_num,
        date=date.strftime('%Y-%m-%d'),
        time=date.strftime('%H:%M:%S'),
        type=tx_type,
        category='undefined',
        title=title,
        notes=body,
        link='|'.join(links),
        error='',
        vat=vat,
        service_fee=service_fee,
        tags=tags,
        transaction_id=transaction_id,
        confidence=confidence,
        email_id=email_data.get('id', ''),
        raw_email=email_data.get('raw', '')
    )


def parse_emails(imap_server: str, email_address: str, app_password: str) -> List[Dict]:
    """Main function to fetch and parse emails"""
    parser = EmailParser(imap_server, email_address, app_password)
    
    if not parser.connect():
        return []
    
    try:
        emails = parser.fetch_unread_emails()
        transactions = []
        
        for email_data in emails:
            transaction = parse_email_transaction(email_data)
            if transaction:
                transactions.append(asdict(transaction))
                # Mark as read after successful parsing
                parser.mark_as_read(email_data['id'])
        
        return transactions
    finally:
        parser.disconnect()


if __name__ == '__main__':
    # Example usage
    import os
    from dotenv import load_dotenv
    
    load_dotenv()
    
    transactions = parse_emails(
        imap_server=os.getenv('IMAP_SERVER', 'imap.gmail.com'),
        email_address=os.getenv('EMAIL_ADDRESS', ''),
        app_password=os.getenv('APP_PASSWORD', '')
    )
    
    print(f"Parsed {len(transactions)} transactions")
    for tx in transactions:
        print(json.dumps(tx, indent=2))
