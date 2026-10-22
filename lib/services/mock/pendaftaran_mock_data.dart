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
      id: 'poli-pd',
      nama: 'Poli Penyakit Dalam',
      icon: Icons.favorite_border_rounded,
      deskripsi: 'Spesialis penyakit dalam, diabetes, lambung, ginjal',
    ),
    PoliModel(
      id: 'poli-anak',
      nama: 'Poli Anak',
      icon: Icons.child_care_rounded,
      deskripsi: 'Kesehatan anak, tumbuh kembang, imunisasi',
    ),
    PoliModel(
      id: 'poli-jantung',
      nama: 'Poli Jantung',
      icon: Icons.monitor_heart_outlined,
      deskripsi: 'Kardiologi & vaskular, konsultasi EKG',
    ),
    PoliModel(
      id: 'poli-mata',
      nama: 'Poli Mata',
      icon: Icons.visibility_outlined,
      deskripsi: 'Kesehatan mata, katarak, refraksi & glaukoma',
    ),
    PoliModel(
      id: 'poli-bedah',
      nama: 'Poli Bedah',
      icon: Icons.healing_outlined,
      deskripsi: 'Bedah umum, konsultasi pra & pasca operasi',
    ),
    PoliModel(
      id: 'poli-saraf',
      nama: 'Poli Saraf',
      icon: Icons.psychology_outlined,
      deskripsi: 'Neurologi, migrain, stroke & saraf kejepit',
    ),
    PoliModel(
      id: 'poli-gigi',
      nama: 'Poli Gigi & Mulut',
      icon: Icons.sentiment_satisfied_alt_outlined,
      deskripsi: 'Perawatan gigi, tambal, cabut & scalling',
    ),
  ];

  static final List<DokterPendaftaranModel> listDokter = [
    DokterPendaftaranModel(
      id: 'dok-1',
      nama: 'dr. Hendra Wicaksono, Sp.PD',
      poliId: 'poli-pd',
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
      poliId: 'poli-pd',
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
      poliId: 'poli-pd',
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
      poliId: 'poli-bedah',
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
}
