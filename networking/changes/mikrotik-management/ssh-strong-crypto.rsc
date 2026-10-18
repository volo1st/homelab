:if ([/ip ssh get strong-crypto] != false) do={:error "Unexpected strong-crypto state"}; /ip ssh set strong-crypto=yes; :put "STRONG_CRYPTO_APPLIED"
