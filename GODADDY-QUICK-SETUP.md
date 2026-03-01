# GoDaddy to Netlify - QUICK SETUP ⚡

## Your Domain: safehandshomeandtechrepair.com
## Your Netlify Site: willowy-centaur-e8d635.netlify.app

---

## The Issue
GoDaddy doesn't recognize Netlify's nameservers. **Solution: Use DNS records instead (CNAME method).**

---

## What to Do in GoDaddy - 3 Simple Steps

### 1. Log into GoDaddy
- Go to **godaddy.com**
- Sign in
- Click **Products** → **My Products**
- Find `safehandshomeandtechrepair.com`

### 2. Click DNS Settings
- Click on your domain
- Click the **DNS** button (left sidebar)

### 3. Add DNS Records

You'll see existing records. **Add these two new records:**

---

## DNS Records to Add

### Record 1: CNAME for www
```
Type:  CNAME
Name:  www
Value: willowy-centaur-e8d635.netlify.app
TTL:   1 hour
```

**Steps:**
1. Click **+ Add Record** button
2. Select Type: **CNAME**
3. Name: type `www`
4. Value: paste `willowy-centaur-e8d635.netlify.app`
5. TTL: leave as default or set to 1 hour
6. Click **Save**

### Record 2: A Record for @ (root domain)
```
Type:  A
Name:  @
Value: 98.84.224.111
TTL:   1 hour
```

**Steps:**
1. Click **+ Add Record** button
2. Select Type: **A**
3. Name: type `@`
4. Value: paste `98.84.224.111`
5. TTL: leave as default or set to 1 hour
6. Click **Save**

---

## After You Save

### Wait 5-30 minutes
DNS records propagate quickly (usually 5-15 minutes)

### Test Your Domain
Open these in your browser:
- ✅ https://www.safehandshomeandtechrepair.com (should show your site)
- ✅ https://safehandshomeandtechrepair.com (should also show your site)

### Check SSL Certificate
- Green lock icon should appear 🔒
- Takes up to 24 hours for full SSL

---

## In Netlify Dashboard (Optional but Recommended)

Once DNS is working:

1. Go to: https://app.netlify.com/projects/willowy-centaur-e8d635
2. Click **Settings** → **Domain Management**
3. Click **Add custom domain**
4. Type: `safehandshomeandtechrepair.com`
5. Click **Verify**
6. Netlify confirms your DNS and activates the domain

---

## Your Forms Will Automatically Work
- All submissions route to Netlify's form system
- No additional setup needed
- Both URLs work: Netlify temporary domain + your custom domain

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Invalid nameserver" error | You don't need nameservers - use DNS records (CNAME/A) |
| Domain shows parked page | Wait 10-30 minutes for DNS to propagate |
| HTTPS warning | Wait 24 hours for SSL certificate to issue |
| Forms not working | Verify www/root domain loads your site first |

---

## Quick Reference

| What | Value |
|-----|-------|
| Your Domain | safehandshomeandtechrepair.com |
| Netlify Site | willowy-centaur-e8d635 |
| Netlify Domain | willowy-centaur-e8d635.netlify.app |
| CNAME Value | willowy-centaur-e8d635.netlify.app |
| A Record IP | 98.84.224.111 |

---

**Your site is already fully functional at willowy-centaur-e8d635.netlify.app**  
This just points your custom domain to it.

Let me know when your DNS records are added! 🚀
