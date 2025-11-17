# Razorpay Payment Integration Setup

## Prerequisites
1. Install python-dotenv: `pip install python-dotenv`
2. Create a `.env` file in the `backend` directory

## .env File Format

Create a `.env` file in the `backend` directory with the following format:

```
RAZORPAY_KEY_ID=your_razorpay_key_id_here
RAZORPAY_KEY_SECRET=your_razorpay_key_secret_here
```

Example:
```
RAZORPAY_KEY_ID=rzp_test_xxxxxxxxxxxxx
RAZORPAY_KEY_SECRET=xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Important Notes

1. **Test Mode Keys**: Use your Razorpay test mode keys (they start with `rzp_test_`)
2. **Security**: Never commit the `.env` file to version control
3. **Location**: The `.env` file should be in the same directory as `main.py` (the `backend` folder)

## Testing

1. Start the backend server: `python main.py`
2. You should see: "Razorpay client initialized" in the console
3. If you see "Warning: Razorpay keys not found", check your `.env` file

## Payment Flow

1. User clicks "Proceed to Payment" on checkout page
2. Backend creates a Razorpay order
3. Razorpay Checkout popup opens in the browser
4. User completes payment
5. Payment is verified and order is confirmed
6. User is redirected to success page

## Test Cards (Test Mode)

Use these test cards for testing:
- **Success**: 4111 1111 1111 1111
- **Failure**: 4000 0000 0000 0002
- **CVV**: Any 3 digits
- **Expiry**: Any future date
- **Name**: Any name









