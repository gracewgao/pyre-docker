FROM ocaml/opam:debian-10-ocaml-4.11

LABEL maintainer="gracewgao"

SHELL ["/bin/bash", "-c"]

# installs system dependencies
RUN sudo apt update && sudo apt upgrade -y
RUN sudo apt install python3 python3-pip pkg-config -y
RUN sudo apt-get install libsqlite3-dev -y

RUN opam switch create 4.10.2

# downloads and installs the source code
RUN git clone https://github.com/facebook/pyre-check \
    && cd pyre-check \
    && ./scripts/setup.sh --local

# installs make
RUN sudo apt-get install build-essential -y

# updates environment variables
ENV PYRE_BINARY='/home/opam/pyre-check/source/_build/default'
ENV PYRE_TYPESHED='/home/opam/pyre-check/stubs/typeshed/typeshed-master'
ENV PYTHONPATH='/home/opam/pyre-check:$PYTHONPATH'
ENV PATH='/home/opam/.opam/4.10.2/bin:/home/opam/pyre-check/scripts:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH'

# installs pyre-check
RUN cd pyre-check/source \
    && make
# runs tests    
RUN cd pyre-check/source \
    && make test

# updates new environment variables
RUN echo -e 'export PYRE_BINARY=/home/opam/pyre-check/source/_build/default \n \
    export PYRE_TYPESHED=/home/opam/pyre-check/stubs/typeshed \n \
    export PYTHONPATH=/home/opam/pyre-check:$PYTHONPATH \n \
    export PATH=/home/opam/pyre-check/scripts:$PATH' >> ~/.bashrc

# creates alias for python3 as python
RUN sudo touch /usr/bin/python \
    && sudo chmod a+w+x /usr/bin/python \
    && sudo echo -e '#!/bin/bash\n \
    python3 "$@" ' > /usr/bin/python

# adds script to run pyre-check
RUN sudo echo -e '#!/bin/bash\n \
    python -m client.pyre "$@" \n' >> /home/opam/pyre-check/scripts/pyre \
    && sudo chmod +x /home/opam/pyre-check/scripts/pyre

# install python dependencies
RUN cd /home/opam/pyre-check \ 
    && pip3 install -r requirements.txt

# runs python tests
RUN cd /home/opam/pyre-check \ 
    && ./scripts/run-python-tests.sh

CMD /bin/bash
