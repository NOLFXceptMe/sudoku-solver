#!/bin/bash

# Empty first element to start indexing from 1
SOLUTIONS=(""
"1|5|2|4|8|9|3|7|6
7|3|9|2|5|6|8|4|1
4|6|8|3|7|1|2|9|5
3|8|7|1|2|4|6|5|9
5|9|1|7|6|3|4|2|8
2|4|6|8|9|5|7|1|3
9|1|4|6|3|7|5|8|2
6|2|5|9|4|8|1|3|7
8|7|3|5|1|2|9|6|4"

"9|5|7|6|1|3|2|8|4
4|8|3|2|5|7|1|9|6
6|1|2|8|4|9|5|3|7
1|7|8|3|6|4|9|5|2
5|2|4|9|7|1|3|6|8
3|6|9|5|2|8|7|4|1
8|4|5|7|9|2|6|1|3
2|9|1|4|3|6|8|7|5
7|3|6|1|8|5|4|2|9"

"7|2|6|4|9|3|8|1|5
3|1|5|7|2|8|9|4|6
4|8|9|6|5|1|2|3|7
8|5|2|1|4|7|6|9|3
6|7|3|9|8|5|1|2|4
9|4|1|3|6|2|7|5|8
1|9|4|8|3|6|5|7|2
5|6|7|2|1|4|3|8|9
2|3|8|5|7|9|4|6|1"

"1|7|2|5|4|9|6|8|3
6|4|5|8|7|3|2|1|9
3|8|9|2|6|1|7|4|5
4|9|6|3|2|7|8|5|1
8|1|3|4|5|6|9|7|2
2|5|7|1|9|8|4|3|6
9|6|4|7|1|5|3|2|8
7|3|1|6|8|2|5|9|4
5|2|8|9|3|4|1|6|7"

"5|8|1|6|7|2|4|3|9
7|9|2|8|4|3|6|5|1
3|6|4|5|9|1|7|8|2
4|3|8|9|5|7|2|1|6
2|5|6|1|8|4|9|7|3
1|7|9|3|2|6|8|4|5
8|4|5|2|1|9|3|6|7
9|1|3|7|6|8|5|2|4
6|2|7|4|3|5|1|9|8"
)

for i in {1..5}; do
  OUT=`ruby sdksolver.rb "problem${i}.sdk" | grep -m1 -A9 "Solution" | tail -n9`

  if [[ ${SOLUTIONS[i]} == $OUT ]]; then
    echo "Test${i} passed"
  else
    echo "Test${i} failed"
  fi
done
