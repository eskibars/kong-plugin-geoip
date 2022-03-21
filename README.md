# kong-plugin-geoip

Allows or denies requests based on the country code of the requester

# Configuration
| Parameter           | Description | Default          |
| ------------------- | ----------- | ---------------- |
| ip_db_file          | Location of the gzipped IP database file | ip2country.db.gz |
| allow_country_codes | A list of allowed 2-character country codes |                  |
| deny_country_codes  | A list of denied 2-character country codes       |                  |
| status              | HTTP status code for rejected requests | 403              |
| message             | HTTP response text for rejected requests        | Your IP address is not allowed              |
| shm_name            | Shared memory location for storing IP ranges       | geoipdb              |

```
_format_version: "2.1"
_transform: true

services:
- name: my-service
  url: https://datenight.connelly.casa/api/
  routes:
  - name: my-route
    paths:
    - /
    plugins:
    - name: geoip
      config:
        ip_db_file: /mnt/c/Users/Shane/Documents/KongPlugins/geoip/kong/plugins/geoip/ip2country.db.gz
        deny_country_codes:
        - RU
        - KP
```


# License
This is proprietary IP
