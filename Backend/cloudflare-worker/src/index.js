/**
 * Aujunpeak key verification backend (Cloudflare Worker + KV).
 * HTTPS POST /api/activate {key, vendorId, model}.
 * Keys are indexed by SHA-256 digest; high-entropy keys are required.
 * No login fallback: invalid/expired keys fail closed.
 * Optional device binding: KV entry boundVendorId is locked to first activated IDFV.
 * KV's eventual consistency makes device-lock best-effort; use Durable Objects/DB transactions
 * if strict atomic single-device binding is required.
 */
const encoder = new TextEncoder();

async function digestKey(key) {
  const bytes = await crypto.subtle.digest('SHA-256', encoder.encode(key));
  return [...new Uint8Array(bytes)].map(b => b.toString(16).padStart(2, '0')).join('');
}
function json(body, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' }
  });
}

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === '/health' && request.method === 'GET') {
      return json({ status: 'online' });
    }
    if (url.pathname !== '/api/activate' || request.method !== 'POST') {
      return json({ valid: false, message: 'Not found' }, 404);
    }
    const contentLength = Number(request.headers.get('content-length') || 0);
    if (contentLength > 2048) return json({ valid: false, message: 'Request too large' }, 413);
    let payload;
    try { payload = await request.json(); }
    catch { return json({ valid: false, message: 'JSON không hợp lệ.' }, 400); }
    const { key, vendorId } = payload || {};
    if (typeof key !== 'string' || typeof vendorId !== 'string' ||
        key.length < 12 || key.length > 256 || vendorId.length > 100 || !vendorId) {
      return json({ valid: false, message: 'Key hoặc IDFV không hợp lệ.' }, 400);
    }
    if (!env.KEYS) return json({ valid: false, message: 'Máy chủ chưa cấu hình KV.' }, 503);
    const hash = await digestKey(key.trim());
    const recordKey = `key:${hash}`;
    const record = await env.KEYS.get(recordKey, { type: 'json' });
    if (!record || record.disabled === true) return json({ valid: false, message: 'Key không hợp lệ.' }, 401);
    if (record.expiresAt && Date.parse(record.expiresAt) <= Date.now()) {
      return json({ valid: false, message: 'Key đã hết hạn.' }, 403);
    }
    if (record.boundVendorId && record.boundVendorId !== vendorId) {
      return json({ valid: false, message: 'Key đã được liên kết với thiết bị khác.' }, 403);
    }
    if (!record.boundVendorId) {
      await env.KEYS.put(recordKey, JSON.stringify({ ...record, boundVendorId: vendorId }));
    }
    return json({
      valid: true,
      displayName: String(record.displayName || 'Aujunpeak Member').slice(0, 64),
      tier: String(record.tier || 'Member').slice(0, 32),
      expiresAt: record.expiresAt || null
    });
  }
};
