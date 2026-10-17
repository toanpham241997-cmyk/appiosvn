// Run: node create-key.mjs ["display name"] ["ISO expiration"]
import { randomBytes, createHash } from 'node:crypto';
const key = `AJP-${randomBytes(20).toString('hex').toUpperCase()}`;
const hash = createHash('sha256').update(key).digest('hex');
const displayName = process.argv[2] || 'Aujunpeak Member';
const expiresAt = process.argv[3] || '2027-12-31T23:59:59Z';
console.log('LOGIN KEY (share privately):', key);
console.log('KV KEY:', `key:${hash}`);
console.log('KV VALUE:', JSON.stringify({ displayName, tier: 'Premium', expiresAt, disabled: false }));
console.log('Keep the key private. Store only the hash-based KV record.');
