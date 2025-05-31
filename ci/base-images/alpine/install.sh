#!/usr/bin/env sh
set -e

apk update && apk add --no-cache \
  bash curl git python3 py3-pip build-base \
  openjdk17 maven nodejs npm

if [ -n "${ATOM_RUBY_VERSION}" ]; then
  git clone https://github.com/rbenv/rbenv.git --depth=1 ~/.rbenv
  echo 'export PATH="/root/.rbenv/bin:$PATH"' >> ~/.profile
  echo 'eval "$(/root/.rbenv/bin/rbenv init - bash)"' >> ~/.profile
  . ~/.profile
  mkdir -p "$(rbenv root)/plugins"
  git clone https://github.com/rbenv/ruby-build.git --depth=1 "$(rbenv root)/plugins/ruby-build"
  rbenv install "$ATOM_RUBY_VERSION" -- --disable-install-doc
  rbenv global "$ATOM_RUBY_VERSION"
fi

if [ "${SKIP_ATOM}" != "yes" ]; then
  ARCH_NAME="$(uname -m)"
  curl -L "https://github.com/AppThreat/atom/releases/latest/download/atom-${ARCH_NAME}" -o /usr/local/bin/atom
  chmod +x /usr/local/bin/atom
  /usr/local/bin/atom --help || true
fi

curl -s "https://get.sdkman.io" | bash
. "$HOME/.sdkman/bin/sdkman-init.sh"
echo -e "sdkman_auto_answer=true\nsdkman_selfupdate_feature=false\nsdkman_auto_env=true\nsdkman_curl_connect_timeout=20\nsdkman_curl_max_time=0" >> "$HOME/.sdkman/etc/config"

if [ -n "${JAVA_VERSION}" ]; then
  sdk install java "$JAVA_VERSION"
  if [ -n "${MAVEN_VERSION}" ]; then
    sdk install maven "$MAVEN_VERSION"
  fi
  sdk offline enable
  mv "$HOME/.sdkman/candidates/"* /opt/
  rm -rf "$HOME/.sdkman"
fi

if [ "${SKIP_PYTHON}" != "yes" ]; then
  python3 -m ensurepip
  python3 -m pip install --no-cache-dir --upgrade pip virtualenv
  python3 -m pip install --no-cache-dir --upgrade pipenv poetry uv --target /opt/pypi
fi

if [ "${SKIP_NODEJS}" != "yes" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  . "$HOME/.nvm/nvm.sh"
  nvm install "$NODE_VERSION"
  npm install --global corepack@latest
fi
