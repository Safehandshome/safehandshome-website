#!/bin/bash
# Daily weather alert for Warren, NJ and Windham, VT
# Uses Open-Meteo API (free, no credits)

# Warren, NJ coordinates
WARREN_LAT="40.6562"
WARREN_LNG="-74.2808"
WARREN_NAME="Warren, NJ"

# Windham, VT coordinates
WINDHAM_LAT="44.3956"
WINDHAM_LNG="-72.4275"
WINDHAM_NAME="Windham, VT"

get_weather() {
  local lat=$1
  local lng=$2
  local name=$3
  
  # Fetch weather from Open-Meteo and save to temp file
  local tmpfile=$(mktemp)
  curl -s "https://api.open-meteo.com/v1/forecast?latitude=${lat}&longitude=${lng}&current=temperature_2m,weather_code,wind_speed_10m,relative_humidity_2m&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max" > "$tmpfile"
  
  # Parse with Python
  python3 << PYEOF
import sys, json

def c_to_f(c):
  return round((c * 9/5) + 32, 1)

try:
  with open('$tmpfile', 'r') as f:
    data = json.load(f)
  
  current = data['current']
  daily = data['daily']
  
  temp_c = current['temperature_2m']
  temp_f = c_to_f(temp_c)
  code = current['weather_code']
  humidity = current['relative_humidity_2m']
  wind = current['wind_speed_10m']
  
  today_max_c = daily['temperature_2m_max'][0]
  today_min_c = daily['temperature_2m_min'][0]
  today_max_f = c_to_f(today_max_c)
  today_min_f = c_to_f(today_min_c)
  
  precip_prob = daily['precipitation_probability_max'][0]
  precip_amt = daily['precipitation_sum'][0]
  
  # Weather code description
  conditions = {
    0: "Clear", 1: "Mostly Clear", 2: "Partly Cloudy", 3: "Overcast",
    45: "Foggy", 48: "Foggy (Depositing)",
    51: "Light Drizzle", 53: "Moderate Drizzle", 55: "Heavy Drizzle",
    61: "Slight Rain", 63: "Moderate Rain", 65: "Heavy Rain",
    71: "Slight Snow", 73: "Moderate Snow", 75: "Heavy Snow",
    77: "Snow Grains", 80: "Slight Rain Showers", 81: "Moderate Rain Showers",
    82: "Violent Rain Showers", 85: "Slight Snow Showers", 86: "Heavy Snow Showers",
    95: "Thunderstorm", 96: "Thunderstorm with Hail", 99: "Thunderstorm with Hail"
  }
  
  condition = conditions.get(code, "Unknown")
  
  print(f"🌡️ Now: {temp_f}°F ({condition})")
  print(f"📈 High: {today_max_f}°F | 📉 Low: {today_min_f}°F")
  print(f"💧 Humidity: {humidity}%")
  print(f"💨 Wind: {wind} km/h")
  
  if precip_prob > 0:
    precip_type = "Rain" if code not in [71, 73, 75, 77, 85, 86] else "Snow"
    print(f"⚠️  {precip_type}: {precip_prob}% chance ({precip_amt}mm)")
  else:
    print(f"✅ No precipitation expected")
    
except Exception as e:
  print(f"Error: {e}", file=sys.stderr)
  sys.exit(1)
PYEOF
  
  # Clean up temp file
  rm -f "$tmpfile"
}

echo "🌤️  WEATHER ALERT - $(date '+%A, %B %d, %Y at %I:%M %p')"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 ${WARREN_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
get_weather "$WARREN_LAT" "$WARREN_LNG" "$WARREN_NAME"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📍 ${WINDHAM_NAME}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
get_weather "$WINDHAM_LAT" "$WINDHAM_LNG" "$WINDHAM_NAME"
echo ""
