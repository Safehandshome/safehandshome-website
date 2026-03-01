# GoDaddy DNS Setup - Click-by-Click Guide

## Follow These Exact Steps

### Step 1: Go to GoDaddy Products
1. Open **godaddy.com**
2. Log in with: `soulturnaround@icloud.com`
3. Click **Products** (top menu)
4. Click **My Products**

### Step 2: Access Your Domain
1. Find `safehandshomeandtechrepair.com` in the list
2. Click on it
3. You'll see domain settings

### Step 3: Open DNS Records
1. Look for **DNS** button or link (usually on left sidebar)
2. Click it
3. You should see a list of existing DNS records

### Step 4: Add First Record (CNAME for www)

**In GoDaddy DNS Records page:**

1. Scroll down and look for **+ Add Record** button (or **+** icon)
2. Click it
3. You'll see a form appear:
   - **Type:** Click dropdown → Select **CNAME**
   - **Name:** Type `www` (just www, nothing else)
   - **Value:** Paste: `willowy-centaur-e8d635.netlify.app`
   - **TTL:** Leave as default (usually "1 hour")
4. Click **Save** button

**Expected result:** You should see a new line in your DNS records:
```
CNAME    www    willowy-centaur-e8d635.netlify.app    1 hour
```

### Step 5: Add Second Record (A Record for @)

1. Click **+ Add Record** button again
2. A new form appears:
   - **Type:** Click dropdown → Select **A**
   - **Name:** Type `@` (just the @ symbol, nothing else)
   - **Value:** Paste: `98.84.224.111`
   - **TTL:** Leave as default (usually "1 hour")
3. Click **Save** button

**Expected result:** You should see a new line:
```
A    @    98.84.224.111    1 hour
```

---

## After Saving

### Wait & Test

**Wait 5-15 minutes** for DNS to propagate, then:

1. Open a **new browser tab** (or incognito window)
2. Type: `https://www.safehandshomeandtechrepair.com`
3. Press Enter
4. You should see your SafeHands website! ✅

5. Also try: `https://safehandshomeandtechrepair.com` (without www)
6. Should also show your site ✅

### Check for HTTPS Lock
- You should see a **green lock** 🔒 in the address bar
- If not, that's normal - wait 24 hours for SSL certificate

---

## Your DNS Records Should Look Like This

When you're done, GoDaddy's DNS Records page should show something like:

```
┌───────────────────────────────────────────────────┐
│ TYPE | NAME | VALUE                           | TTL│
├───────────────────────────────────────────────────┤
│  A   │  @   │ 1.2.3.4 (GoDaddy's default)    │    │
│ CNAME│  www │ willowy-centaur-e8d635.netlify.app │ 1h│
│  A   │  @   │ 98.84.224.111                  │ 1h│
└───────────────────────────────────────────────────┘
```

(Note: You might have some GoDaddy defaults mixed in - that's ok)

---

## Didn't Work? Troubleshooting

### Still showing "unregistered nameserver" error?
- **You're in the wrong section!** Don't use "Change Nameservers"
- Use **DNS Records** section instead
- Click **+ Add Record** to add CNAME and A records

### Domain still shows GoDaddy parked page?
- DNS hasn't propagated yet - **wait 10-30 minutes**
- Try opening in incognito mode / different browser
- Go back to GoDaddy and verify your records saved (both CNAME and A should be there)

### Site shows but no HTTPS lock?
- That's normal during the first 24 hours
- Netlify is issuing the SSL certificate automatically
- Check back in 24 hours

### Forms not working on new domain?
- Make sure your site loads first (https://www.safehandshomeandtechrepair.com)
- Forms work the same as before - no configuration needed
- Give it 24 hours for full SSL/DNS propagation

---

## You're Done! 🎉

Once DNS propagates (usually 5-15 minutes):

✅ Your site is live at: **https://safehandshomeandtechrepair.com**  
✅ Forms are working: Contact submissions work normally  
✅ SSL certificate: Green lock in browser  
✅ Both URLs work:
- https://www.safehandshomeandtechrepair.com
- https://safehandshomeandtechrepair.com

---

## Questions?

**Email/Contact:** Your existing setup handles everything
**Need help?** Netlify support at https://docs.netlify.com/domains-https/custom-domains/

**Your domain:** safehandshomeandtechrepair.com  
**Your Netlify site:** willowy-centaur-e8d635  
**Your website:** willowy-centaur-e8d635.netlify.app (still works as backup)
