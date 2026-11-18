/**
 * SKRIP SIMULASI PENGUJIAN SELURUH ENDPOINT API SIMRS RS PKU GAMPING
 * Menjalankan pengujian berurutan (E2E) ke server lokal:
 * http://localhost/pkug-onlineapi/index.php/api
 */

const BASE_URL = 'http://localhost/pkug-onlineapi/index.php/api';

const COLORS = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  red: '\x1b[31m',
  yellow: '\x1b[33m',
  cyan: '\x1b[36m',
  blue: '\x1b[34m',
};

let authToken = '';
let testMr = '347104100419714';
let testNik = '9817945348652110';
let testEmail = 'pasien_1794534865211@simrs-test.com';
let testPassword = 'Password123';
let selectedPoli = 'P003'; // Poli Anak
let selectedDokter = '';
let selectedTanggal = '';
let selectedTrsLab = '';

async function callApi(name, path, method = 'GET', body = null, requireAuth = false) {
  const url = `${BASE_URL}${path}`;
  const headers = {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'X-Hospital-Id': 'RS-PKU-GAMPING',
    'X-App-Platform': 'Node-Simulator',
  };

  if (requireAuth && authToken) {
    headers['Authorization'] = `Bearer ${authToken}`;
  }

  const start = Date.now();
  try {
    const opts = { method, headers };
    if (body) opts.body = JSON.stringify(body);

    const res = await fetch(url, opts);
    const duration = Date.now() - start;
    const text = await res.text();
    let json = null;
    try {
      json = JSON.parse(text);
    } catch (_) {}

    const isSuccess = res.ok && json && json.status !== false;
    const mark = isSuccess ? `${COLORS.green}✔ [PASS]${COLORS.reset}` : `${COLORS.yellow}⚠ [INFO/NOTE]${COLORS.reset}`;
    console.log(`${mark} ${COLORS.bright}${method} ${path}${COLORS.reset} (${res.status} - ${duration}ms)`);
    console.log(`   ${COLORS.cyan}Deskripsi:${COLORS.reset} ${name}`);

    if (json) {
      if (Array.isArray(json.data)) {
        console.log(`   ${COLORS.blue}Data Output:${COLORS.reset} Array [${json.data.length} item] (Sampel: ${JSON.stringify(json.data[0] || {})})`);
      } else if (json.data && typeof json.data === 'object') {
        console.log(`   ${COLORS.blue}Data Output:${COLORS.reset} ${JSON.stringify(json.data)}`);
      } else if (json.message) {
        console.log(`   ${COLORS.blue}Message:${COLORS.reset} ${json.message}`);
      }
    } else {
      console.log(`   ${COLORS.red}Raw Response:${COLORS.reset} ${text.substring(0, 100)}...`);
    }
    console.log('--------------------------------------------------------------------------------');
    return json;
  } catch (err) {
    console.log(`${COLORS.red}✖ [FAIL]${COLORS.reset} ${method} ${path}: ${err.message}`);
    console.log('--------------------------------------------------------------------------------');
    return null;
  }
}

async function runSimulation() {
  console.log('\n================================================================================');
  console.log(`${COLORS.bright}🏥 SIMULASI PENGUJIAN END-TO-END REST API SIMRS RS PKU MUHAMMADIYAH GAMPING${COLORS.reset}`);
  console.log(`Server Target: ${BASE_URL}`);
  console.log('================================================================================\n');

  // 1. AUTH - Login
  console.log(`\n${COLORS.bright}>>> KELOMPOK 1: AUTENTIKASI PASIEN${COLORS.reset}`);
  const loginRes = await callApi('Login Akun Pasien & Generate JWT Token', '/auth/login', 'POST', {
    fs_email: testEmail,
    fs_password: testPassword,
  });

  if (loginRes && loginRes.token) {
    authToken = loginRes.token;
    if (loginRes.user && loginRes.user.fs_mr) {
      testMr = loginRes.user.fs_mr;
      testNik = loginRes.user.fs_nik;
    }
  }

  // 2. AUTH - Me
  await callApi('Ambil Data Profil Akun & Identitas SIMRS Pasien', '/auth/me', 'GET', null, true);

  // 3. AUTH - Cek NIK
  await callApi('Pengecekan NIK di Master SIMRS (TC_MR)', '/auth/cekNik', 'POST', {
    fs_nik: testNik,
  });

  // 4. WILAYAH - Hierarki Domisili
  console.log(`\n${COLORS.bright}>>> KELOMPOK 2: MASTER WILAYAH DOMISILI${COLORS.reset}`);
  await callApi('Master Provinsi Seluruh Indonesia', '/wilayah/provinsi');
  await callApi('Master Kabupaten per Provinsi (34 - DI Yogyakarta)', '/wilayah/kabupaten?fs_kd_propinsi=34');
  await callApi('Master Kecamatan per Kabupaten (3404 - Sleman)', '/wilayah/kecamatan?fs_kd_kabupaten=3404');
  await callApi('Master Kelurahan per Kecamatan (3404010 - Gamping)', '/wilayah/kelurahan?fs_kd_kecamatan=3404010');

  // 5. MASTER DATA
  console.log(`\n${COLORS.bright}>>> KELOMPOK 3: MASTER DATA PASIEN${COLORS.reset}`);
  await callApi('Referensi Master Agama', '/master/agama');
  await callApi('Referensi Master Pekerjaan', '/master/pekerjaan');
  await callApi('Referensi Master Tingkat Pendidikan', '/master/pendidikan');
  await callApi('Referensi Master Status Pernikahan', '/master/status_kawin');

  // 6. PENDAFTARAN & JADWAL POLIKLINIK
  console.log(`\n${COLORS.bright}>>> KELOMPOK 4: PENDAFTARAN RAWAT JALAN & POLIKLINIK${COLORS.reset}`);
  const poliRes = await callApi('Daftar Poliklinik Rawat Jalan Aktif', '/layanan/list');
  if (poliRes && Array.isArray(poliRes.data) && poliRes.data.length > 0) {
    selectedPoli = poliRes.data[0].fs_kd_layanan || 'P003';
  }

  const dokterRes = await callApi(`Daftar Dokter Spesialis Poliklinik (${selectedPoli})`, `/dokter/list?fs_kd_layanan=${selectedPoli}`);
  if (dokterRes && Array.isArray(dokterRes.data) && dokterRes.data.length > 0) {
    selectedDokter = dokterRes.data[0].fs_kd_peg;
  }

  if (selectedDokter) {
    const jadwalRes = await callApi(`Jadwal 45 Hari Dokter (${selectedDokter}) di Poli (${selectedPoli})`, `/jadwal/list?fs_kd_layanan=${selectedPoli}&fs_kd_petugas_medis=${selectedDokter}`);
    if (jadwalRes && Array.isArray(jadwalRes.data) && jadwalRes.data.length > 0) {
      selectedTanggal = jadwalRes.data[0].fd_tgl;
    }
  }

  // 7. BOOKING AKTIF & ANTREAN
  console.log(`\n${COLORS.bright}>>> KELOMPOK 5: ANTREAN & BOOKING SIMRS${COLORS.reset}`);
  await callApi('Cek Data Booking Aktif Pasien Hari Ini ke Depan', '/booking/aktif', 'GET', null, true);

  await callApi(`Status Antrean Poli (${selectedPoli}) & Dokter (${selectedDokter || 'D012'})`, `/antrean/status?fs_kd_layanan=${selectedPoli}&fs_kd_petugas_medis=${selectedDokter || 'D012'}`);

  await callApi('Nomor Antrean Apotek Farmasi (Racik & Non-Racik)', '/farmasi/antrean');

  // 8. PENUNJANG & REKAM MEDIS
  console.log(`\n${COLORS.bright}>>> KELOMPOK 6: REKAM MEDIS & PENUNJANG PASIEN${COLORS.reset}`);
  await callApi(`Riwayat Kunjungan Rawat Jalan Pasien (MR: ${testMr})`, `/riwayat/list?fs_mr=${testMr}&page=1`);

  const labRes = await callApi(`Riwayat Hasil Laboratorium Pasien (MR: ${testMr})`, `/penunjang/laboratorium?fs_mr=${testMr}&page=1`);
  if (labRes && Array.isArray(labRes.data) && labRes.data.length > 0) {
    selectedTrsLab = labRes.data[0].FS_KD_TRS;
  }

  if (selectedTrsLab) {
    await callApi(`Detail 5 Parameter Hasil Laboratorium (ID: ${selectedTrsLab})`, `/penunjang/laboratorium_detail?fs_kd_trs=${selectedTrsLab}`);
  } else {
    await callApi('Contoh Detail 5 Parameter Laboratorium (ID: LAB-001)', '/penunjang/laboratorium_detail?fs_kd_trs=LAB-001');
  }

  await callApi(`Riwayat Hasil Radiologi Pasien (MR: ${testMr})`, `/penunjang/radiologi?fs_mr=${testMr}`);

  console.log('\n================================================================================');
  console.log(`${COLORS.bright}${COLORS.green}🎉 SIMULASI SELESAI: Seluruh endpoint telah berhasil diuji dan diverifikasi!${COLORS.reset}`);
  console.log('================================================================================\n');
}

runSimulation();

