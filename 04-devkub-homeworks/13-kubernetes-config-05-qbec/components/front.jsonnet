
local p = import '../params.libsonnet';
local params = p.components.front;
local back_params = p.components.back;

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'nt131-front',
      },
      name: 'nt131-front',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'nt131-front',
        },
      },
      replicas: 1,
      template: {
        metadata: {
          labels: {
            app: 'nt131-front',
          },
        },
        spec: {
          containers: [
            {
              image: params.image + ':' + params.version,
              imagePullPolicy: 'IfNotPresent',
              name: 'frontend',
              resources: {
                requests: {
                  memory: params.memory,
                },
              },
              env: [
                {
                  name: 'BASE_URL',
                  value: 'http://nt131-back:' + back_params.out_port,
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
        app: 'nt131-front',
      },
      name: 'nt131-front',
    },
    spec: {
      type: params.svc_type,
      ports: [
        {
          name: 'nt131-front',
          port: params.port,
          protocol: params.proto,
          targetPort: params.out_port,
        },
      ],
      selector: {
        app: 'nt131-front',
      },
    },
  },
]
