#!/bin/bash
trap 'cp /jd-scripts-docker/sync.sh /sync' Exit
(
  exec 2<>/dev/null
  set -e
  cd /jd-scripts-docker
  git checkout .
  git pull
) || {
  git clone https://github.com/chinnkarahoi/jd-scripts-docker.git /jd-scripts-docker_tmp
  [ -d /jd-scripts-docker_tmp ] && {
    rm -rf /jd-scripts-docker
    mv /jd-scripts-docker_tmp /jd-scripts-docker
  }
}
(
  exec 2<>/dev/null
  set -e
  cd /scripts
  git checkout .
  git pull
) || {
  git clone --branch=master https://github.com/chinnkarahoi/jd_scripts.git /scripts_tmp
  [ -d /scripts_tmp ] && {
    rm -rf /scripts
    mv /scripts_tmp /scripts
  }
}
(
  exec 2<>/dev/null
  set -e
  cd /loon
  git checkout .
  git pull
) || {
  git clone --branch=main https://github.com/chinnkarahoi/Loon.git /loon_tmp
  [ -d /loon_tmp ] && {
    rm -rf /loon
    mv /loon_tmp /loon
  }
}
cd /scripts || exit 1
cp -r /loon/* /scripts
npm install || npm install --registry=https://registry.npm.taobao.org || exit 1
[ -f /crontab.list ] && {
  cp /crontab.list /crontab.list.old
}
cat /etc/os-release | grep -q ubuntu && {
  cp /jd-scripts-docker/crontab.list /crontab.list
  crontab -r
} || {
  echo "55 */1 * * *  bash /jd-scripts-docker/cron_wrapper bash /sync" > /crontab.list
  ls /scripts/*.js | xargs -i cat {} | grep ^cron | grep \".*\" | sed -E 's|.*"(.*)".*[/ =]([^/]*.js).*|\1 bash /jd-scripts-docker/cron_wrapper "node /scripts/\2"|g' >> /crontab.list
  cat /custom.list >> /crontab.list
}

crontab /crontab.list || {
  cp /crontab.list.old /crontab.list
  crontab /crontab.list
}
crontab -l


