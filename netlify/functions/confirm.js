exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'Method Not Allowed' };

  const SENDGRID_API_KEY = process.env.SENDGRID_API_KEY;
  let data;
  try { data = JSON.parse(event.body); } catch(e) {
    const p = new URLSearchParams(event.body);
    data = Object.fromEntries(p.entries());
  }

  const { name, email, message } = data;
  if (!email) return { statusCode: 400, body: 'No email' };

  const body = {
    personalizations: [{ to: [{ email, name: name || 'there' }] }],
    from: { email: 'soulturnaround@icloud.com', name: 'SafeHands Home & Tech Repair' },
    reply_to: { email: 'soulturnaround@icloud.com' },
    subject: 'We received your message — SafeHands Home & Tech Repair',
    content: [{
      type: 'text/html',
      value: `
        <div style="font-family:Arial,sans-serif;max-width:600px;margin:0 auto;background:#0a1628;color:#fff;border-radius:12px;overflow:hidden;">
          <div style="background:#0047ab;padding:24px 32px;">
            <h1 style="margin:0;font-size:1.4rem;">SafeHands Home & Tech Repair</h1>
            <p style="margin:4px 0 0;opacity:0.85;font-size:0.9rem;">Professional Home & Technology Services · NJ</p>
          </div>
          <div style="padding:32px;">
            <h2 style="margin-top:0;">Message Received! ✅</h2>
            <p>Hi ${name || 'there'},</p>
            <p>Thanks for contacting SafeHands Home & Tech Repair. We received your message and will get back to you <strong>within 24 hours</strong>.</p>
            ${message ? `<div style="background:#1a2a4a;border:1px solid #2a3a5a;border-radius:8px;padding:16px;margin:20px 0;"><p style="margin:0 0 8px;font-size:0.85rem;color:#aaa;">YOUR MESSAGE</p><p style="margin:0;">${message}</p></div>` : ''}
            <p>Feel free to reply to this email if you have any additional details to add.</p>
            <p style="margin-top:32px;color:#aaa;font-size:0.85rem;">— George, SafeHands Home & Tech Repair<br>safehandshomeandtech.com</p>
          </div>
        </div>`
    }]
  };

  const res = await fetch('https://api.sendgrid.com/v3/mail/send', {
    method: 'POST',
    headers: { 'Authorization': `Bearer ${SENDGRID_API_KEY}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body)
  });

  return { statusCode: res.ok ? 200 : 500, body: res.ok ? 'OK' : 'Error' };
};
