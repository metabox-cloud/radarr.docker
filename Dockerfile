#metaBox NZBHydra2
# Lightweight Linux Node base
FROM alpine:latest
LABEL maintainer="metaBox <contact@metabox.cloud>"
LABEL build_version=="metaBox - Radarr - v: 1.0"

#MEDIAINFO VERSION
ENV MEDIAINFO_VERSION='0.7.93'

#Add Repo
RUN apk add --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing

# InstalL s6 overlay
RUN wget https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-amd64.tar.gz -O s6-overlay.tar.gz && \
    tar xfv s6-overlay.tar.gz -C / && \
    rm -r s6-overlay.tar.gz

#Add Dependancies.
RUN \
	apk add \
	curl \
	g++ \
	gcc \
	git \
	libcurl \
	python3 \
	make \
	tar \
	unrar \
	p7zip \
	wget \
	xz \ 
	tar \
	sqlite \
	nano \
	htop
	
##Install Mono
RUN apk add --no-cache mono --repository http://dl-cdn.alpinelinux.org/alpine/edge/testing

	
# Add volumes
VOLUME [ "/config" ]
	
RUN \	
  mkdir -p /build/mediaInfo && \
  curl -o /build/mediaInfo/MediaInfo_CLI_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz -L https://mediaarea.net/download/binary/mediainfo/${MEDIAINFO_VERSION}/MediaInfo_CLI_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz && \
  curl -o /build/mediaInfo//MediaInfo_DLL_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz -L https://mediaarea.net/download/binary/libmediainfo0/${MEDIAINFO_VERSION}/MediaInfo_DLL_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz && \
  cd /build/mediaInfo && \
  tar xpf MediaInfo_CLI_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz && \
  tar xpf MediaInfo_DLL_${MEDIAINFO_VERSION}_GNU_FromSource.tar.xz && \
  cd /build/mediaInfo/MediaInfo_CLI_GNU_FromSource && \
  ./CLI_Compile.sh && \
  cd /build/mediaInfo/MediaInfo_CLI_GNU_FromSource/MediaInfo/Project/GNU/CLI/ && \
  make install && \
  cd /build/mediaInfo/MediaInfo_DLL_GNU_FromSource && \
  ./SO_Compile.sh && \
  cd /build/mediaInfo/MediaInfo_DLL_GNU_FromSource/MediaInfoLib/Project/GNU/Library && \
  make install && \
  cd /build/mediaInfo/MediaInfo_DLL_GNU_FromSource/ZenLib/Project/GNU/Library && \
  make install
  
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
   
	
#Do Cleanup
RUN \
 apk del --purge \
    make \
    g++ \
    gcc \
    git \
    sqlite
RUN \
  rm -rf \
    /root/.cache \
    /tmp/* \
    /build/*
	
COPY root/ /
EXPOSE 7878

# Setup EntryPoint
ENTRYPOINT [ "/init" ]

