# GoDaddy DNS Setup - CNAME Method (Alternative)

## Your Domain: safehandshomeandtechrepair.com

If GoDaddy won't accept Netlify nameservers, use CNAME records instead. This is often more reliable.

---

## Step-by-Step CNAME Configuration

### 1. Log into GoDaddy
- Go to **godaddy.com**
- Sign in with your account (soulturnaround@icloud.com)
- Go to **Products** → **My Products**
- Find your domain `safehandshomeandtechrepair.com`

### 2. Access DNS Records
- Click on your domain name
- Click **DNS** (on the left sidebar)
- Look for **DNS Records** section (scroll down)
- You should see existing A records and CNAME records

### 3. Add CNAME Record for www

**Add a new CNAME record:**

| Field | Value |
|-------|-------|
| **Type** | CNAME |
| **Name** | www |
| **Value** | willowy-centaur-e8d635.netlify.app |
| **TTL** | 1 hour (or default) |

**Steps:**
1. Click **Add Record** (or **+** button)
2. Select Type: **CNAME**
3. Name: `www`
4. Value: `willowy-centaur-e8d635.netlify.app`
5. Click **Save**

### 4. Update @ (Root) Domain - OPTION A: A Record

If you want the root domain (`safehandshomeandtechrepair.com` without www) to work:

**Get Netlify's IP Address:**
```bash
nslookup willowy-centaur-e8d635.netlify.app
```

Look for the **A record** IP address (usually something like `98.84.224.111`)

**In GoDaddy DNS Records:**
| Field | Value |
|-------|-------|
| **Type** | A |
| **Name** | @ |
| **Value** | [IP from nslookup above] |
| **TTL** | 1 hour (or default) |

---

## OR: Update @ (Root) Domain - OPTION B: Alias Record (Simpler)

**In GoDaddy DNS Records:**
| Field | Value |
|-------|-------|
| **Type** | ALIAS or ANAME |
| **Name** | @ |
| **Value** | willowy-centaur-e8d635.netlify.app |
| **TTL** | 1 hour (or default) |

⚠️ **Note:** Not all registrars support ALIAS. If GoDaddy doesn't have this option, use Option A (A record).

---

## Summary of DNS Records to Add

### Minimum (www only):
```
CNAME    www    willowy-centaur-e8d635.netlify.app
```

### Full Setup (root + www):
```
A        @      [Netlify IP - get from nslookup]
CNAME    www    willowy-centaur-e8d635.netlify.app
```

---

## Verification

After saving DNS records (5-15 minutes):

✅ **Test www subdomain:**
```bash
nslookup www.safehandshomeandtechrepair.com
```
Should resolve to Netlify IP

✅ **Visit website:**
- https://www.safehandshomeandtechrepair.com (should work)
- https://safehandshomeandtechrepair.com (might not work yet without A record)

✅ **Check SSL:**
- Green lock in browser
- Takes 24h for full SSL certificate

---

## Step-by-Step: Get Netlify's IP Address

Run this to find the IP:

```bash
nslookup willowy-centaur-e8d635.netlify.app
```

Look for output like:
```
Address: 98.84.224.111
```

Use that IP for the A record @ entry.

---

## Current Netlify Info

- **Netlify Site:** willowy-centaur-e8d635
- **Netlify Domain:** willowy-centaur-e8d635.netlify.app
- **Your Domain:** safehandshomeandtechrepair.com

---

## Troubleshooting

### Still getting GoDaddy error?
- Try using just `www` subdomain first (CNAME record only)
- Root domain (@) can be set up after www is working

### Domain shows GoDaddy parked page
- DNS records may not have propagated yet (5-30 minutes)
- Check GoDaddy shows your CNAME record was saved

### Forms not working on custom domain
- Make sure you're using the correct Netlify domain
- Wait 24h for full SSL certificate issuance

---

## Next: Add Domain in Netlify Dashboard

Once DNS is configured:
1. Go to https://app.netlify.com/projects/willowy-centaur-e8d635
2. Click **Settings** → **Domain Management**
3. Click **Add custom domain**
4. Enter: `safehandshomeandtechrepair.com`
5. Netlify will verify DNS and enable your domain

---

**Questions?** Netlify support: https://docs.netlify.com/domains-https/custom-domains/
