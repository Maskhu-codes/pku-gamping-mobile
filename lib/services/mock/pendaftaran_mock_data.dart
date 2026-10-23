import 'package:flutter/material.dart';
import 'package:pku_gamping_app/models/pasien_model.dart';
import 'package:pku_gamping_app/models/pendaftaran_model.dart';

/// Data Dummy Mock Pendaftaran Rawat Jalan RS PKU Gamping
class PendaftaranDummyData {
  static const PasienModel defaultPasien = PasienModel(
    id: 'p-1',
    nama: 'Dahlan Muda',
    noRm: '347104100407951',
    nik: '3471041234560001',
    tanggalLahir: '12-05-1988',
    isTerhubung: true,
    hubungan: 'Diri Sendiri',
  );

  static const List<PasienModel> listPasienTersimpan = [
    defaultPasien,
    PasienModel(
      id: 'p-2',
      nama: 'Siti Aminah',
      noRm: '347104100408892',
      nik: '3471045678900002',
      tanggalLahir: '24-08-1992',
      isTerhubung: true,
      hubungan: 'Istri',
    ),
    PasienModel(
      id: 'p-3',
      nama: 'Fahri Hamzah Muda',
      noRm: '347104100409941',
      nik: '3471049988770003',
      tanggalLahir: '03-11-2018',
      isTerhubung: true,
      hubungan: 'Anak',
    ),
  ];

  static const List<PoliModel> listPoli = [
    PoliModel(
      id: 'poli-anak',
      nama: 'Anak',
      icon: Icons.child_care_rounded,
      deskripsi: 'Kesehatan anak, imunisasi, dan tumbuh kembang',
    ),
    PoliModel(
      id: 'poli-anak-neurologi',
      nama: 'Anak Neurologi',
      icon: Icons.psychology_alt_outlined,
      deskripsi: 'Konsultasi saraf dan perkembangan neurologis anak',
    ),
    PoliModel(
      id: 'poli-anestesi',
      nama: 'Anestesi',
      icon: Icons.medication_outlined,
      deskripsi: 'Konsultasi pra-operasi & penanganan manajemen nyeri',
    ),
    PoliModel(
      id: 'poli-andrologi',
      nama: 'Andrologi',
      icon: Icons.male_rounded,
      deskripsi: 'Kesehatan reproduksi, hormon, dan fertilitas pria',
    ),
    PoliModel(
      id: 'poli-bedah-anak',
      nama: 'Bedah Anak',
      icon: Icons.escalator_warning_outlined,
      deskripsi: 'Tindakan bedah khusus bayi dan anak-anak',
    ),
    PoliModel(
      id: 'poli-bedah-digestif',
      nama: 'Bedah Digestif',
      icon: Icons.restaurant_outlined,
      deskripsi: 'Bedah saluran cerna, lambung, usus, dan hepatobilier',
    ),
    PoliModel(
      id: 'poli-bedah-mulut',
      nama: 'Bedah Mulut',
      icon: Icons.face_retouching_natural_outlined,
      deskripsi: 'Bedah maksilofasial, impaksi gigi & rekonstruksi mulut',
    ),
    PoliModel(
      id: 'poli-bedah-onkologi',
      nama: 'Bedah Onkologi',
      icon: Icons.biotech_outlined,
      deskripsi: 'Operasi penanganan tumor dan keganasan/kanker',
    ),
    PoliModel(
      id: 'poli-bedah-orthopedi',
      nama: 'Bedah Orthopedi',
      icon: Icons.accessibility_new_outlined,
      deskripsi: 'Bedah tulang, sendi, fraktur, dan cedera muskuloskeletal',
    ),
    PoliModel(
      id: 'poli-bedah-plastik',
      nama: 'Bedah Plastik',
      icon: Icons.auto_fix_high_outlined,
      deskripsi: 'Bedah rekonstruksi jaringan, luka bakar & estetika medis',
    ),
    PoliModel(
      id: 'poli-bedah-syaraf',
      nama: 'Bedah Syaraf',
      icon: Icons.psychology_outlined,
      deskripsi: 'Operasi otak, sumsum tulang belakang, dan saraf tepi',
    ),
    PoliModel(
      id: 'poli-bedah-tkv',
      nama: 'Bedah TKV',
      icon: Icons.favorite_outlined,
      deskripsi: 'Bedah toraks, kardiak, dan sistem vaskuler',
    ),
    PoliModel(
      id: 'poli-bedah-umum',
      nama: 'Bedah Umum',
      icon: Icons.healing_outlined,
      deskripsi: 'Konsultasi & tindakan bedah umum pra/pasca operasi',
    ),
    PoliModel(
      id: 'poli-bedah-urologi',
      nama: 'Bedah Urologi',
      icon: Icons.water_drop_outlined,
      deskripsi: 'Bedah saluran kemih, batu ginjal, kandung kemih & prostat',
    ),
    PoliModel(
      id: 'poli-bedah-vaskuler',
      nama: 'Bedah Vaskuler',
      icon: Icons.bloodtype_outlined,
      deskripsi: 'Tindakan bedah pembuluh darah vena, arteri, dan varises',
    ),
    PoliModel(
      id: 'poli-dalam',
      nama: 'Dalam',
      icon: Icons.favorite_border_rounded,
      deskripsi: 'Penyakit dalam, diabetes, lambung, ginjal, dan infeksi',
    ),
    PoliModel(
      id: 'poli-dalam-ginjal-hipertensi',
      nama: 'Dalam Ginjal dan Hipertensi',
      icon: Icons.monitor_heart_outlined,
      deskripsi: 'Nefrologi, gagal ginjal, terapi dialisis, dan hipertensi',
    ),
    PoliModel(
      id: 'poli-forensik',
      nama: 'Forensik',
      icon: Icons.policy_outlined,
      deskripsi: 'Kedokteran forensik, visum et repertum & medikolegal',
    ),
    PoliModel(
      id: 'poli-gigi-endodonsi',
      nama: 'Gigi Endodonsi',
      icon: Icons.sentiment_satisfied_alt_outlined,
      deskripsi: 'Perawatan saluran akar, pulpa, dan saraf gigi',
    ),
    PoliModel(
      id: 'poli-gigi-orthodonti',
      nama: 'Gigi Orthodonti',
      icon: Icons.sentiment_very_satisfied_outlined,
      deskripsi: 'Pemasangan kawat gigi / behel dan perataan susunan gigi',
    ),
    PoliModel(
      id: 'poli-gigi-pedodonsi-anak',
      nama: 'Gigi Pedodonsi (Anak)',
      icon: Icons.child_care_rounded,
      deskripsi: 'Kesehatan gigi dan perawatan rongga mulut khusus anak',
    ),
    PoliModel(
      id: 'poli-gigi-periodonti',
      nama: 'Gigi Periodonti',
      icon: Icons.clean_hands_outlined,
      deskripsi: 'Pengobatan gusi berdarah, karang gigi & jaringan penyangga',
    ),
    PoliModel(
      id: 'poli-gigi-prostodonti',
      nama: 'Gigi Prostodonti',
      icon: Icons.mood_outlined,
      deskripsi: 'Pembuatan gigi tiruan, mahkota (crown), dan implan gigi',
    ),
    PoliModel(
      id: 'poli-hemato-onkologi',
      nama: 'Hemato Onkologi',
      icon: Icons.bubble_chart_outlined,
      deskripsi: 'Kelainan darah, anemia aplastik, limfoma, dan leukimia',
    ),
    PoliModel(
      id: 'poli-hip-and-knee',
      nama: 'Hip and Knee',
      icon: Icons.directions_walk_outlined,
      deskripsi: 'Rekonstruksi sendi panggul dan penggantian sendi lutut',
    ),
    PoliModel(
      id: 'poli-home-care',
      nama: 'Home Care',
      icon: Icons.medical_services_outlined,
      deskripsi: 'Pelayanan medis dan keperawatan berkala di rumah pasien',
    ),
    PoliModel(
      id: 'poli-ivf-dan-ingin-anak',
      nama: 'IVF dan Ingin Anak',
      icon: Icons.pregnant_woman_outlined,
      deskripsi: 'Program bayi tabung (IVF), promil, dan infertilitas terpadu',
    ),
    PoliModel(
      id: 'poli-jantung',
      nama: 'Jantung',
      icon: Icons.monitor_heart_rounded,
      deskripsi: 'Kardiologi, penyakit jantung koroner, aritmia & EKG',
    ),
    PoliModel(
      id: 'poli-jiwa',
      nama: 'Jiwa',
      icon: Icons.self_improvement_outlined,
      deskripsi: 'Psikiatri, kesehatan mental, gangguan cemas & depresi',
    ),
    PoliModel(
      id: 'poli-kardiologi-intervensi',
      nama: 'Kardiologi Intervensi',
      icon: Icons.hub_outlined,
      deskripsi: 'Kateterisasi jantung (Cath Lab) & pemasangan ring/stent',
    ),
    PoliModel(
      id: 'poli-kebidanan',
      nama: 'Kebidanan',
      icon: Icons.family_restroom_outlined,
      deskripsi: 'Kandungan, kehamilan, persalinan, USG 4D & ginekologi',
    ),
    PoliModel(
      id: 'poli-kemoterapi',
      nama: 'Kemoterapi',
      icon: Icons.medical_information_outlined,
      deskripsi: 'Layanan terapi infus sitostatika terpadu & monitoring kanker',
    ),
    PoliModel(
      id: 'poli-kulit-dan-kelamin',
      nama: 'Kulit dan Kelamin',
      icon: Icons.spa_outlined,
      deskripsi: 'Dermatologi, alergi kulit, infeksi kulit & kelamin',
    ),
    PoliModel(
      id: 'poli-mata',
      nama: 'Mata',
      icon: Icons.visibility_outlined,
      deskripsi: 'Kesehatan mata, pemeriksaan visus, katarak & glaukoma',
    ),
    PoliModel(
      id: 'poli-mcu',
      nama: 'Medical Check Up',
      icon: Icons.fact_check_outlined,
      deskripsi: 'Paket pemeriksaan kesehatan menyeluruh secara berkala',
    ),
    PoliModel(
      id: 'poli-neonatologi',
      nama: 'Neonatologi',
      icon: Icons.baby_changing_station_outlined,
      deskripsi: 'Perawatan intensif bayi baru lahir, ikterus & prematuritas',
    ),
    PoliModel(
      id: 'poli-neurologi-intervensi',
      nama: 'Neurologi Intervensi',
      icon: Icons.alt_route_outlined,
      deskripsi: 'Tindakan intervensi endovaskular otak dan stroke akut',
    ),
    PoliModel(
      id: 'poli-odc-hemato-onkologi',
      nama: 'ODC Hemato Onkologi',
      icon: Icons.medication_liquid_outlined,
      deskripsi: 'Perawatan harian kemoterapi singkat dan transfusi darah',
    ),
    PoliModel(
      id: 'poli-odc-penyakit-dalam',
      nama: 'ODC Penyakit Dalam',
      icon: Icons.local_hospital_outlined,
      deskripsi: 'Layanan rawat sehari (One Day Care) penyakit dalam',
    ),
    PoliModel(
      id: 'poli-onkologi-ginekologi',
      nama: 'Onkologi Ginekologi',
      icon: Icons.female_rounded,
      deskripsi: 'Deteksi dini dan penanganan kanker organ reproduksi wanita',
    ),
    PoliModel(
      id: 'poli-onkologi-radiasi',
      nama: 'Onkologi Radiasi',
      icon: Icons.wb_iridescent_outlined,
      deskripsi: 'Radioterapi eksternal dan terarah untuk pengobatan kanker',
    ),
    PoliModel(
      id: 'poli-onkologi-toraks',
      nama: 'Onkologi Toraks',
      icon: Icons.air_outlined,
      deskripsi: 'Penanganan tumor dan keganasan dinding serta rongga dada',
    ),
    PoliModel(
      id: 'poli-paru',
      nama: 'Paru',
      icon: Icons.air_rounded,
      deskripsi: 'Pulmonologi, asma, batuk kronis, TBC, dan PPOK',
    ),
    PoliModel(
      id: 'poli-eksekutif',
      nama: 'Poli Eksekutif',
      icon: Icons.workspace_premium_outlined,
      deskripsi: 'Layanan rawat jalan jalur cepat dengan fasilitas VIP',
    ),
    PoliModel(
      id: 'poli-poliklinik',
      nama: 'Poliklinik',
      icon: Icons.domain_outlined,
      deskripsi: 'Layanan konsultasi poliklinik umum RS PKU Gamping',
    ),
    PoliModel(
      id: 'poli-psikologi',
      nama: 'Psikologi',
      icon: Icons.psychology_alt_rounded,
      deskripsi: 'Konseling psikologi, tes minat bakat & terapi kognitif',
    ),
    PoliModel(
      id: 'poli-rehab-medik',
      nama: 'Rehab Medik',
      icon: Icons.fitness_center_outlined,
      deskripsi: 'Fisioterapi, terapi wicara, okupasi & rehabilitasi fisik',
    ),
    PoliModel(
      id: 'poli-syaraf',
      nama: 'Syaraf',
      icon: Icons.psychology_outlined,
      deskripsi: 'Neurologi, migrain, epilepsi, vertigo, dan saraf terjepit',
    ),
    PoliModel(
      id: 'poli-tht',
      nama: 'T.H.T',
      icon: Icons.hearing_outlined,
      deskripsi: 'Telinga, Hidung, Tenggorokan, sinusitis & gangguan dengar',
    ),
    PoliModel(
      id: 'poli-telemedicine',
      nama: 'Telemedicine',
      icon: Icons.videocam_outlined,
      deskripsi: 'Konsultasi dokter daring terpercaya dari kenyamanan rumah',
    ),
    PoliModel(
      id: 'poli-tumbuh-kembang-anak',
      nama: 'Tumbuh Kembang Anak',
      icon: Icons.accessibility_rounded,
      deskripsi: 'Evaluasi tumbuh kembang anak, speech delay & stimulasi sensori',
    ),
    PoliModel(
      id: 'poli-vaksin',
      nama: 'Vaksin',
      icon: Icons.vaccines_outlined,
      deskripsi: 'Vaksinasi bayi, anak, dewasa, hepatitis, serviks & umroh',
    ),
  ];

  static final List<DokterPendaftaranModel> listDokter = [
    DokterPendaftaranModel(
      id: 'dok-1',
      nama: 'dr. Hendra Wicaksono, Sp.PD',
      poliId: 'poli-dalam',
      spesialisasi: 'Spesialis Penyakit Dalam',
      fotoUrl: null,
      jadwalSlots: [
        const JadwalSlotModel(
          id: 'slot-1',
          hariTanggal: 'Jumat, 9 Oktober 2026',
          jam: 'Pukul 07.30 WIB',
          sisaKuota: 6,
          totalKuota: 100,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
        const JadwalSlotModel(
          id: 'slot-2',
          hariTanggal: 'Selasa, 13 Oktober 2026',
          jam: 'Pukul 07.30 WIB',
          sisaKuota: 3,
          totalKuota: 100,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
        const JadwalSlotModel(
          id: 'slot-3',
          hariTanggal: 'Jumat, 16 Oktober 2026',
          jam: 'Pukul 07.30 WIB',
          sisaKuota: 3,
          totalKuota: 100,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
        const JadwalSlotModel(
          id: 'slot-4',
          hariTanggal: 'Selasa, 20 Oktober 2026',
          jam: 'Pukul 07.30 WIB',
          sisaKuota: 0,
          totalKuota: 100,
          isPenuh: true,
          shift: 'Praktik Pagi',
        ),
      ],
    ),
    DokterPendaftaranModel(
      id: 'dok-2',
      nama: 'dr. H. Ahmad Farhan, Sp.PD',
      poliId: 'poli-dalam',
      spesialisasi: 'Spesialis Penyakit Dalam',
      fotoUrl: null,
      jadwalSlots: [
        const JadwalSlotModel(
          id: 'slot-21',
          hariTanggal: 'Senin, 12 Oktober 2026',
          jam: 'Pukul 09.00 WIB',
          sisaKuota: 12,
          totalKuota: 80,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
        const JadwalSlotModel(
          id: 'slot-22',
          hariTanggal: 'Kamis, 15 Oktober 2026',
          jam: 'Pukul 09.00 WIB',
          sisaKuota: 5,
          totalKuota: 80,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
      ],
    ),
    DokterPendaftaranModel(
      id: 'dok-3',
      nama: 'dr. Dewi Anggraini, Sp.PD',
      poliId: 'poli-dalam',
      spesialisasi: 'Spesialis Penyakit Dalam',
      fotoUrl: null,
      jadwalSlots: [
        const JadwalSlotModel(
          id: 'slot-31',
          hariTanggal: 'Rabu, 14 Oktober 2026',
          jam: 'Pukul 14.00 WIB',
          sisaKuota: 8,
          totalKuota: 60,
          isPenuh: false,
          shift: 'Praktik Siang',
        ),
      ],
    ),
    DokterPendaftaranModel(
      id: 'dok-4',
      nama: 'dr. Budi Santoso, Sp.A',
      poliId: 'poli-anak',
      spesialisasi: 'Spesialis Anak',
      fotoUrl: null,
      jadwalSlots: [
        const JadwalSlotModel(
          id: 'slot-41',
          hariTanggal: 'Senin, 12 Oktober 2026',
          jam: 'Pukul 08.00 WIB',
          sisaKuota: 15,
          totalKuota: 75,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
        const JadwalSlotModel(
          id: 'slot-42',
          hariTanggal: 'Rabu, 14 Oktober 2026',
          jam: 'Pukul 08.00 WIB',
          sisaKuota: 0,
          totalKuota: 75,
          isPenuh: true,
          shift: 'Praktik Pagi',
        ),
      ],
    ),
    DokterPendaftaranModel(
      id: 'dok-5',
      nama: 'dr. Siti Nurhaliza, Sp.JP',
      poliId: 'poli-jantung',
      spesialisasi: 'Spesialis Jantung & Pembuluh Darah',
      fotoUrl: null,
      jadwalSlots: [
        const JadwalSlotModel(
          id: 'slot-51',
          hariTanggal: 'Selasa, 13 Oktober 2026',
          jam: 'Pukul 10.00 WIB',
          sisaKuota: 10,
          totalKuota: 50,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
      ],
    ),
    DokterPendaftaranModel(
      id: 'dok-6',
      nama: 'dr. Rina Kusuma, Sp.M',
      poliId: 'poli-mata',
      spesialisasi: 'Spesialis Mata',
      fotoUrl: null,
      jadwalSlots: [
        const JadwalSlotModel(
          id: 'slot-61',
          hariTanggal: 'Kamis, 15 Oktober 2026',
          jam: 'Pukul 13.00 WIB',
          sisaKuota: 7,
          totalKuota: 40,
          isPenuh: false,
          shift: 'Praktik Siang',
        ),
      ],
    ),
    DokterPendaftaranModel(
      id: 'dok-7',
      nama: 'dr. Hendra Wijaya, Sp.B',
      poliId: 'poli-bedah-umum',
      spesialisasi: 'Spesialis Bedah Umum',
      fotoUrl: null,
      jadwalSlots: [
        const JadwalSlotModel(
          id: 'slot-71',
          hariTanggal: 'Jumat, 16 Oktober 2026',
          jam: 'Pukul 08.00 WIB',
          sisaKuota: 4,
          totalKuota: 30,
          isPenuh: false,
          shift: 'Praktik Pagi',
        ),
      ],
    ),
  ];

  /// Mengambil daftar dokter untuk suatu [poliId]
  /// Jika poli belum memiliki dokter mock eksplisit, menyediakan dokter spesialis default dengan slot aktif
  static List<DokterPendaftaranModel> getDokterByPoliId(String poliId) {
    // 1. Cek dokter spesifik yang terdaftar
    final match = listDokter.where((d) {
      if (d.poliId == poliId) return true;
      if (poliId == 'poli-dalam' && d.poliId == 'poli-pd') return true;
      if (poliId == 'poli-bedah-umum' && d.poliId == 'poli-bedah') return true;
      return false;
    }).toList();
    if (match.isNotEmpty) return match;

    // 2. Fallback cerdas: buat dokter spesialis representatif untuk poli tersebut
    final poli = listPoli.firstWhere(
      (p) => p.id == poliId,
      orElse: () => const PoliModel(
        id: 'poli-umum',
        nama: 'Poliklinik',
        icon: Icons.local_hospital_outlined,
      ),
    );

    return [
      DokterPendaftaranModel(
        id: 'dok-$poliId-1',
        nama: 'dr. Spesialis ${poli.nama}',
        poliId: poliId,
        spesialisasi: 'Spesialis ${poli.nama}',
        fotoUrl: null,
        jadwalSlots: const [
          JadwalSlotModel(
            id: 'slot-auto-1',
            hariTanggal: 'Senin, 26 Oktober 2026',
            jam: 'Pukul 08.00 - 12.00 WIB',
            sisaKuota: 18,
            totalKuota: 40,
            isPenuh: false,
            shift: 'Praktik Pagi',
          ),
          JadwalSlotModel(
            id: 'slot-auto-2',
            hariTanggal: 'Rabu, 28 Oktober 2026',
            jam: 'Pukul 13.00 - 16.00 WIB',
            sisaKuota: 10,
            totalKuota: 40,
            isPenuh: false,
            shift: 'Praktik Siang',
          ),
        ],
      ),
    ];
  }
}
