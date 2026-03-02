#!/bin/bash

# After-Hours Stock Report - Daily market quotes  
# Stocks: IBIT, GDX, GLD, SLV, MSTR
# Runs at 6:30 AM - data fetched from previous day's after-hours session
# Sent to user at 6:35 AM
#
# To enable live quotes:
# 1. Register for FREE at https://finnhub.io
# 2. Set environment variable: export FINNHUB_API_KEY="your_key_here"
# 3. Or add to ~/.bashrc for persistent access

STOCKS="IBIT GDX GLD SLV MSTR"
TIMESTAMP=$(date '+%A, %B %d, %Y at %I:%M %p')
YESTERDAY=$(date -d yesterday '+%B %d, %Y')

echo "📊 AFTER-HOURS STOCK REPORT - $TIMESTAMP"
echo "Data from: Previous Trading Day ($YESTERDAY)"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Function to fetch real stock data
get_stock_afterhours() {
    local symbol=$1
    
    # If API key is set, use real data
    if [ ! -z "$FINNHUB_API_KEY" ]; then
        response=$(curl -s "https://finnhub.io/api/v1/quote?symbol=$symbol&token=$FINNHUB_API_KEY" 2>/dev/null)
        
        # Parse JSON response
        c=$(echo "$response" | grep -o '"c":[0-9.]*' | cut -d':' -f2)
        pc=$(echo "$response" | grep -o '"pc":[0-9.]*' | cut -d':' -f2)
        
        if [ ! -z "$c" ] && [ "$c" != "null" ]; then
            # Calculate after-hours change
            if [ ! -z "$pc" ] && [ "$pc" != "null" ]; then
                ah_change=$(echo "$c - $pc" | bc -l 2>/dev/null)
                ah_pct=$(echo "($ah_change / $pc) * 100" | bc -l 2>/dev/null)
            else
                ah_change="0"
                ah_pct="0"
            fi
            
            # Determine emoji based on after-hours change
            if (( $(echo "$ah_change > 0" | bc -l 2>/dev/null) )); then
                emoji="📈"
                sign="+"
            else
                emoji="📉"
                sign=""
            fi
            
            # Format output
            price=$(printf "%.2f" "$c" 2>/dev/null || echo "$c")
            change=$(printf "%.2f" "$ah_change" 2>/dev/null || echo "$ah_change")
            change_pct=$(printf "%.2f" "$ah_pct" 2>/dev/null || echo "$ah_pct")
            
            echo ""
            echo "$emoji $symbol"
            echo "   Current: \$$price | After-Hours Change: $sign$change ($sign$change_pct%)"
            return
        fi
    fi
    
    # Fallback: Show placeholder for demo
    echo ""
    echo "📊 $symbol"
    echo "   Current: --  | After-Hours Change: -- (API key needed)"
}

# Fetch quotes for each stock
for stock in $STOCKS; do
    get_stock_afterhours "$stock"
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# If no API key, show instructions
if [ -z "$FINNHUB_API_KEY" ]; then
    echo "⚠️  Live quotes unavailable (API key not configured)"
    echo ""
    echo "To enable live market data:"
    echo "1. Register FREE at: https://finnhub.io"
    echo "2. Copy your API key"
    echo "3. Run: export FINNHUB_API_KEY='your_key_here'"
    echo "4. Or add to ~/.bashrc for permanent setup"
else
    echo "✅ Using Finnhub API for live after-hours quotes"
fi
