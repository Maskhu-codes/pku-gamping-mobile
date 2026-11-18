import 'package:flutter_test/flutter_test.dart';
import 'package:pku_gamping_app/core/session/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SessionManager.init();
  });

  test('SessionManager menyimpan dan membaca token, fs_mr, fs_nm_pasien, fs_email, fs_nik', () async {
    expect(SessionManager.hasValidSession(), isFalse);

    await SessionManager.saveSession(
      token: 'jwt.token.dummy',
      fsNmPasien: 'Ahmad Dahlan',
      fsMr: '347104100407951',
      fsNik: '3471012345670001',
      fsEmail: 'ahmad.dahlan@example.com',
      username: 'ahmad_dahlan',
    );

    expect(SessionManager.hasValidSession(), isTrue);
    expect(SessionManager.isLoggedIn, isTrue);
    expect(SessionManager.token, 'jwt.token.dummy');
    expect(SessionManager.fsMr, '347104100407951');
    expect(SessionManager.noRm, '347104100407951');
    expect(SessionManager.fsNmPasien, 'Ahmad Dahlan');
    expect(SessionManager.namaPasien, 'Ahmad Dahlan');
    expect(SessionManager.fsNik, '3471012345670001');
    expect(SessionManager.nik, '3471012345670001');
    expect(SessionManager.fsEmail, 'ahmad.dahlan@example.com');
    expect(SessionManager.email, 'ahmad.dahlan@example.com');
    expect(SessionManager.username, 'ahmad_dahlan');
  });

  test('SessionManager clearSession menghapus seluruh sesi aktif', () async {
    await SessionManager.saveSession(
      token: 'jwt.token.dummy',
      fsNmPasien: 'Ahmad Dahlan',
      fsMr: '347104100407951',
      fsNik: '3471012345670001',
      fsEmail: 'ahmad.dahlan@example.com',
    );

    expect(SessionManager.hasValidSession(), isTrue);

    await SessionManager.clearSession();

    expect(SessionManager.hasValidSession(), isFalse);
    expect(SessionManager.isLoggedIn, isFalse);
    expect(SessionManager.token, isNull);
    expect(SessionManager.fsNik, isNull);
    expect(SessionManager.fsEmail, isNull);
  });
}

