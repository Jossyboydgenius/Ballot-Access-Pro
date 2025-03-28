class AppFlavorConfig {
  final String name;
  final String apiBaseUrl;
  final String socketUrl;
  final String webUrl;
  final String sentryDsn;
  final String mixpanelToken;

  AppFlavorConfig({
    required this.name,
    required this.apiBaseUrl,
    required this.socketUrl,
    required this.webUrl,
    required this.sentryDsn,
    required this.mixpanelToken,
  });
}