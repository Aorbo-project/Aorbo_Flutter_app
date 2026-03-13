# Flutter App & Backend Connection Status

## ✅ Current Status

### Backend
- **Status**: ✅ Running
- **URL**: http://localhost:3001
- **Database**: MySQL (aorbo_trekking)
- **Environment**: Development

### Flutter App
- **Status**: ✅ Running on Android Emulator
- **Device**: sdk gphone64 x86 64 (emulator-5554)
- **Mode**: Debug
- **API Configuration**: ✅ Updated to use local backend

### Configuration Applied
```dart
// lib/repository/network_url.dart
static const String baseUrl = "http://10.0.2.2:3001/api/v1/";
static const String imageUrl = "http://10.0.2.2:3001/";
static const String socketUrl = "http://10.0.2.2:3001";
```

## 🔧 Known Issues & Solutions

### Issue 1: Database Schema Mismatch
**Problem**: Some seeders fail due to missing columns (e.g., `notes` in vendors table)

**Impact**: Some features may not work until database is fully seeded

**Solution**: The basic data (cities, destinations, activities, badges) is seeded. Trek data may need manual addition or production database import.

### Issue 2: JSON Contains Error
**Problem**: "Invalid data type for JSON data in argument 1 to function json_contains"

**Impact**: Trek search queries may fail

**Solution**: This is a database query issue in the backend. The backend code expects JSON fields but the database schema might be different.

## 📱 Testing the Connection

### 1. Test Backend Health
Open in browser or use curl:
```bash
curl http://localhost:3001/api/v1/
```

### 2. Test from Flutter App
1. Open the app on emulator
2. Try to login with a phone number
3. Check backend terminal for incoming requests

### 3. Monitor Logs

**Backend Logs** (Terminal 4):
```bash
# Check process
Get-Process node

# View logs in real-time
# Already running in background process
```

**Flutter Logs** (Terminal 6):
```bash
# App is running, logs show in terminal
# Look for API requests starting with:
# "💡 ➡️ onRequest: URI ->> http://10.0.2.2:3001/api/v1/..."
```

## 🎯 Next Steps

### 1. Add Sample Trek Data
The database needs trek data to display in the app. Options:

**Option A**: Import from production database
```sql
-- Export from production
mysqldump -h production_host -u user -p aorbo_trekking treks batches > treks_data.sql

-- Import to local
mysql -u root aorbo_trekking < treks_data.sql
```

**Option B**: Use the demo trek seeder (has schema issues currently)
```bash
cd arbo-trck-back_updated
npm run seed:demoTrek
```

**Option C**: Add treks manually through admin panel or API

### 2. Fix Database Schema Issues
Run database sync to ensure all tables match the models:
```bash
cd arbo-trck-back_updated
npm run sync
```

### 3. Test Key Features
- ✅ Login/OTP
- ⏳ Browse treks (needs trek data)
- ⏳ Search treks (needs trek data)
- ⏳ Booking flow (needs trek data)
- ⏳ User profile

## 🔍 Debugging Tips

### Check if App is Calling Local Backend
Look for these in Flutter logs:
```
✅ Good: http://10.0.2.2:3001/api/v1/...
❌ Bad: https://api.aorbotreks.co.in/api/v1/...
```

### Check Backend Receives Requests
Backend logs should show:
```
11:XX:XX [info]: Request received: GET /api/v1/cities
{
  "requestId": "req-...",
  "method": "GET",
  "url": "/api/v1/cities",
  "ip": "::ffff:127.0.0.1"
}
```

### Common Connection Issues

**Issue**: App still calls production API
**Solution**: Hot restart the app (press 'R' in Flutter terminal)

**Issue**: Backend not responding
**Solution**: Check if backend is running: `Get-Process node`

**Issue**: Database connection error
**Solution**: Verify MySQL is running and credentials in `.env` are correct

## 📊 Available API Endpoints

### Working Endpoints (No Trek Data Required)
- GET `/api/v1/cities` - List of cities
- GET `/api/v1/states` - List of states  
- GET `/api/v1/destinations` - List of destinations
- POST `/api/v1/customer/auth/request-otp` - Request OTP
- POST `/api/v1/customer/auth/firebase-verify` - Verify token

### Endpoints Requiring Trek Data
- GET `/api/v1/treks` - Search treks
- GET `/api/v1/treks/:id` - Trek details
- POST `/api/v1/customer/bookings/create-trek-order` - Create booking

## 🚀 Quick Commands

### Restart Backend
```powershell
# Stop
Stop-Process -Name node

# Start
cd arbo-trck-back_updated
npm start
```

### Restart Flutter App
```powershell
# In Flutter terminal, press 'R' for hot restart
# Or stop and restart:
flutter run -d emulator-5554
```

### Check Running Processes
```powershell
# Backend
Get-Process node

# Flutter/Emulator
flutter devices
```

## 📝 Summary

✅ Backend is running on localhost:3001  
✅ Flutter app is configured to use local backend (10.0.2.2:3001)  
✅ App is running on Android emulator  
✅ Basic database tables are seeded (cities, states, destinations, activities)  
⚠️ Trek data is missing - app will show empty lists  
⚠️ Some database schema issues exist but don't block basic functionality  

**The connection is established and working!** The app can now communicate with your local backend. The main limitation is the lack of trek data in the database.
