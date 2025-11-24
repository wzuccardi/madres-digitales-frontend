// ignore_for_file: constant_identifier_names, sort_constructors_first
enum Role {
  ADMIN('ADMIN'),
  MADRINA('MADRINA'),
  MEDICO('MEDICO'),
  GESTANTE('GESTANTE'),
  SUPERVISOR('SUPERVISOR');

  const Role(this.value);
  final String value;

  static Role fromString(String value) {
    switch (value) {
      case 'ADMIN':
        return Role.ADMIN;
      case 'MADRINA':
        return Role.MADRINA;
      case 'MEDICO':
        return Role.MEDICO;
      case 'GESTANTE':
        return Role.GESTANTE;
      case 'SUPERVISOR':
        return Role.SUPERVISOR;
      default:
        return Role.GESTANTE;
    }
  }

  @override
  String toString() => value;
}
