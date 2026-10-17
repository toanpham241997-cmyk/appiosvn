import assert from 'node:assert/strict';
import { createHash, webcrypto } from 'node:crypto';
import worker from '../src/index.js';
if (!globalThis.crypto) globalThis.crypto = webcrypto;
const data = new Map();
const env = { KEYS: {
  async get(key, opts) {
    const val = data.get(key);
    return opts?.type === 'json' && val ? JSON.parse(val) : val;
  },
  async put(key, value) { data.set(key, value); }
}};
const token = 'AJP-' + 'a'.repeat(40);
const hash = createHash('sha256').update(token).digest('hex');
data.set(`key:${hash}`, JSON.stringify({displayName:'Test Member', tier:'VIP', expiresAt:'2099-01-01T00:00:00Z'}));
async function activate(key, vendorId='idfv-1') {
  const request = new Request('https://auth.example/api/activate', {
    method:'POST',headers:{'content-type':'application/json'},
    body:JSON.stringify({key,vendorId,model:'iPhone'})
  });
  const res = await worker.fetch(request, env);
  return {status:res.status,body:await res.json()};
}
const accepted = await activate(token);
assert.equal(accepted.status, 200);
assert.equal(accepted.body.valid,true);
assert.equal(accepted.body.displayName,'Test Member');
assert.equal(JSON.parse(data.get(`key:${hash}`)).boundVendorId,'idfv-1');
const sameDevice = await activate(token);
assert.equal(sameDevice.status,200);
const otherDevice = await activate(token,'idfv-2');
assert.equal(otherDevice.status,403);
const badKey = await activate('AJP-' + 'b'.repeat(40));
assert.equal(badKey.status,401);
const health = await worker.fetch(new Request('https://auth.example/health'), env);
assert.equal(health.status,200);
console.log('Worker key tests passed (valid, repeat, other device, invalid, health).');
