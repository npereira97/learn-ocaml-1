FROM raml_base


ENV LD_LIBRARY_PATH  /home/opam/opam-repository/clp/coin-Clp/lib

COPY main.ml main.ml
COPY Makefile.in Makefile.in


RUN sudo env "PATH=$PATH" "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" ./configure --with-coin-clp clp/coin-Clp
RUN sudo env "PATH=$PATH" "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" make 


EXPOSE 5000

CMD ["./main"]

