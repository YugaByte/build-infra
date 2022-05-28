#!/usr/bin/env bash

set -euo pipefail -x

spark_version=3.2.1
spark_dir_name="spark-${spark_version}-bin-hadoop3.2"
spark_tarball_name="$spark_dir_name.tgz"
spark_download_url="https://dlcdn.apache.org/spark/spark-${spark_version}/${spark_tarball_name}"

spark_parent_dir=/opt/yb-build/spark
mkdir -p "${spark_parent_dir}"
cd "${spark_parent_dir}"
rm -f "${spark_tarball_name}"
curl -O "${spark_download_url}"
ls -l "${spark_tarball_name}"
expected_sha256sum=224e058cb0c6fb68b39896427a3ccd11ae2246e9bf465b5e29e4fb192d39a59c
actual_sha256sum=$( sha256sum "$spark_tarball_name" | awk '{print $1}' )
if [[ $actual_sha256sum != "$expected_sha256sum" ]]; then
  echo "Invalid checksum: $actual_sha256sum, expected: $expected_sha256sum" >&2
  exit 1
fi

tar xzf "${spark_tarball_name}"
spark_install_dir="${spark_parent_dir}/${spark_dir_name}"

if [[ ! -d "${spark_install_dir}" ]]; then
  echo "$spark_install_dir did not get created after extracting the tarball" >&2
  exit 1
fi
spark_conf_dir="${spark_install_dir}/conf"

spark_worker_dir=/var/spark/worker
mkdir -p "${spark_worker_dir}"
chmod a+w "${spark_worker_dir}"

cat >"${spark_conf_dir}/spark-env.sh" <<-EOT
SPARK_WORKER_DIR=${spark_worker_dir}
EOT

cd "${spark_parent_dir}"
if [[ -d current ]]; then
  unlink current
fi
ln -s "${spark_dir_name}" current
