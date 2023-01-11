job "batch" {
  datacenters = ["batch_workers"]
  type        = "batch"

  parameterized {
    meta_optional = ["tile", "band"]
  }

  meta {
    tile = "16TDK"
    band = "AOT"
  }

  group "batch" {
    task "batch" {
      driver = "docker"

      config {
        image   = "public.ecr.aws/n8p1o0d8/hdsa:0.6.1"
        command = "/bin/bash"
        args    = ["${NOMAD_TASK_DIR}/batch.sh"]
      }

      template {
        data = <<EOF
#!/bin/bash
set -e
echo "Start"
eval "$('/conda/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
echo tile=${NOMAD_META_tile} band=${NOMAD_META_band}
cd /scripts
pwd
curl https://icanhazip.com/
echo "Work"
#bash -e s2zarr.sh "${NOMAD_META_tile}" "${NOMAD_META_band}"
bash -e l2zarr.sh "${NOMAD_META_tile}" "${NOMAD_META_band}"
echo "Done"
        EOF
        destination = "local/batch.sh"
      }

      resources {
        cpu = 3000
        memory = 7000
      }
    }
  }
}
