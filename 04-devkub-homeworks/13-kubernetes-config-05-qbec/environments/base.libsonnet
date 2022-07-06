
// this file has the baseline default parameters
{
  components: {
    back: {
      image: 'runout/13-kubernetes-config_backend',
      version: 'latest',
      memory: '1000Mi',
      port: 9000,
      out_port: 9000,
      proto: 'TCP',
      svc_type: 'ClusterIP'
    },
    front: {
      image: 'runout/13-kubernetes-config_frontend',
      version: 'latest',
      memory: '1000Mi',
      port: 80,
      out_port: 80,
      proto: 'TCP',
      svc_type: 'ClusterIP'
    },
    db: {
      image: 'postgres',
      version: '13-alpine',
      memory: '256Mi',
      cpu: '100m',
      port: 5432,
      out_port: 5432,
      proto: 'TCP',
      user: 'postgres',
      pasword: 'postgres',
      database: 'news',
      svc_type: 'ClusterIP'
    }
  }
}