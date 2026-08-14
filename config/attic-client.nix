# The cache is optional. Replace the endpoint and public key, then enable it.
# These values are public and may be committed. Never put an Attic token here.
{
  devbox.attic.client = {
    enable = false;

    endpoint = "https://attic.example.invalid/dev";
    publicKey = "dev:REPLACE_WITH_ATTIC_CACHE_PUBLIC_KEY";

    # Required only for `push.enable`.
    serverName = "devbox";
    serverEndpoint = "https://attic.example.invalid";
    cacheName = "dev";

    push = {
      enable = false;
      tokenFile = "/run/secrets/attic-token";
    };
  };
}
