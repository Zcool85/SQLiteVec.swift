#!/bin/bash

# download sqlite-vec amalgamation
SQLITE_VEC_VERSION=0.1.6

curl -o sqlite-vec-amalgamation.zip -L https://github.com/asg017/sqlite-vec/releases/download/v${SQLITE_VEC_VERSION}/sqlite-vec-${SQLITE_VEC_VERSION}-amalgamation.zip
unzip -q sqlite-vec-amalgamation.zip
mv sqlite-vec.c Sources/CSQLiteVec/
mv sqlite-vec.h Sources/CSQLiteVec/include/
rm sqlite-vec-amalgamation.zip

