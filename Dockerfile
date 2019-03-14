FROM fretlink/nix

RUN nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs
RUN nix-channel --update
USER root
RUN apk update &&\
    apk add --no-cache git curl bzip2 bash openssl &&\
    # addgroup nixuser root &&\
    chown nixuser /nix
ADD nix.conf /etc/nix/
RUN su - nixuser -c 'git clone https://github.com/input-output-hk/cardano-sl.git /home/nixuser/cardano-sl'
USER nixuser
ENV USER nixuser

WORKDIR /home/nixuser/cardano-sl
RUN git checkout tags/2.0.1

RUN nix-build -A cardano-sl-node-static --cores 0 --max-jobs 2 --no-build-output --out-link master
RUN nix-build -A connectScripts.mainnet.wallet -o connect-to-mainnet

USER root
CMD ./connect-to-mainnet --no-tls
