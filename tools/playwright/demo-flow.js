// Run with the Playwright browser_run_code tool while Flutter Chrome is running.
// This scenario reloads the local demo only. It never accesses Supabase.
async (page) => {
  const errors = [];
  page.on('console', message => {
    if (message.type() === 'error') errors.push(message.text());
  });
  const button = name => page.getByRole('button', { name, exact: true });
  const tab = name => page.getByRole('tab', { name, exact: true });
  const stock = count => page.getByRole('button', {
    name: `Proyektor Demo DEMO-001 Kategori: Elektronik Status: Tersedia Stok: ${count}`,
    exact: true,
  }).waitFor();
  const text = value => page.getByText(value, { exact: true }).last().waitFor();
  // Flutter creates its editable input after focus; send ordinary key events.
  const input = async (field, value) => {
    await field.click();
    await field.press('ControlOrMeta+A');
    await field.press('Backspace');
    if (value) await field.pressSequentially(value);
  };
  const logout = async () => {
    await tab('Profil').click();
    await button('KELUAR DARI AKUN').click();
    await button('Keluar').click();
    await button('MASUK').waitFor();
  };

  await page.goto('http://127.0.0.1:8766/');
  await page.locator('flt-semantics-placeholder').evaluate(element => element.click());
  await button('MASUK').click();
  await tab('Inventaris').click();
  await stock(2);
  const search = page.getByRole('textbox', { name: 'Cari nama barang...' });
  await input(search, 'Laptop');
  await page.getByRole('button', { name: /Laptop Demo DEMO-002/ }).waitFor();
  await page.getByRole('button', { name: /Proyektor Demo DEMO-001/ }).waitFor({ state: 'hidden' });
  await input(search, '');
  await page.getByRole('button', { name: /Proyektor Demo DEMO-001/ }).click();
  await button('AJUKAN PEMINJAMAN').click();
  await button('KIRIM / COBA LAGI').click();
  await text('Pilih tanggal pinjam dan tanggal kembali.');
  for (let index = 0; index < 2; index++) {
    await button('DD/MM/YYYY').first().click();
    await button('OK').click();
  }
  await button('KIRIM / COBA LAGI').click();
  await text('Isi keperluan peminjaman (maksimal 2.000 karakter).');
  await input(page.getByRole('textbox', { name: 'Input alasan / keperluan...' }),
    'Uji Playwright: peminjaman dan pengembalian kondisi baik. Memastikan teks keperluan yang panjang tetap terbaca pada layar ponsel.');
  await button('KIRIM / COBA LAGI').click();
  await button('Back').click();
  await tab('Peminjaman').click();
  await page.getByText(/Proyektor Demo \(1 Unit\).*PENDING/s).waitFor();
  await page.screenshot({ path: 'docs/evidence/playwright-student-pending.png' });
  await tab('Inventaris').click();
  await stock(2);
  await logout();
  await page.getByRole('radio', { name: 'Laboran Demo', exact: true }).click();
  await button('MASUK').click();
  await button('Setujui').click();
  await tab('Inventaris').click();
  await stock(1);
  await tab('Dashboard').click();
  await button('Pengembalian').click();
  await page.getByRole('radio', { name: 'Normal / Baik', exact: true }).waitFor();
  await page.screenshot({ path: 'docs/evidence/playwright-return-phone.png' });
  await input(page.getByRole('textbox', { name: 'Input catatan kondisi fisik barang...' }),
    'Uji Playwright: kondisi baik, stok siap pakai dikembalikan.');
  await button('KONFIRMASI KEMBALI').click();
  await tab('Riwayat').click();
  await page.getByText(/Proyektor Demo - Peminjam: Mahasiswa Demo.*RETURNED/s).waitFor();
  await page.screenshot({ path: 'docs/evidence/playwright-admin-returned.png' });
  await tab('Inventaris').click();
  await stock(2);
  await page.screenshot({ path: 'docs/evidence/playwright-stock-restored.png' });
  if (errors.length) throw new Error(`Browser errors: ${errors.join('\n')}`);
  return { passed: true, stockSequence: [2, 2, 1, 2], consoleErrors: errors,
    checks: ['search', 'empty dates', 'empty purpose', 'pending history on tab open',
      'logout', 'admin approval', 'refreshed stock on tab open', 'good return',
      'refreshed transaction history', 'long purpose on phone'] };
}
