enum ReportFormat {
  pdf,
  excel,
  csv,
  txt;

  String get displayName {
    switch (this) {
      case ReportFormat.pdf:
        return 'PDF';
      case ReportFormat.excel:
        return 'Excel';
      case ReportFormat.csv:
        return 'CSV';
      case ReportFormat.txt:
        return 'TXT';
    }
  }
}