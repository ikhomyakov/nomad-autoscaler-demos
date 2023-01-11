job "batch" {
  datacenters = ["batch_workers"]
  type        = "batch"

  parameterized {
    meta_optional = ["kind", "prefix", "tile", "band", "catalog"]
  }

  meta {
    kind = "s2"
    prefix = "s3://constellr-product-segment/sentinel-s2-l2a-zarrs/"
    tile = "16TEL"
    band = "B1"
    catalog = "s3://constellr-product-segment/sentinel-s2-l2a-zarrs/catalogs/16TEL.cat"
  }

  group "batch" {
    task "batch" {
      driver = "docker"

      config {
        image   = "public.ecr.aws/n8p1o0d8/hdsa:0.2.0"
        command = "/bin/bash"
        args    = ["${NOMAD_TASK_DIR}/batch.sh"]
      }

      template {
        data = <<EOF
#!/usr/bin/env bash
echo prefix=${NOMAD_META_prefix}
echo tile=${NOMAD_META_tile}
echo band=${NOMAD_META_band}
echo catalog=${NOMAD_META_catalog}
pwd
ls -l
echo "Done"
        EOF
        destination = "local/batch.sh"
      }

      resources {
        cpu    = 500
        memory = 1000
      }
    }
  }
}
