import assert from 'node:assert/strict';
import { readFile, readdir, writeFile } from 'node:fs/promises';
import { createHash } from 'node:crypto';

const directory = 'docs/evidence/device';
const rows = (await readFile(`${directory}/actions.jsonl`, 'utf8'))
  .trim().split('\n').map(line => JSON.parse(line));
const info = rows.filter(row => row.ok && row.action === 'info');
const find = (predicate, label) => {
  const row = info.find(predicate);
  assert.ok(row, `Missing native checkpoint: ${label}`);
  return { at: row.at, ...row.result };
};
const stock = quantity => row => row.result.desc ===
  `Proyektor Demo\nDEMO-001\nKategori: Elektronik\nStatus: Tersedia\nStok: ${quantity}`;
const pending = find(row => /Proyektor Demo[\s\S]*PENDING$/.test(row.result.desc), 'pending');
const approved = find(row => /Proyektor Demo[\s\S]*APPROVED$/.test(row.result.desc), 'approved');
const goodReturn = find(row => /Proyektor Demo[\s\S]*RETURNED$/.test(row.result.desc), 'good return');
const rejected = find(row => /Proyektor Demo[\s\S]*REJECTED$/.test(row.result.desc), 'rejected');
const damaged = find(row => row.result.desc === 'Rusak / Perlu Perbaikan' && row.result.checked, 'damaged radio selected');
const checks = {
  adminDashboard: find(row => row.result.desc === 'Dashboard Laboran', 'admin dashboard'),
  emptyDates: find(row => row.result.desc === 'Pilih tanggal pinjam dan tanggal kembali.', 'date validation'),
  pending,
  pendingStock: find(row => row.at > pending.at && stock(2)(row), 'pending stock stays 2'),
  approved,
  approvedStock: find(stock(1), 'approval stock 1'),
  goodReturn,
  goodReturnStock: find(row => row.at > goodReturn.at && stock(2)(row), 'good return stock 2'),
  rejected,
  rejectedStock: find(row => row.at > rejected.at && stock(2)(row), 'rejection stock stays 2'),
  damaged,
  damagedStock: find(row => row.at > damaged.at && stock(1)(row), 'damaged return usable stock stays 1'),
  newItem: find(row => /USB Hub Uji Android[\s\S]*Stok: 1$/.test(row.result.desc), 'admin inventory creation'),
  invalidNewItem: find(row => row.result.desc === 'Isi nama barang dan stok yang valid (minimal 0).', 'inventory validation'),
  projectorImage: find(row => row.result.desc === 'Ilustrasi Proyektor Demo' && row.result.clazz === 'android.widget.ImageView', 'projector image'),
  laptopImage: find(row => row.result.desc === 'Ilustrasi Laptop Demo' && row.result.clazz === 'android.widget.ImageView', 'laptop image'),
  searchInput: find(row => row.result.clazz === 'android.widget.EditText' && /^laptop$/i.test(row.result.text), 'search keyboard input'),
  signedOut: find(row => row.at > damaged.at && row.result.desc === 'MASUK', 'logout after transactions'),
};
const images = [];
for (const filename of (await readdir(directory)).filter(name => name.endsWith('.png')).sort()) {
  const bytes = await readFile(`${directory}/${filename}`);
  assert.ok(bytes.length > 1000 && bytes.readUInt32BE(0) === 0x89504e47 &&
    bytes.subarray(-8, -4).toString() === 'IEND', `Invalid evidence PNG: ${filename}`);
  images.push({ filename, bytes: bytes.length, width: bytes.readUInt32BE(16), height: bytes.readUInt32BE(20) });
}
const apk = await readFile('build/app/outputs/flutter-apk/app-demo-debug.apk');
const summary = {
  scope: 'Android native demo; not production database integration',
  device: 'Redmi 12 / 23053RN02A, Android 15 API 35',
  package: 'com.example.lab_inventory.demo',
  checkpointsPassed: Object.keys(checks).length,
  checks,
  images,
  apkSha256: createHash('sha256').update(apk).digest('hex'),
  failedActionsRetainedInLog: rows.filter(row => !row.ok).length,
  note: 'Raw actions retain failed USB/selector/setup attempts; checkpoints above refer to successful native observations. Search filtering was also visually checked in 10-catalog-search.png.',
};
await writeFile(`${directory}/native-checkpoints.json`, JSON.stringify(summary, null, 2) + '\n');
console.log(JSON.stringify({ checkpointsPassed: summary.checkpointsPassed, validImages: images.length, failedActionsRetainedInLog: summary.failedActionsRetainedInLog, apkSha256: summary.apkSha256 }));
