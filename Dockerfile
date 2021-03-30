FROM ocaml/opam:debian-10-ocaml-4.11

LABEL maintainer="gracewgao"

SHELL ["/bin/bash", "-c"]

# updates environment variables
ENV PYRE_BINARY='/home/opam/pyre-check/source/_build/default/main.exe'
ENV PYRE_TYPESHED='/home/opam/pyre-check/stubs/typeshed/typeshed-master'
ENV PYTHONPATH='/home/opam/pyre-check:$PYTHONPATH'
ENV PATH='/home/opam/.opam/4.10.2/bin:/home/opam/pyre-check/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH'

RUN echo -e 'export PYRE_BINARY=/home/opam/pyre-check/source/_build/default/main.exe \n \
    export PYRE_TYPESHED=/home/opam/pyre-check/stubs/typeshed/typeshed-master \n \
    export PYTHONPATH=/home/opam/pyre-check:$PYTHONPATH \n \
    export PATH=/home/opam/pyre-check/scripts:$PATH' >> ~/.bashrc

# installs system dependencies
RUN sudo apt update && sudo apt upgrade -y \
    && sudo apt install python3 python3-pip pkg-config -y \
    && sudo apt-get install libsqlite3-dev build-essential -y \ 
    && opam switch create 4.10.2

# downloads and installs pyre-check
RUN git clone https://github.com/facebook/pyre-check \
    && cd pyre-check \
    && ./scripts/setup.sh --local
    
RUN cd pyre-check/source \
    && make \
    && make test

# creates scripts for python alias and pyre-check
RUN sudo touch /usr/bin/python \
    && sudo chmod a+w+x /usr/bin/python \
    && sudo echo -e '#!/bin/bash\n \
    python3 "$@" ' > /usr/bin/python \
    && sudo echo -e '#!/bin/bash\n \
    python -m client.pyre "$@" \n' >> /home/opam/pyre-check/scripts/pyre \
    && sudo chmod +x /home/opam/pyre-check/scripts/pyre

# runs python tests
RUN cd /home/opam/pyre-check \ 
    && pip3 install -r requirements.txt \
    && ./scripts/run-python-tests.sh

# unzips typeshed
RUN cd /home/opam/pyre-check/stubs/typeshed \
    && unzip typeshed.zip

CMD /bin/bash
