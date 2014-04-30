# /etc/skel/.bashrc
#
# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.  So make sure this doesn't display
# anything or bad things will happen !


# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]] ; then
	# Shell is non-interactive.  Be done now!
	return
fi


# Put your fun stuff here.
alias ssh_start='for i in {10..59}; do ssh -f -N -L 30$i:10.10.10.$i:22 root@datamill.uwaterloo.ca; done; for i in {3..9}; do ssh -f -N -L 300$i:10.10.10.$i:22 root@datamill.uwaterloo.ca; done'
alias l='root@localhost'
