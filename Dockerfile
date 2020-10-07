#metaBox Radarr
# Lightweight Linux Node base
FROM metaboxcloud/docker.base.mono:latest
LABEL maintainer="metaBox <contact@metabox.cloud>"
LABEL build_version="metaBox - Radarr - v: 1.0"

 RUN \
  mkdir -p /app/radarr && \
  mkdir -p /build/radarr && \
  radarr_tag=$(curl -sX GET "https://api.github.com/repos/Radarr/Radarr/releases" | awk '/tag_name/{print $4;exit}' FS='[""]') && \
  curl -o /build/radarr/radarr.tar.gz -L "https://github.com/galli-leo/Radarr/releases/download/${radarr_tag}/Radarr.develop.${radarr_tag#v}.linux.tar.gz" && \
   tar ixzf /build/radarr/radarr.tar.gz -C /app/radarr --strip-components=1
 
#Do Permissions
RUN addgroup -g 911 abc
RUN adduser -u 911 -D -G abc abc
RUN chown -R 911:911 /app/radarr 
   
RUN \
  rm -rf \
    /root/.cache \
    /tmp/* \
    /build/*
	
COPY root/ /
EXPOSE 7878

# Setup EntryPoint
ENTRYPOINT [ "/init" ]

