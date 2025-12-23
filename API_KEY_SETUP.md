# 🔑 How to Add Your Gemini API Key

## Quick Steps:

1. **Get your API key** from: https://makersuite.google.com/app/apikey

2. **Open this file**: `lib/core/constants/gemini_config.dart`

3. **Replace** `'YOUR_API_KEY_HERE'` with your actual API key:
   ```dart
   static const String apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
   ```

4. **Save** the file

5. **Run** the app - Gemini AI will now work!

## ⚠️ Important Notes:

- **Keep it secret**: Don't commit your API key to Git
- **Free tier**: 60 requests/minute (plenty for testing)
- **Offline fallback**: App will use keyword-based classification if API fails

## 🧪 Test It:

After adding your key, scan a receipt and check the logs for:
```
✅ Gemini AI initialized successfully
🤖 Gemini AI analyzing receipt...
✅ Gemini AI predicted: Food
```

---

**Once you have your API key, paste it here and I'll add it to the code!** 🚀
