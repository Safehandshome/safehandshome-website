# GoDaddy DNS Setup for SafeHands Website

## Your Domain: safehandshomeandtechrepair.com

---

## Step-by-Step DNS Configuration

### 1. Log into GoDaddy
- Go to **godaddy.com**
- Sign in with your account (soulturnaround@icloud.com)
- Go to **Products** → **My Products**
- Find your domain `safehandshomeandtechrepair.com`

### 2. Access DNS Settings
- Click on your domain name
- Click **DNS** (on the left sidebar)
- Scroll to "Nameservers" section

### 3. Change Nameservers to Netlify

**Delete current nameservers** and replace with Netlify's:

```
dns1.netlify.com
dns2.netlify.com
dns3.netlify.com
dns4.netlify.com
```

**Steps:**
1. Click "Change Nameservers"
2. Select "I'll use my own nameservers"
3. Delete existing nameservers
4. Add the 4 Netlify nameservers above
5. Save changes

**⏱️ Propagation Time:** 24-48 hours (usually 1-2 hours)

---

## After DNS Changes Propagate

### In Netlify Dashboard
1. Go to: https://app.netlify.com/projects/willowy-centaur-e8d635
2. Click **Settings** → **Domain Management**
3. Click **Add custom domain**
4. Enter: `safehandshomeandtechrepair.com`
5. Click **Add Domain**
6. Verify SSL certificate (Netlify handles this automatically)

---

## Verification

Once DNS propagates (24-48 hours):

✅ Visit https://safehandshomeandtechrepair.com
- Should show your SafeHands website
- SSL certificate should be valid (green lock in browser)
- Forms should work normally

---

## Current Status

| Item | Status |
|------|--------|
| Domain Registered | ✅ safehandshomeandtechrepair.com |
| Netlify Site Ready | ✅ willowy-centaur-e8d635 |
| DNS Nameservers | ⏳ Awaiting your configuration |
| Custom Domain Added | ⏳ After DNS changes |
| SSL Certificate | ⏳ Auto-issued by Netlify after domain connects |

---

## Troubleshooting

### Domain shows GoDaddy parked page
- DNS hasn't propagated yet - wait 24-48 hours
- Check GoDaddy DNS settings are correct (4 Netlify nameservers)

### SSL certificate shows warning
- Normal during propagation - certificate auto-issues after 24h

### Forms not working on custom domain
- Check Netlify shows domain as connected (green checkmark)
- May take up to 48 hours for full SSL/DNS propagation

---

## Questions?

**Netlify Documentation:** https://docs.netlify.com/domains-https/custom-domains/

**Your Current Addresses:**
- Temporary: https://willowy-centaur-e8d635.netlify.app (still works)
- Custom: https://safehandshomeandtechrepair.com (after DNS setup)

---

**Next Steps:**
1. Log into GoDaddy now
2. Change nameservers to Netlify's 4 DNS servers above
3. Wait 24-48 hours for propagation
4. Verify domain works
5. Add domain in Netlify dashboard

Let me know when you've completed the GoDaddy DNS changes!
