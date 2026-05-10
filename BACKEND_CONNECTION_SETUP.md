# Backend Connection Setup

## Backend Status
✅ Backend is running on `http://localhost:3001`
- Database: MySQL (aorbo_trekking)
- Environment: Development
- Email Service: Active

## Flutter App Configuration

### API Endpoints
The Flutter app has been configured to connect to your local backend:

**File:** `lib/repository/network_url.dart`

```dart
// Local Development URL (Android Emulator)
static const String baseUrl = "http://10.0.2.2:3001/api/v1/";

// Local Development image URL
static const String imageUrl = "http://10.0.2.2:3001/";

// Socket.IO base URL (Local Development)
static const String socketUrl = "http://10.0.2.2:3001";
```

### Why 10.0.2.2?
- Android emulator uses `10.0.2.2` to access the host machine's `localhost`
- This is a special alias that routes to your computer's localhost:3001

## Testing the Connection

### 1. Backend Health Check
Open in browser: http://localhost:3001/api/v1/

### 2. Test from Flutter App
Once the app launches on the emulator:
1. Try to login with a phone number
2. The app will send OTP request to: `http://10.0.2.2:3001/api/v1/customer/auth/request-otp`
3. Check backend logs for incoming requests

## Available API Endpoints

### Authentication
- POST `/api/v1/customer/auth/request-otp` - Request OTP
- POST `/api/v1/customer/auth/firebase-verify` - Verify Firebase token

### Treks
- GET `/api/v1/cities` - Get cities list
- GET `/api/v1/destinations` - Get destinations
- GET `/api/v1/treks` - Search treks
- GET `/api/v1/treks/:id` - Get trek details

### User
- GET `/api/v1/customer/auth/profile` - Get user profile
- POST `/api/v1/customer/travelers` - Add traveller
- POST `/api/v1/customer/bookings/create-trek-order` - Create booking
- GET `/api/v1/customer/bookings` - Booking history

### Chat (Socket.IO)
- Socket URL: `http://10.0.2.2:3001`
- Events: `join_chat`, `send_message`, `receive_message`

## Switching Between Local and Production

### To use Production API:
Edit `lib/repository/network_url.dart`:

```dart
// Comment out local URLs
// static const String baseUrl = "http://10.0.2.2:3001/api/v1/";

// Uncomment production URLs
static const String baseUrl = "https://api.aorbotreks.co.in/api/v1/";
static const String imageUrl = "https://api.aorbotreks.co.in/";
static const String socketUrl = "https://api.aorbotreks.co.in";
```

### To use Local API on Physical Device:
Replace `10.0.2.2` with your computer's local IP address:

```dart
// Find your IP: ipconfig (Windows) or ifconfig (Mac/Linux)
static const String baseUrl = "http://192.168.1.XXX:3001/api/v1/";
```

## Troubleshooting

### Backend not responding
1. Check if backend is running: `Get-Process node`
2. Check backend logs in terminal
3. Verify database is running (MySQL on localhost:3306)

### Flutter app can't connect
1. Verify you're using `10.0.2.2` for Android emulator
2. Check if backend is accessible: `curl http://localhost:3001/api/v1/`
3. Check Flutter app logs for network errors

### Database connection issues
1. Verify MySQL is running
2. Check `.env` file in backend:
   - DB_HOST=localhost
   - DB_PORT=3306
   - DB_NAME=aorbo_trekking
   - DB_USER=root
   - DB_PASSWORD=

## Next Steps

1. ✅ Backend is running
2. ✅ Flutter app is configured
3. ⏳ Wait for Flutter app to finish building on emulator
4. 🧪 Test login functionality
5. 🧪 Test API calls from the app

## Backend Process Management

### Check if backend is running:
```powershell
Get-Process node
```

### Stop backend:
Use Kiro's process management or:
```powershell
Stop-Process -Name node
```

### Restart backend:
```powershell
cd arbo-trck-back_updated
npm start
```

## Current Status
- ✅ Backend: Running on port 3001
- ✅ Database: Connected (aorbo_trekking)
- ✅ Flutter: Building for Android emulator
- ✅ API URLs: Configured for local development
