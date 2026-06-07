// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$authServiceHash() => r'8a5c3836e9a16ccf57e6a3565172a1ac82c68106';

/// See also [AuthService].
@ProviderFor(AuthService)
final authServiceProvider =
    AutoDisposeNotifierProvider<AuthService, UserState>.internal(
  AuthService.new,
  name: r'authServiceProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$authServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AuthService = AutoDisposeNotifier<UserState>;
