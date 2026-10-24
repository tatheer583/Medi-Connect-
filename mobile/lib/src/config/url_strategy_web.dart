import 'package:flutter_web_plugins/flutter_web_plugins.dart';

/// Web-only: use hash-based URLs (e.g. /#/dashboard) so the app works on
/// static hosts like GitHub Pages where path routes would 404 on refresh.
void configureUrlStrategy() {
  setUrlStrategy(const HashUrlStrategy());
}
