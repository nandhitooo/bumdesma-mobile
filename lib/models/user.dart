class AppUser {
  final String nip;
  final String nama;
  final String jabatan;
  final String departemen;
  final bool mustChangePassword;

  const AppUser({
    required this.nip,
    required this.nama,
    required this.jabatan,
    required this.departemen,
    this.mustChangePassword = false,
  });

  AppUser copyWith({bool? mustChangePassword}) {
    return AppUser(
      nip: nip,
      nama: nama,
      jabatan: jabatan,
      departemen: departemen,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }
}
