# This is my personal development container providing normal day-to-day tools
# and proper environment
FROM golang:alpine


RUN apk upgrade --update && \
  apk add \
      binutils binutils-doc \
      coreutils coreutils-doc \
      ctags \
      curl curl-doc \
      file file-doc \
      findutils findutils-doc \
      git git-doc \
      less less-doc \
      man man-pages \
      mdocml-apropos \
      mksh mksh-doc \
      ncurses \
      nmap nmap-doc \
      openssh-client openssh-doc \
      sed sed-doc \
      shadow \
      socat socat-doc \
      sudo \
      tmux tmux-doc \
      util-linux util-linux-doc \
      vim \
  && rm -fr /var/cache/apk/*

# Enable users belonging to wheel group use sudo without password (as there's none)
RUN sed -i'' -e 's|# %wheel ALL=(ALL) NOPASSWD: ALL|%wheel ALL=(ALL) NOPASSWD: ALL|' /etc/sudoers

RUN adduser -s /bin/mksh -D tmak && \
  addgroup tmak wheel
USER tmak
WORKDIR /home/tmak

# Create terminfo for screen-256color
ADD screen-256color.ti .
RUN tic screen-256color.ti && \
  rm screen-256color.ti

# screen-256color most often matches the client setup
ENV TERM=screen-256color

# Use my traditional $GOPATH
ENV GOPATH=/home/tmak/gopath

# Install vim-go Go Binaries
RUN go get github.com/klauspost/asmfmt/cmd/asmfmt && \
  go get github.com/kisielk/errcheck && \
  go get github.com/davidrjenni/reftools/cmd/fillstruct && \
  go get github.com/nsf/gocode && \
  go get github.com/rogpeppe/godef && \
  go get github.com/zmb3/gogetdoc && \
  go get golang.org/x/tools/cmd/goimports && \
  go get github.com/golang/lint/golint && \
  go get github.com/alecthomas/gometalinter && \
  go get github.com/fatih/gomodifytags && \
  go get golang.org/x/tools/cmd/gorename && \
  go get github.com/jstemmer/gotags && \
  go get golang.org/x/tools/cmd/guru && \
  go get github.com/josharian/impl && \
  go get github.com/dominikh/go-tools/cmd/keyify && \
  go get github.com/fatih/motion


# Fetch personal config & setup vim
RUN git clone https://github.com/tuommaki/dotfiles.git ~/src/dotfiles && \
  cd ~/src/dotfiles && \
  cp vimrc ~/.vimrc && \
  cp tmux.conf ~/.tmux.conf && \
  cp mkshrc ~/.mkshrc && \
  sed -i'' -e '/export EMAIL.*/d' ~/.mkshrc && \
  grep -E '^Plugin ' vimrc | sed -e "s|Plugin '\(.*\)'|\1|g" | \
    grep -v 'cscope' | \
    while read path; do \
      git clone https://github.com/$path ~/.vim/bundle/$(basename $path); \
    done


CMD /bin/mksh

