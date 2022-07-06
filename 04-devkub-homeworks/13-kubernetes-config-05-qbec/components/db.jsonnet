
local p = import '../params.libsonnet';
local params = p.components.db;

[
  {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      labels: {
        app: 'db',
      },
      name: 'db',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'db',
        },
      },
      serviceName: 'db',
      template: {
        metadata: {
          labels: {
            app: 'db',
          },
        },
        spec: {
          containers: [
            {
              name: 'db',
              image: params.image + ':' + params.version,
              ports: [
                {
                  name: 'postgres',
                  containerPort: params.port,
                  protocol: params.proto,
                },
              ],
              resources: {
                requests: {
                  cpu: params.cpu,
                  memory: params.memory,
                },
              },
              env: [
                {
                  name: 'POSTGRES_USER',
                  value: params.user,
                },
                {
                  name: 'POSTGRES_PASSWORD',
                  value: params.pasword,
                },
                {
                  name: 'POSTGRES_DB',
                  value: params.database,
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: 'v1',
    kind: 'Service',
    metadata: {
      labels: {
        app: 'db',
      },
      name: 'db',
    },
    spec: {
      type: params.svc_type,
      ports: [
        {
          name: 'db',
          port: params.port,
          protocol: params.proto,
          targetPort: params.out_port,
        },
      ],
      selector: {
        app: 'db',
      },
    },
  },
]
