#!/bin/bash

# Stock Report - Daily market quotes  
# Stocks: IBIT, GDX, GLD, SLV, MSTR
# 
# To enable live quotes:
# 1. Register for FREE at https://finnhub.io or https://marketstack.com
# 2. Set environment variable: export FINNHUB_API_KEY="your_key_here"
# 3. Or add to ~/.bashrc for persistent access

STOCKS="IBIT GDX GLD SLV MSTR"
TIMESTAMP=$(date '+%A, %B %d, %Y at %I:%M %p')

echo "📈 STOCK REPORT - $TIMESTAMP"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Function to fetch real stock data
get_stock_quote() {
    local symbol=$1
    
    # If API key is set, use real data
    if [ ! -z "$FINNHUB_API_KEY" ]; then
        response=$(curl -s "https://finnhub.io/api/v1/quote?symbol=$symbol&token=$FINNHUB_API_KEY" 2>/dev/null)
        
        # Parse JSON response
        c=$(echo "$response" | grep -o '"c":[0-9.]*' | cut -d':' -f2)
        d=$(echo "$response" | grep -o '"d":[^,]*' | cut -d':' -f2)
        dp=$(echo "$response" | grep -o '"dp":[^,]*' | cut -d':' -f2)
        
        if [ ! -z "$c" ] && [ "$c" != "null" ]; then
            # Determine emoji based on change
            if (( $(echo "$d > 0" | bc -l 2>/dev/null) )); then
                emoji="📈"
                sign="+"
            else
                emoji="📉"
                sign=""
            fi
            
            # Format output
            price=$(printf "%.2f" "$c" 2>/dev/null || echo "$c")
            change=$(printf "%.2f" "$d" 2>/dev/null || echo "$d")
            change_pct=$(printf "%.2f" "$dp" 2>/dev/null || echo "$dp")
            
            echo ""
            echo "$emoji $symbol"
            echo "   Price: \$$price | Change: $sign$change ($sign$change_pct%)"
            return
        fi
    fi
    
    # Fallback: Show placeholder for demo
    echo ""
    echo "📊 $symbol"
    echo "   Price: --  | Change: -- (API key needed)"
}

# Fetch quotes for each stock
for stock in $STOCKS; do
    get_stock_quote "$stock"
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
    echo "✅ Using Finnhub API for live quotes"
fi
