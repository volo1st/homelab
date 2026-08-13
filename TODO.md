# DNS deep-dive

Qingping-Air-Monitor wake up its screen when renewing IP


## Stale DNS

MacOS:

dscacheutil (The Directory Service Cache Utility)

> Why it failed alone: Clearing this cache only removes the high-level system data references, but it does not reset the actual background network process that fetches the IP addresses.

mDNSResponder (multicast DNS Responder)

> Why it fixed your issue: Sending the -HUP signal forces this background service to completely restart and dump its deep network cache.

```
sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder
```

Linux:

Problem is actually on the host level

```
sudo resolvectl flush-caches
```

