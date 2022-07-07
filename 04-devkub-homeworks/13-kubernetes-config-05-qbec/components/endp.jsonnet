local p = import '../params.libsonnet';
[
  {
    kind: 'Service',
    apiVersion: 'v1',
    metadata: {
      name: 'ext-api',
    },
    spec: {
      selector: {},
      ports: [
        {
          name: 'ext-api',
          protocol: 'TCP',
          port: 443,
          nodePort: 0,
        },
      ],
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Endpoints',
    metadata: {
      name: 'ext-api',
    },
    subsets: [
      {
        addresses: [
          {
            ip: '13.248.207.97',
          },
        ],
        ports: [
          {
            name: 'ext-api',
            port: 443,
          },
        ],
      },
    ],
  },
]