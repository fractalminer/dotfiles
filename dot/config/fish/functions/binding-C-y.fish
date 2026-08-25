# Runs `make test` with appropriate number of cores.  If
# shift is held then it will be OPT=.
function binding-C-y
  test -e Makefile; or return 1
  # set -l cores (cores)
  # set -l cmd "make test -j$cores"
  set -l cmd "make test"
  # Put the command on the command line and then execute it in a
  # way that then puts it in the fish history.
  commandline $cmd
  commandline -f execute
end
