
local p = import '../params.libsonnet';
local params = p.components.back;
local db_params = p.components.db;

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'nt131-back',
      },
      name: 'nt131-back',
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'nt131-back',
        },
      },
      replicas: params.replicas,
      template: {
        metadata: {
          labels: {
            app: 'nt131-back',
          },
        },
        spec: {
          initContainers: [
            {
              name: 'wait-for-db',
              image: db_params.image + ':' + db_params.version,
              command: [
                'sh',
                '-c',
                'until pg_isready -h db -p ' + db_params.port + ' -U ' + db_params.user + '; do echo not yet; sleep 2; done',
              ],
            },
          ],
          containers: [
            {
              image: params.image + ':' + params.version,
              imagePullPolicy: 'IfNotPresent',
              name: 'backend',
              resources: {
                requests: {
                  memory: params.memory,
                },
              },
              env: [
                {
                  name: 'DATABASE_URL',
                  value: 'postgres://' + db_params.user + ':' + db_params.pasword + '@db:' + db_params.port + '/' + db_params.database,
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
        app: 'nt131-back',
      },
      name: 'nt131-back',
    },
    spec: {
      type: params.svc_type,
      ports: [
        {
          name: 'nt131-back',
          port: params.port,
          protocol: params.proto,
          targetPort: params.out_port,
        },
      ],
      selector: {
        app: 'nt131-back',
      },
    },
  },
]
