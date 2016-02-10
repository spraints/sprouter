# Sprouter

This is spraint's router's helper scripts. It takes a config file like this:

```yaml
# Internet servers that should always go over the fast link
turbo_sites:
  label:
  - hostname1.service.com.
  - hostname2.service.com.
  label2:
  - hostname.label2.com.

# Internal hosts that should get completely moved to the fast link
# if pings are getting dropped.
preferred_hosts:
  label:
  - 192.168.100.1
  - 192.168.100.2
  label2:
  - 192.168.100.22

# Optional set of hosts that should be added to `turbo_hosts` always
turbo_hosts:
  label3:
  - 192.168.100.32

config:
  stat: "http://192.168.100.81:12004/data/minibuntu/ping/ping_droprate-8.8.8.8"
  threshold: 0.5
```

When you run `sprouter adjust config.yml`, the sites will be looked up and their IPs added to the `turbo_sites` table. Visage will be queried for the current rate of errors. If the average over the last minute is over `threshold`, the `turbo_hosts` will be populated. Otherwise, it'll be emptied.

Running `sprouter status` will show the tables.

