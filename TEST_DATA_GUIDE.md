# Test Data Guide - Trek Search

## ✅ Sample Trek Added Successfully!

A sample trek has been added to your local database for testing the search functionality.

## 📱 How to Search in the App

### Step 1: Open the App
The app should be running on your Android emulator.

### Step 2: Search for Trek
Use these exact values to find the test trek:

**Search Parameters:**
- **City**: Bangalore (or select from dropdown)
- **Destination**: Coorg (or select from dropdown)  
- **Date**: **March 10, 2026** (2026-03-10)

### Trek Details
- **Trek ID**: 89
- **Title**: Weekend Trek to Coorg
- **Description**: Experience the beautiful coffee plantations and misty hills of Coorg. Perfect weekend getaway with moderate trekking. Enjoy nature walks, visit Abbey Falls, and explore local culture.
- **Duration**: 2 Days 1 Night
- **Price**: ₹2,999
- **Max Participants**: 20
- **Status**: Active & Approved

### Available Batch
- **Batch ID**: 472
- **Start Date**: March 10, 2026
- **End Date**: March 12, 2026
- **Available Slots**: 20

## 🔍 Testing the Search Flow

### 1. From Dashboard
1. Tap on search/explore treks
2. Select "Bangalore" as city
3. Select "Coorg" as destination
4. Pick date: March 10, 2026
5. Tap "Search"

### 2. Expected Result
You should see:
- Trek card showing "Weekend Trek to Coorg"
- Price: ₹2,999
- Duration: 2 Days 1 Night
- Available slots: 20

### 3. Trek Details
Tap on the trek card to see:
- Full description
- Itinerary (if added)
- Inclusions/Exclusions
- Booking button

## 🗄️ Database Information

### Trek Table
```sql
SELECT * FROM treks WHERE id = 89;
```

### Batch Table
```sql
SELECT * FROM batches WHERE trek_id = 89;
```

### City & Destination
```sql
-- City: Bangalore
SELECT * FROM cities WHERE id = 22;

-- Destination: Coorg
SELECT * FROM destinations WHERE id = 56;
```

## 🔧 Adding More Test Data

### Add Another Batch
```bash
cd arbo-trck-back_updated
node add-batches.js
```

### Add More Treks
Modify `add-simple-trek.js` and change:
- Title
- Description
- Destination ID
- City IDs
- Price

Then run:
```bash
node add-simple-trek.js
```

## 🐛 Troubleshooting

### Trek Not Showing in Search

**Check 1: Verify trek exists**
```bash
cd arbo-trck-back_updated
node -e "const {sequelize} = require('./models'); sequelize.query('SELECT id, title, status, trek_status FROM treks WHERE id = 89').then(([r]) => { console.log(r); sequelize.close(); });"
```

**Check 2: Verify batch exists**
```bash
node -e "const {sequelize} = require('./models'); sequelize.query('SELECT * FROM batches WHERE trek_id = 89').then(([r]) => { console.log(r); sequelize.close(); });"
```

**Check 3: Check API response**
Look at backend logs when you search. You should see:
```
GET /api/v1/treks?city_id=22&destination_id=56&start_date=2026-03-10
```

**Check 4: Verify app is calling local backend**
Flutter logs should show:
```
http://10.0.2.2:3001/api/v1/treks?...
```

NOT:
```
https://api.aorbotreks.co.in/api/v1/treks?...
```

### Empty Response

If the API returns empty data:
1. Check if trek status is 'active' and trek_status is 'approved'
2. Verify city_ids contains the city ID (should be `[22]` for Bangalore)
3. Check if batch date matches or is after the search date

### Database Errors

If you see JSON errors in backend logs:
```sql
-- Check city_ids format
SELECT id, title, city_ids FROM treks WHERE id = 89;
-- Should be: [22] or ["22"]

-- Fix if needed
UPDATE treks SET city_ids = '[22]' WHERE id = 89;
```

## 📊 API Endpoints for Testing

### Search Treks
```
GET http://localhost:3001/api/v1/treks?city_id=22&destination_id=56&start_date=2026-03-10
```

### Get Trek Details
```
GET http://localhost:3001/api/v1/treks/89
```

### Get Cities
```
GET http://localhost:3001/api/v1/cities
```

### Get Destinations
```
GET http://localhost:3001/api/v1/destinations
```

## 🎯 Next Steps

1. ✅ Trek data is added
2. ✅ Batch is available
3. 🧪 Test search in the app
4. 🧪 Test trek details view
5. 🧪 Test booking flow (if you want to test further)

## 💡 Tips

- Use the exact date: **March 10, 2026** for guaranteed results
- Make sure the app is connected to local backend (10.0.2.2:3001)
- Check backend terminal for incoming API requests
- If trek doesn't show, check backend logs for errors

## 🚀 Quick Test Command

To verify everything is set up:
```bash
curl "http://localhost:3001/api/v1/treks?city_id=22&destination_id=56&start_date=2026-03-10"
```

You should see JSON response with the trek data!

---

**Happy Testing! 🎉**
