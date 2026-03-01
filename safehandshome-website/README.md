# SafeHands Home & Tech Repair LLC - Website

Professional website for SafeHands Home & Tech Repair LLC, a family-owned home services business serving Somerset, Morris, and Union counties in New Jersey.

## Features

- **Responsive Design** - Works on all devices (mobile, tablet, desktop)
- **Professional Branding** - Navy, white, and light blue color scheme matching your logo
- **Services Showcase** - All 7 services clearly displayed
- **Photo Gallery** - 17 portfolio images showing your work
- **Contact Form** - Netlify form submission (emails go to soulturnaround@icloud.com)
- **Fast Loading** - Optimized static HTML/CSS, no databases
- **SEO Ready** - Proper meta tags and structured content
- **Secure** - No sensitive business data in version control

## Setup for Deployment

### Prerequisites
- GitHub account (create at github.com if needed)
- Netlify account (create at netlify.com if needed)

### Steps

1. **Create GitHub Repository**
   - Go to github.com
   - Click "New repository"
   - Name: `safehandshome-website`
   - Make it public
   - Create repository

2. **Upload Files to GitHub**
   - Clone the repo locally OR upload files via GitHub web interface
   - Include all files: `index.html`, `README.md`, `.gitignore`
   - Create `gallery/` folder for images
   - Add all 17 photo files to `gallery/` folder

3. **Deploy to Netlify**
   - Go to netlify.com
   - Click "New site from Git"
   - Connect GitHub account
   - Select `safehandshome-website` repo
   - Use defaults: Branch=main, Build command=blank, Publish directory=.
   - Deploy!

4. **Configure Contact Form**
   - Netlify automatically detects `netlify` form attributes
   - Form submissions will be visible in Netlify dashboard
   - Email notifications will go to configured Netlify email

5. **(Optional) Add Custom Domain**
   - Purchase domain (GoDaddy, Namecheap, etc.)
   - Add domain in Netlify settings
   - Update DNS records as instructed by Netlify
   - Free SSL certificate included

## Gallery Images

Place all 17 photos in the `gallery/` folder with these names:

- `01-dryer-vent.jpg`
- `02-network-setup.jpg`
- `03-camera-install.jpg`
- `04-lawn-drone.jpg`
- `05-leaf-cleanup.jpg`
- `06-dryer-tutorial.jpg`
- `07-plumbing.jpg`
- `08-renovation.jpg`
- `09-tools.jpg`
- `10-mower.jpg`
- `11-excavation.jpg`
- `12-floor-sanding.jpg`
- `13-floor-result.jpg`
- `14-dining-floor.jpg`
- `15-tile-prep.jpg`
- `16-tile-cutting.jpg`
- `17-tile-install.jpg`

## Making Updates

To update content on the website:

1. Edit `index.html` in your text editor or GitHub web interface
2. Change text, add services, update hours, etc.
3. Commit changes to GitHub
4. Netlify automatically deploys (usually within 1-2 minutes)

### Common Updates

**Hours of Operation**: Search for "Hours" section in Services Area

**Contact Email**: Search for "soulturnaround@icloud.com" to find all instances

**Phone Number**: Add phone number when ready (search for "phone" in HTML)

**Services List**: Find the "Services Section" and add/remove service cards

**Business Description**: Find the "About Section" to update text

## Data Privacy

✅ **Your private business data is 100% secure**
- No sensitive info (email, phone, address) stored in version control
- Only public website content on GitHub/Netlify
- `.gitignore` prevents private folder from being committed
- Form submissions go directly to your email

## Support

For questions or updates, contact the developer.

---

**Website Version:** 1.0  
**Last Updated:** 2026-03-01  
**Status:** Ready for deployment
