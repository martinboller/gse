curl -X POST -H 'Content-Type: application/json' \
    -H 'Authorization: Bearer '$TOKEN'' \
    -d '{"name":"testscanner002",
        "size":"s-2vcpu-4gb",
        "region":"fra1",
        "image":"debian-13-x64",
        "ipv6":true,
        "vpc_uuid":"aa4b014e-7330-4e5f-b579-cc039fd0060b"}' \
    "https://api.digitalocean.com/v2/droplets"
