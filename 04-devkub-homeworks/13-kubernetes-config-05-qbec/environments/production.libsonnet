
// this file has the param overrides for the default environment
local base = import './base.libsonnet';

base {
  components +: {
    back +: {
      replicas: 3
    },
    front +: {
      replicas: 3
    }
  }
}
