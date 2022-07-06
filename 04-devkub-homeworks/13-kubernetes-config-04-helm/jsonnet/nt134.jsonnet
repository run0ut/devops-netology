local ns = 'prod';

// back
local back_image    = 'runout/13-kubernetes-config_backend';
local back_version  = 'latest';
local back_memory   = '1000Mi';
local back_port     = 9000;
local back_out_port = 9000;
local back_proto    = 'TCP';
local back_svc_type = 'ClusterIP';

// front
local front_image    = 'runout/13-kubernetes-config_frontend';
local front_version  = 'latest';
local front_memory   = '1000Mi';
local front_port     = 80;
local front_out_port = 80;
local front_proto    = 'TCP';
local front_svc_type = 'ClusterIP';

// db
local db_image    = 'postgres';
local db_version  = '13-alpine';
local db_memory   = '256Mi';
local db_cpu      = '100m';
local db_port     = 5432;
local db_out_port = 5432;
local db_proto    = 'TCP';
local db_user     = 'postgres';
local db_pasword  = 'postgres';
local db_database = 'news';
local db_svc_type = 'ClusterIP';

[
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'nt131-back',
      },
      name: 'nt131-back',
      namespace: ns,
    },
    spec: {
      selector: {
        matchLabels: {
          app: 'nt131-back',
        },
      },
      replicas: 1,
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
              image: db_image + ':' + db_version,
              command: [
                'sh',
                '-c',
                '"until pg_isready -h db -p ' + db_port + ' -U ' + db_user + '; do echo not yet; sleep 2; done"',
              ],
            },
          ],
          containers: [
            {
              image: back_image + ':' + back_version,
              imagePullPolicy: 'IfNotPresent',
              name: 'backend',
              resources: {
                requests: {
                  memory: back_memory,
                },
              },
              env: [
                {
                  name: 'DATABASE_URL',
                  value: 'postgres://' + db_user + ':' + db_pasword + '@db:' + db_port + '/' + db_database,
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
      namespace: ns,
    },
    spec: {
      type: back_svc_type,
      ports: [
        {
          name: 'nt131-back',
          port: back_port,
          protocol: back_proto,
          targetPort: back_out_port,
        },
      ],
      selector: {
        app: 'nt131-back',
      },
    },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'Deployment',
    metadata: {
      labels: {
        app: 'nt131-front',
      },
      name: 'nt131-front',
      namespace: ns,
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
              image: front_image + ':' + front_version,
              imagePullPolicy: 'IfNotPresent',
              name: 'frontend',
              resources: {
                requests: {
                  memory: front_memory,
                },
              },
              env: [
                {
                  name: 'BASE_URL',
                  value: 'http://nt131-back:' + back_out_port,
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
      namespace: ns,
    },
    spec: {
      type: front_svc_type,
      ports: [
        {
          name: 'nt131-front',
          port: front_port,
          protocol: front_proto,
          targetPort: front_out_port,
        },
      ],
      selector: {
        app: 'nt131-front',
      },
    },
  },
  {
    apiVersion: 'apps/v1',
    kind: 'StatefulSet',
    metadata: {
      labels: {
        app: 'db',
      },
      name: 'db',
      namespace: ns,
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
              image: db_image + ':' + db_version,
              ports: [
                {
                  name: 'postgres',
                  containerPort: db_port,
                  protocol: db_proto,
                },
              ],
              resources: {
                requests: {
                  cpu: db_cpu,
                  memory: db_memory,
                },
              },
              env: [
                {
                  name: 'POSTGRES_USER',
                  value: db_user,
                },
                {
                  name: 'POSTGRES_PASSWORD',
                  value: db_pasword,
                },
                {
                  name: 'POSTGRES_DB',
                  value: db_database,
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
      namespace: ns,
    },
    spec: {
      type: db_svc_type,
      ports: [
        {
          name: 'db',
          port: db_port,
          protocol: db_proto,
          targetPort: db_out_port,
        },
      ],
      selector: {
        app: 'db',
      },
    },
  },
]
