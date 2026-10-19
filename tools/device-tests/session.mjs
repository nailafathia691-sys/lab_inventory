import path from 'node:path';
import { appendFile, mkdir, writeFile } from 'node:fs/promises';
import readline from 'node:readline';

// Run from the repository root. Cache stays in the ignored workspace directory.
process.env.PLAYWRIGHT_BROWSERS_PATH = path.resolve('.dart_tool/playwright-browsers');
const { _android } = await import('playwright');
const serial = process.argv[2];
if (!serial) throw new Error('Usage: node tools/device-tests/session.mjs <device-serial>');
const packageName = 'com.example.lab_inventory.demo';
const devices = await _android.devices({
  omitDriverInstall: process.argv.includes('--reuse-driver'),
});
const device = devices.find(entry => entry.serial() === serial);
if (!device) throw new Error('The specified Android device is not authorized/connected.');
device.setDefaultTimeout(10000);
const evidence = path.resolve('docs/evidence/device');
await mkdir(evidence, { recursive: true });
async function record(value) {
  const line = JSON.stringify({ at: new Date().toISOString(), ...value });
  await appendFile(path.join(evidence, 'actions.jsonl'), line + '\n');
  console.log(line);
}
const settle = () => new Promise(resolve => setTimeout(resolve, 400));
async function find(value) {
  const until = Date.now() + 10000;
  let lastError;
  while (Date.now() < until) {
    try { return await device.info(selector(value)); }
    catch (error) {
      lastError = error;
      if (/Device is closed|Pipe has been closed/.test(error.message)) throw error;
      await settle();
    }
  }
  throw lastError;
}
function selector(value = {}) {
  const result = { pkg: packageName, ...value };
  for (const field of ['text', 'desc', 'clazz']) {
    if (result[`${field}Regex`] !== undefined) {
      result[field] = new RegExp(result[`${field}Regex`]);
      delete result[`${field}Regex`];
    }
  }
  return result;
}
console.log(JSON.stringify({ ready: true, model: device.model(), packageName }));
const input = readline.createInterface({ input: process.stdin, terminal: false });
try {
  for await (const line of input) {
    if (!line.trim()) continue;
    let command;
    try {
      command = JSON.parse(line);
      let result;
      switch (command.action) {
        case 'info': result = await find(command.selector); break;
        case 'tap': await find(command.selector); await device.tap(selector(command.selector)); await settle(); result = true; break;
        case 'fill': await find(command.selector); await device.fill(selector(command.selector), command.text); await settle(); result = true; break;
        case 'wait': await device.wait(selector(command.selector), { state: command.state, timeout: 10000 }); result = true; break;
        case 'press': await device.input.press(command.key); await settle(); result = true; break;
        case 'type': await device.input.type(command.text); result = true; break;
        case 'swipe': await device.input.swipe(command.from, command.segments, command.steps ?? 30); result = true; break;
        case 'scroll': await device.scroll(selector(command.selector ?? { scrollable: true }), command.direction, command.percent ?? 70); await settle(); result = true; break;
        case 'screenshot': {
          await device.info({ pkg: packageName });
          if (!/^[a-zA-Z0-9_-]+\.png$/.test(command.filename)) throw new Error('Invalid evidence filename');
          const filename = path.join(evidence, command.filename);
          // Keep each USB response small. Large raw/sync screenshot transfers
          // were truncated by this phone's USB transport.
          const remote = '/data/local/tmp/lab_inventory_native.png';
          await device.shell(`screencap -p ${remote}`);
          const size = Number((await device.shell(`stat -c %s ${remote}`)).toString().trim());
          if (!(size > 1000 && size < 5000000)) throw new Error('Invalid capture size');
          const parts = [];
          for (let index = 0; index < Math.ceil(size / 8192); index++) {
            const encoded = await device.shell(`dd if=${remote} bs=8192 skip=${index} count=1 2>/dev/null | base64`);
            parts.push(Buffer.from(encoded.toString().trim(), 'base64'));
          }
          const bytes = Buffer.concat(parts);
          if (bytes.length !== size || bytes.readUInt32BE(0) !== 0x89504e47 ||
              bytes.subarray(-8, -4).toString() !== 'IEND') {
            throw new Error('Incomplete screenshot; do not treat this file as evidence.');
          }
          await writeFile(filename, bytes);
          await device.shell(`rm -f ${remote}`);
          result = { filename };
          break;
        }
        case 'quit': input.close(); break;
        default: throw new Error('Unsupported action');
      }
      await record({ action: command.action, selector: command.selector, ok: true, result });
      if (command.action === 'quit') break;
    } catch (error) {
      await record({ action: command?.action, selector: command?.selector, ok: false, error: error.message });
    }
  }
} finally {
  await device.close();
}
