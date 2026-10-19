// Run after demo-flow.js, without reloading its local demo session.
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
  const loginAs = async role => {
    await tab('Profil').click();
    await button('KELUAR DARI AKUN').click();
    await button('Keluar').click();
    await page.getByRole('radio', { name: role, exact: true }).click();
    await button('MASUK').click();
  };
  const request = async purpose => {
    await loginAs('Mahasiswa Demo');
    await tab('Inventaris').click();
    await stock(2);
    await page.getByRole('button', { name: /Proyektor Demo DEMO-001/ }).click();
    await button('AJUKAN PEMINJAMAN').click();
    for (let index = 0; index < 2; index++) {
      await button('DD/MM/YYYY').first().click();
      await button('OK').click();
    }
    const field = page.getByRole('textbox', { name: 'Input alasan / keperluan...' });
    await field.click();
    await field.pressSequentially(purpose);
    await button('KIRIM / COBA LAGI').click();
    await button('Back').click();
    await loginAs('Laboran Demo');
  };
  await request('Uji Playwright: pengajuan ditolak');
  await button('Tolak').click();
  await tab('Riwayat').click();
  await page.getByText(/Proyektor Demo - Peminjam: Mahasiswa Demo.*REJECTED/s).waitFor();
  await tab('Inventaris').click();
  await stock(2);
  await request('Uji Playwright: pengembalian barang rusak');
  await button('Setujui').click();
  await tab('Inventaris').click();
  await stock(1);
  await tab('Dashboard').click();
  await button('Pengembalian').click();
  await page.getByRole('radio', { name: 'Rusak / Perlu Perbaikan', exact: true }).click();
  const notes = page.getByRole('textbox', { name: 'Input catatan kondisi fisik barang...' });
  await notes.click();
  await notes.pressSequentially('Uji Playwright: kerusakan ditemukan saat inspeksi; jangan tambah stok siap pakai.');
  await page.screenshot({ path: 'docs/evidence/playwright-damaged-return.png' });
  await button('KONFIRMASI KEMBALI').click();
  await tab('Inventaris').click();
  await stock(1);
  await page.screenshot({ path: 'docs/evidence/playwright-stock-after-damage.png' });
  if (errors.length) throw new Error(`Browser errors: ${errors.join('\n')}`);
  return { passed: true, rejectedStock: 2, damagedReturnStock: 1, consoleErrors: errors };
}
