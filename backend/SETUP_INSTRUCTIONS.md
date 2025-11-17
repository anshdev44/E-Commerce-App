# Setup Instructions for Razorpay Integration

## Step 1: Copy .env File

You have your Razorpay keys in `.env copy 2`. You need to:

1. **Copy the file** to create `.env` in the `backend` directory:
   - Copy `backend/.env copy 2` 
   - Rename it to `backend/.env`
   - OR manually create `backend/.env` with your keys

2. **Make sure the `.env` file is in the `backend` directory** (same folder as `main.py`)

## Step 2: Install python-dotenv

```bash
cd backend
pip install python-dotenv
```

## Step 3: Restart Backend Server

1. Stop the current backend server (Ctrl+C)
2. Start it again:
   ```bash
   python main.py
   ```

3. **Check the console output** - you should see:
   ```
   Razorpay client initialized
   ```
   
   If you see "Warning: Razorpay keys not found", check your `.env` file.

## Step 4: Restart Flutter App

1. **Stop the Flutter app** completely (not just hot reload)
2. **Clear browser cache** (Ctrl+Shift+Delete) or use incognito mode
3. **Restart Flutter**:
   ```bash
   flutter run -d chrome
   ```

## Step 5: Test Payment

1. Login to your app
2. Add a product to cart
3. Go to checkout
4. Fill in the form
5. Click "Proceed to Payment"
6. **Razorpay Checkout popup should open** (not the old demo message)

## Troubleshooting

- **If you still see the old message**: Do a full restart (stop and start both backend and Flutter)
- **If Razorpay popup doesn't open**: Check browser console (F12) for errors
- **If keys not loading**: Make sure `.env` file is in `backend` folder, not root folder









