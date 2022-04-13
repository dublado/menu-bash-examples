#!/bin/bash
for term in vt100 linux screen xterm
  { echo "$term:"
    infocmp -L1 $term|egrep 'key_(left|right|up|down|home|end)'
  }
