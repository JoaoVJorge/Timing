enum AuthIdentityProvider {
  google(providerKey: "google"),
  apple(providerKey: "apple");

  const AuthIdentityProvider({required this.providerKey});

  final String providerKey;
}
